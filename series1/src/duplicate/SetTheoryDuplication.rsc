module duplicate::SetTheoryDuplication

import ProjectAnnotations;
import ListRelation;
import lang::java::m3::AST;
import Prelude;
import Analyzer;


public void duplicationSetCheck(ProjectTree project){
	list[ProjectTree] sourceFiles  = project@sourceFileList;
	int sourcesCount = size(sourceFiles);
	int totalDuplicatedLines = searchDuplication(sourceFiles);
	println("totalDuplicatedLines <totalDuplicatedLines>");
}
 
 
private int searchDuplication(list[ProjectTree] sourceFiles){
	list[str] allLines = [];
	int currentIndex = 0;
	int comboCount = 0;
	list[int] comboLineNrs = [];
	list[str] comboLines = [];
	list[str] comboLinesTemp = [];
	lrel[int,str] nr2LineRel ;
	int lineCounter = 0;
	int fileLoops = 0;
	int duplicatedLinesCount = 0;
	for(file <- sourceFiles){
		list[str] fileLines = file@fileLines;
		lineLoops = size(fileLines);
		for(line <-fileLines){
		//println("<line>");
			lineCounter += 1;
			allLines += line;
			if(line == "}" && comboCount == 0){
				currentIndex +=1;
				continue;
			} 
			int index = indexOf(allLines,line);
			if( (index < currentIndex) ){
				//println("<line>");
				comboCount +=1;
				comboLinesTemp += line;
				if((lineCounter ==lineLoops) && comboCount>=6){
					duplicatedLinesCount += comboCount;
					comboLines += comboLinesTemp;
				}
			}else{
				if(comboCount>=6){
					duplicatedLinesCount += comboCount;
					comboLines += comboLinesTemp;
				}
				comboLinesTemp = [];
				//comboLineNrs = [];
				comboCount = 0;
			}
		currentIndex+=1;
		}
		comboLinesTemp = [];
		//comboLineNrs = [];
		comboCount = 0;
		lineCounter = 0;
	}
	println("comboLines: <comboLines>");
	return duplicatedLinesCount;
}
//
//for(file <- sourceFiles){
//		lrel[int,str] nr2LineRel = toList(file@nrs2lines);
//		lineLoops = size(nr2LineRel);
//		for(<lineNr,line> <-sort(nr2LineRel)){
//			lineCounter += 1;
//				allLines += line;
//			
//			int index = indexOf(allLines,line);
//			if( (index < currentIndex) ){
//				comboCount +=1;
//				comboLineNrs += lineNr;
//				comboLinesTemp += line;
//				if((lineCounter ==lineLoops) && comboCount>=6){
//					duplicatedLinesCount += comboCount;
//					comboLines += comboLinesTemp;
//				}
//			}else{
//				if(comboCount>=6){
//					duplicatedLinesCount += comboCount;
//					comboLines += comboLinesTemp;
//				}
//				comboLinesTemp = [];
//				comboLineNrs = [];
//				comboCount = 0;
//			}
//		currentIndex+=1;
//		}
//		comboLinesTemp = [];
//		comboLineNrs = [];
//		comboCount = 0;
//		lineCounter = 0;
//	}
