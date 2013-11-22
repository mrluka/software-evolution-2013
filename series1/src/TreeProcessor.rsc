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
data ProjectTree = root(set[ProjectTree] projects) 
              | project(loc id,str name, set[ProjectTree] contents)
              | folder(loc id, set[ProjectTree] contents)
              | file(loc id)
              | sourceFile(loc id, Declaration declaration);
        
        
public ProjectTree makeProjectTree(loc projectLoc){
	println("\>making project tree\<");
	Resource projectResource = getProject(projectLoc);
	return makeTree(projectResource);
}    
           

private ProjectTree makeTree(Resource projectResource){
	ProjectTree projectTree; // return value
	set[ProjectTree] folders = {};	
	visit(projectResource){
		case  f: folder(loc folderLoc, set[Resource] contents) : { 
			set[ProjectTree] sourceFiles = {};
			list[loc] folderContent = folderLoc.ls;
			bool hasSourceFiles = false;
			for(l <- folderContent){
				if(isSourceFile(l)){
					Declaration declaration = createAstFromFile(l,true);
					ProjectTree sFile = sourceFile(declaration@src, declaration); // use declaration@src because fileLoc does NOT contain begin.line, end.line,etc					
					sourceFiles += sFile;
					hasSourceFiles = true;
				}
			}
			
			if(hasSourceFiles){
				ProjectTree newFolder = folder(folderLoc, sourceFiles);
				folders += newFolder;
			}
		}
	}
	
	projectTree = project(projectResource.id,projectResource.id.authority, folders); //init return value
	ProjectTree root = root({projectTree});
	return root;
}

private bool isSourceFile(loc file){
	return /.*java/ := file.extension;
}
