module TreeProcessor

import count::LocCounter; 
import count::UnitCounter; 
import ProjectAnnotations;
import util::Resources;
import IO;
import Set;
import ListRelation;
import lang::java::m3::AST;

public ProjectTree makeProjectTree(loc projectLoc){
	println("\>Start: Make Tree\<");
	Resource projectResource = getProject(projectLoc);
	return makeTree(projectResource);
}    
           

private ProjectTree makeTree(Resource projectResource){
	ProjectTree projectTree; // return value
	int c = 0; // for testing stuff
	int folderUnitsCount =0, folderClassesCount = 0, totalSFCount =0,folderSFCount = 0;
	set[ProjectTree] folders = {};
	list[ProjectTree] totalSourceFileList = [];
	
	bottom-up visit(projectResource){

		case ProjectTree r : root(set[ProjectTree] projects):{ // ROOT
			println("root");
			r@classesCount = totalSFCount;
			insert r;
		}
		
		case ProjectTree p : project(loc id,str name, set[ProjectTree] contents):{ // PROJECT
			println("project");
			projectTree@sourceFileList = totalSourceFileList;
			p@sourcesCount = totalSFCount;
			
			insert p;
		}
		
		case  f: folder(loc folderLoc, set[Resource] contents) : {
			if(!isTestFolder(folderLoc)){ 
				set[ProjectTree] sourceFiles = {};
				list[loc] folderContent = folderLoc.ls;
				bool hasSourceFiles = false;
				for(l <- folderContent){
					if(isSourceFile(l) && !isTestFile(l)){
						Declaration declaration = createAstFromFile(l,true);
						ProjectTree sFile = sourceFile(declaration@src, declaration); // use declaration@src because fileLoc does NOT contain begin.line, end.line,etc
						list[str] afileLines = readFileLines(declaration@src);
						ProjectTree countedSourceFile = countSourceFileElements(sFile); // In UNIT COUNTER
						countedSourceFile@fileLines = afileLines;
						ProjectTree locFile = getLocCountedSourceFile(countedSourceFile); // IN LOC COUNTER
						sourceFiles += locFile;
						hasSourceFiles = true;
						folderSFCount +=1;
					}
				}
				
				if(hasSourceFiles){
					ProjectTree newFolder = folder(folderLoc, sourceFiles);
					totalSourceFileList += toList(sourceFiles);
					totalSFCount += folderSFCount;
					newFolder@sourcesCount=folderSFCount; // source files per folder
					newFolder@unitsCount = folderUnitsCount; // unit count per folder
					newFolder@classesCount = folderClassesCount; // classes count per folder
					newFolder.contents = sourceFiles;			
					folderUnitsCount = 0;
					folderClassesCount = 0;
					folderSFCount = 0;
					folders += newFolder;
				}
			}
		}
	}
	
	projectTree = project(projectResource.id,projectResource.id.authority, folders); //init return value
	projectTree@sourceFileList = totalSourceFileList;
	int projectLOC =  getProjectLOC(totalSourceFileList);
	
	ProjectTree root = root({projectTree[@LOC=projectLOC][@sourceFileList=totalSourceFileList]});
	return root;
}


private bool isSourceFile(loc file){
	return /.*java/ := file.extension;
}

private bool isTestFolder(loc folder){
	return /^.*Test.*/ := folder.path;
}

private bool isTestFile(loc file){
	return /^.*Test.*$/ := file.file; 
}






//
//case ProjectTree f : folder(id, contents) :{ //FOLDER: sourcesCount, unitsCount, classesCount
//			set[ProjectTree] sourceFiles = {};  
//			for(sFile <- contents){ //For each source file in folder
//				ProjectTree countedSourceFile = countSourceFileElements(sFile); 
//				sourceFiles += countedSourceFile;
//				folderUnitsCount += countedSourceFile@unitsCount;
//			}
//			int folderSFCount = size(id.ls); 
//			totalSFCount += folderSFCount;
//			f@sourcesCount=folderSFCount; // source files per folder
//			f@unitsCount = folderUnitsCount; // unit count per folder
//			f@classesCount = folderClassesCount; // classes count per folder
//			f.contents = sourceFiles;			
//			folderUnitsCount = 0;
//			folderClassesCount = 0;
//			insert f;
//		}
		
		
		