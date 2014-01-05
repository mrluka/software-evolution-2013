module TreeProcessor


//import count::UnitCounter; 
import ProjectAnnotations;
import util::Resources;
import IO;
import Set;
import List;
import Relation;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import vis::Figure;
import vis::Render;
import complexity::ComplexityAnalyzer;
import complexity::StatementComplexity;
//import complexity::ExpressionComplexity;
import complexity::ComplexityRiskLevels;
//import complexity::ComplexityVisualizer;
//import sig::Rating;
import count::LocCounter; 

//duplicatedLines duplicatedLinesMap
public Resource makeTree(loc projectLocation){
	Resource projectResource = getProject(projectLocation);
	int folderSourcesCount = 0, totalSourcesCount= 0, folderClassesCount= 0, totalClassesCount = 0, totalLOC =0 ;
	list[Resource] allSourceFiles = []; 
	
	//DUPLICATION
	int comboCount = 0;
	list[str] comboLines = [];
	list[str] comboLinesTemp = [];
	int lineCounter = 0;
	int duplicatedLinesCount = 0;
	set[str] allLinesSet = {};
	int lastSetSize = -1;
	int setSize = -1;
	map[loc file,list[int]lines] file2LinesMap = ();	// ! 
	list[int] tempFileLines = []; // ! 
	// -----------	
	return bottom-up visit(projectResource){ 
		case  p : project(loc id, set[Resource] contents):{ 
			set[Resource] relevantItems = {items |  items <- contents, isRelevantItem(items.id)};
			p.contents	 = relevantItems;
			p@sourcesCount = totalSourcesCount;
			p@classesCount = totalClassesCount;
			p@LOC = totalLOC;
			//int duplicatedLinesCount =  searchDuplication(allSourceFiles);
			p@duplicationLineCount = duplicatedLinesCount;
			p@duplicatedLinesMap = file2LinesMap;
			//println(duplicatedLinesCount);
			//iprint(file2LinesMap);
			insert p; 
		}
		case  f: folder(loc folderLoc, set[Resource] contents) : {
			if(!isTestFolder(folderLoc)){
				set[Resource] relevantItems = {items |  items <- contents, isRelevantItem(items.id)};
				f.contents = relevantItems;
				f@sourcesCount= folderSourcesCount;
				f@classesCount= folderClassesCount;
				folderSourcesCount =0;
				folderClassesCount =0;
				insert f;
			}  
		}
		case f: file(_)  : { 
			if(isSourceFile(f.id) && !isTestFile(f.id)){ 
				Declaration declaration = createAstFromFile(f.id,true);
				f@declaration  = declaration;
				units = [b | u <- f@declaration.types, b <- u.body, \method( \return,  name, parameters,exceptions, Statement stat) := b || \method( \return,  name, parameters,exceptions) := b ];
				f@unitsCount = size(units); // unit count (per file)
				f@importsCount = size(f@declaration.imports);  // import count
				f@classesCount = size(f@declaration.types); //classes count
				f@fileLines =readFileLines(f.id);
				f = getLocCountedSourceFile(f); 
				totalLOC += f@LOC;
				folderSourcesCount += 1;
				folderClassesCount += f@classesCount;
				totalSourcesCount += 1;
				totalClassesCount += f@classesCount;
				allSourceFiles += f;
				
				//DUPLICATION
				file2LinesMap[f.id] = []; // ! 
				list[str] fileLines = f@fileLines;
				lineLoops = size(fileLines);
				
				for(line <-f@fileLines){
					lineCounter += 1;
					lastSetSize = size(allLinesSet);
					allLinesSet += line;
					setSize = size(allLinesSet);
					if(lastSetSize == setSize){
						comboCount += 1;
						tempFileLines += lineCounter; // ! 
						if((lineCounter ==lineLoops) && comboCount>=6){
							duplicatedLinesCount += comboCount;
							comboLines += comboLinesTemp;
							file2LinesMap[f.id] += tempFileLines; // !
							tempFileLines = []; // !
							comboCount = 0;
							//println(file2LinesMap[f.id]);// !
						}
					}else{
						if(comboCount >= 6){
							duplicatedLinesCount += comboCount;
							file2LinesMap[f.id] += tempFileLines; // !
							//println(file2LinesMap[f.id]); // !
						}
						tempFileLines = []; // !
						comboCount = 0;
					}
				}
				f@duplicatedLines = file2LinesMap[f.id];
				tempFileLines = []; // !
				lineCounter = 0;
				comboCount = 0;
				insert f; 
			}
		}
	};
}



private bool isRelevantItem(loc itemLocation){
	return isSourceFile(itemLocation) && !isTestFolder(itemLocation);
}

private bool isSourceFile(loc file){
	return (/.*java/ := file.extension || file.extension == "") && !(/^\..*/ := file.extension);
}

private bool isTestFolder(loc folder){
	if(/^.*Test.*/ := folder.path || /^.*junit.*/ := folder.path || /^.*lib.*/ := folder.path){ //test folder	
		return true;
	}
	if( /^.*\/bin.*/ := folder.path){ //bin folder
		return true;
	}
	if( /^\..*/ := folder.file){ // hiden folder
		return true;
	}
	if( /^\.txt/ := folder.file){ // txt file 
		return true;
	}
	if( /^\.lib/ := folder.file){ // lib file
		return true;
	}
	return  false;
}

private bool isTestFile(loc file){
	return /^.*Test.*$/ := file.file; 
}


public void printToFile(value toPrint,bool saveToFile){
	if(saveToFile){
		iprintToFile(|file:///Volumes/Big/Uni/Master02/Software_Evolution/workspace/series1/output.txt|,toPrint);
	}else{
		iprintln(toPrint);
	}
}


//private int searchDuplication(list[Resource] sourceFiles){
	//int comboCount = 0;
	//list[str] comboLines = [];
	//list[str] comboLinesTemp = [];
	//int lineCounter = 0;
	//int duplicatedLinesCount = 0;
	//set[str] allLinesSet = {};
	//int lastSetSize = -1;
	//int setSize = -1;
	//
	//map[str file,list[int]lines] file2LinesMap = ();	// ! 
	//list[int] tempFileLines = []; // ! 
	
	//for(file <- sourceFiles){ // PER SOURCE FILE 
		//file2LinesMap["fileLocation"] = []; // ! 
		//list[str] fileLines = file@fileLines;
		//lineLoops = size(fileLines);
		
		
		//for(line <-fileLines){
		//	lineCounter += 1;
		//	lastSetSize = size(allLinesSet);
		//	allLinesSet += line;
		//	setSize = size(allLinesSet);
		//	if(lastSetSize == setSize){
		//		comboCount += 1;
		//		tempFileLines += lineCounter; // ! 
		//		if((lineCounter ==lineLoops) && comboCount>=6){
		//			duplicatedLinesCount += comboCount;
		//			comboLines += comboLinesTemp;
		//			file2LinesMap["fileLocation"] += tempFileLines; // !
		//			tempFileLines = []; // !
		//			comboCount = 0;
		//			println(file2LinesMap["fileLocation"]);// !
		//		}
		//	}else{
		//		if(comboCount >= 6){
		//			duplicatedLinesCount += comboCount;
		//			file2LinesMap["fileLocation"] += tempFileLines; // !
		//			println(file2LinesMap["fileLocation"]); // !
		//		}
		//		tempFileLines = []; // !
		//		comboCount = 0;
		//	}
		//}
		
		
		//tempFileLines = []; // !
		//lineCounter = 0;
		//comboCount = 0;
	
	//}
	//return duplicatedLinesCount;
//}
