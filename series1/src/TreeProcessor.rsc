module TreeProcessor

import Prelude;
import util::Resources;
import IO;
import List;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::m3::TypeHierarchy;
import lang::java::m3::TypeSymbol;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;

// TreeProcessor creates a tree out of a project location. The tree contains nodes with information such as: XXXXXX ToDo

 //ProjectTree annotations
 //FOLDER
anno int ProjectTree @sourceFileCount; 

data ProjectTree = root(set[ProjectTree] projects) 
              | project(loc id,str name, set[ProjectTree] contents)
              | folder(loc id, set[ProjectTree] contents)
              | file(loc id)
              | sourceFile(loc id, Declaration declaration);
              
              




public ProjectTree createProjectTree(loc projectLoc){
	Resource projectResource = getProject(projectLoc);
	//println("---------projectResource:");
	//iprint(projectResource);
	return makeProjectTree(projectResource);
}    


// MAKE TREE
private ProjectTree makeProjectTree(Resource projectResource){ 
	ProjectTree projectTree; // Return value
	set[ProjectTree] files = {}; //helper set to store files that are added to the current folder in visit statement
	set[ProjectTree] folders= {}; // same as files -^ but folders
	int counter = 0; //for testing.
	
	bottom-up visit (projectResource) { 
	
		//PROJECT
		case project(loc id, set[Resource] contents) : { //Because of bottom-up, this one is visited last (but not least)
			projectTree = project(id,id.authority, (files +folders)); //init return value
		}
		//FOLDER
		case  folder(loc folderLoc, set[Resource] contents) : {
			if(counter == 11 || counter == 10){ //only for testing. 
				if(size(files)>0){ //Do not add empty folders. 
					ProjectTree folder =  folder(folderLoc,files); //create folder and add enclosed files
					folders += folder; //add folder to folder set
					files = {}; //empty files set because all files of folder were already visited and added to folder
				}
			}
			counter +=1; //for testing
		} 
		//FILE
		case f: file(fileLoc) : {
			if(/.*java/ := fileLoc.extension){ //Check file extension, we only need .java itc
				Declaration declaration = createAstFromFile(fileLoc,true);
				ProjectTree sFile = sourceFile(declaration@src, declaration); // use declaration@src because fileLoc does NOT contain begin.line, end.line,etc					
				files += sFile;
			}
			//else{ // for NOT Java files
			//	ProjectTree file = file(fileLoc);
			//	files += file;
			//}
		}
			//ROOT
		case root(set[Resource] projects) : { //Never occurred
			println("root size: <size(projects)>");
		}
	};
	return projectTree;	
}