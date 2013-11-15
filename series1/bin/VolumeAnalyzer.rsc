module VolumeAnalyzer

import Prelude;
import util::Resources;
import IO;
import List;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;

anno int Declaration @count; 
//anno str Declaration @count; 

public void analyzeProjectVolume(){
	analyzeSmallProject();
}

public void analyzeSmallProject(){
	loc projectLocation = |project://smallsql0.21_src/|;
	preStuff(projectLocation);
	// parseM3(projectLocation);	 //import lang::java::jdt::m3::Core;
}

private void preStuff(loc projectLocation){
	Resource projectResource = getProject(projectLocation);
	println("--- START project: <projectLocation>");
	countFolder(projectResource);
	countTotalFiles(projectResource);	
	countClassFiles(projectResource);
	//printHierarchicalRepresentation(projectResource);
	println("--- FINISHED SMALL project");
}




private void parseM3AST(loc projectLoc){
	M3 ast = createM3FromEclipseFile(projectLoc); 	
	rel[loc from, loc to] containmentRelations = ast@containment; // containment contains class, method,field,variable,constructor name(s). modifier(?)-> name
	set[loc] containmentSet = carrier(containmentRelations); //Set of all name occurrences, no duplications (set of names)
	//Constructors
	set[loc] classConstructors = getNames(containmentSet,"java+constructor"); 
	println("classConstructors: <classConstructors>");
	
	
	//Methods
	set[loc] classMethods = getNames(containmentSet,"java+method"); 
	println("classMethods: <classMethods>");
	
	//Fields
	set[loc] classFields = getNames(containmentSet,"java+field");
	println("class fields:<classFields>");
	
	
}

private set[loc] getNames(set[loc] locations, str namePattern){
	return {n | loc n <- locations, /^.*?<word:\w*><namePattern><rest:.*$>/:= toString(n)}; //Checks if location contains "java+method", which indicates a method(relation, see above)
} 


//data Class = class(str name, list[Type] extends, list[Type] implements, list[Declaration] body);  //| class(list[Declaration] body);
//anno int Class@methods;
//anno int Class@members;
//anno int Class@imports;
 
private void parseAST(loc fileLoc, bool b){
	Declaration ast = createAstFromFile(fileLoc.top,b);  // createAstsFromDirectory would return list[Declaration] 
	//iprint(ast); //prettyprint AST
	//Class class;
	top-down visit(ast){
		case c:\class(str name, list[Type] extends, list[Type] implements, list[Declaration] body): { // Count imports
		//case \Class c: {
			class = c;
			println("class: <class> ");
		}
		
		case \package(str name): { 
			println("package: <name> ");
		}
		
		case \import(str imp): { // Count imports
			println("Import: <imp>");
			//class[@imports =1];
		} 
		case \compilationUnit(list[Declaration] imports, list[Declaration] types): { 
			println("compilationUnit: ");
		} 
		case \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types): { 
			println("compilationUnit2 Declaration package: <package> ");
		} 
		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): { 
			println("method:<name> "); // with Expression able to go level deeper into expression attributes
		} 
		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions): { 
			println("method2: <name> ");
		}
		
		case \variables(Type \type, list[Expression] \fragments): { 
			println("type: <\type> ");
		}
    
	};
}


private void countClassFiles(Resource projectResource){
	int cFileCount = 0;
	visit(projectResource){			
		case file(loc fLoc) : { // Visit each file in Resource
			visit(fLoc.extension){ // Visit each file's extension
				case /^.*java+$/ : { // Java source file
			 		cFileCount +=1; 
			 		if(cFileCount <=1){
			 			println("File: <fLoc>");
			 			//parseAST(fLoc,false);
			 			parseM3AST(fLoc);
			 		}
			 	}
			};
		}
	};
	println("Class files:<cFileCount>");
}




private void countFolder(Resource projectResource){
	int folderCount=0;
	
	visit(projectResource){
		case folder(loc id, set[Resource] contents): {
		folderCount += 1;
		} 
		//case root(_) :println("root");
	};	
	println("Folders: <folderCount>");
}

private void countTotalFiles(Resource projectResource){
	int fileCount = 0;
	visit(projectResource){
		case file(loc id): fileCount += 1; //case file(loc id): println("file:<id>");
	};
	println("Total files: <fileCount>");
}

private void printHierarchicalRepresentation(Resource projectResource){ //(loc projectLocation){
	println("Hierarchy:<projectResource>");
}