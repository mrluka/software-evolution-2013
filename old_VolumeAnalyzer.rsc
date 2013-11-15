module VolumeAnalyzer

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

// -------
public void analyzeProjectVolume(){
	analyzeSmallProject();
}

public void analyzeSmallProject(){
	loc projectLocation = |project://smallsql0.21_src/|+"";	
	
	//Global project data: contains folders, files and class files
	map[str,set[loc]] projectDataMap = getProjectData(projectLocation);
	//printProjectData(projectDataMap);
	
	set[loc] folders = projectDataMap["folders"];
	
	
	
	//for each folder, createAstFromDirectory to have set of containing class files (or compilationUnits)
	//Maybe check if folder contains source files,..?
	//println(project.name);
	
	//for(folder <- project.folders){
	//	set[Declaration] directoryDeclarationSet = createAstsFromDirectory(folder, true);
	//}
	
	//set[loc] sourceFiles = projectDataMap["sourceFiles"];
	
	
	
	//Class file data: contains sourceFileLocation -> ("methods | fields | packages | .." -> set of loc of occurrences)
	//map[loc,map[str,set[loc]]] sourceFilesDataMap = getsourceFilesData(projectDataMap["sourceFiles"]);
	//printsourceFilesData(sourceFilesDataMap);
	
	
	// ---- 
	// projectM3Ast(projectLocation); //See comment in method projectM3Ast
	// fileAst(getOneFrom(projectDataMap["sourceFiles"]));
	// folderAst(getOneFrom(projectDataMap["folders"]));
}


private set[Declaration] getMethodsData(set[loc] methodsList,M3 mo){
	set[Declaration] methodDeclarations = {}; // return value
	for(m <- methodsList){
		methodDeclarations += getMethodASTEclipse(m,model=mo);
	}
	return methodDeclarations;
}

private Declaration getMethodDataAst(loc methodLocation){
	return getMethodASTEclipse(methodLocation,model=m3Memo);
}

private map[str,set[loc]] getProjectData(loc projectLocation){
	map[str,set[loc]] projectEntityMap; // return value
	Resource projectResource = getProject(projectLocation);
	
	//Project folders (not packages?!)
	set[loc] folders = getProjectFolders(projectResource);
	
	//Project files (total)
	set[loc] files = getProjectFiles(projectResource);	
	
	//Project Class files. With each file possible to call getsourceFileData to receive all important data from class file.
	set[loc] sourceFiles = getProjectsourceFiles(projectResource);
	
	projectEntityMap = ("folders" : folders) +("files" : files) +("sourceFiles" : sourceFiles);

	return projectEntityMap;	
}
//classname ,[categoryName(fields,methods,..),loc (occurrences]
private map[loc,map[str,set[loc]]] getsourceFilesData(set[loc] sourceFiles){
	map[loc,map[str,set[loc]]] sourceFilesDataMap = (); // Return value
	int i= 0;
	for(sourceFile <- sourceFiles){
		if(i<=2){
			sourceFilesDataMap += (sourceFile :getsourceFileData(sourceFile));
		}
		
		i+=1;
	}
	return sourceFilesDataMap;
}

@memo public map[loc,set[loc]] sourceLocMap(M3 m) = toMap(m@containment);
@memo public M3 m3Memo(M3 m) = m; 

//Returns map containing category (item name) and set of items that belong to that category
//Internally creates M3 AST and looks for "method, field, class,package,.." occurences (@containment used to lookup)
private map[str,set[loc]] getsourceFileData(loc projectLoc){
	M3 ast = createM3FromEclipseFile(projectLoc); 	
	M3 modu = m3Memo(ast);
	
	map[str,set[loc]] astEntityMap; // Return value. Maybe own data type (?) with getters and setters for each item (methods,fields,..)
	
	//Containment: contains items that are interesting to analyze 
	rel[loc from, loc to] containmentRelations = ast@containment; // containment contains class, method,field,variable,constructor name(s). modifier(?)-> name
	set[loc] containmentSet = carrier(containmentRelations); //Set of all name occurrences, no duplications (set of names)
	
	//Constructors
	set[loc] classConstructors = getNames(containmentSet,"java+constructor"); 
	
	//Methods
	set[loc] classMethodsSet = getNames(containmentSet,"java+method"); 
	
	//Class file's method data: using getMethodASTEclipse for each method location in each class file
	set[Declaration] methodDeclarations= getMethodsData(classMethodsSet,modu); 
	
	iprint(methodDeclarations);
	
	//Fields
	set[loc] classFields = getNames(containmentSet,"java+field");

	//CompilationUnit (absolute class file) // must (?!) be == 1 element!? 
	set[loc] classCompilationUnits = getNames(containmentSet,"java+compilationUnit");
	
	//Package
	set[loc] classPackages = getNames(containmentSet,"java+package");
	
	//Union of all sets from above
	astEntityMap = ("containments" : containmentSet) + ("constructors" : classConstructors) + ("methods" : classMethodsSet) 
				+ ("fields" : classFields) + ("compilationUnit" : classCompilationUnits) + ("packages" : classPackages); 
	
	return astEntityMap;
}

private set[loc] getNames(set[loc] locations, str namePattern){
	return {n | loc n <- locations, /^.*?<word:\w*><namePattern><rest:.*$>/:= toString(n)}; //Checks if location contains "java+method", which indicates a method(relation, see above)
} 


private set[loc] getProjectsourceFiles(Resource projectResource){
	set[loc] classesSet = {}; // return value
	visit(projectResource){			
		case file(loc fLoc) : { // Visit each file in Resource
			visit(fLoc.extension){ // Visit each file's extension
				case /^.*java+$/ : { // Java source file
					classesSet += fLoc;
			 	}
			};
		}
	};	
	return classesSet;
}


private set[loc] getProjectFolders(Resource projectResource){
	set[loc] folderSet = {}; // return value
	visit(projectResource){
		case folder(loc id, set[Resource] contents): {
			folderSet+= id;
		} 
	};	
	return folderSet;
}


private set[loc] getProjectFiles(Resource projectResource){
	set[loc] filesSet = {}; // return value
	visit(projectResource){
		case file(loc id): filesSet+= id; //case file(loc id): println("file:<id>");
	};
	return filesSet;
}

private void printProjectData(map[str,set[loc]] projectDataMap){
	println("-- Eclipse project data:");
	println("Folders: <size(projectDataMap["folders"])>");
	println("Total files: <size(projectDataMap["files"])>");
	println("Class files: <size(projectDataMap["sourceFiles"])>");
	println("--");
}

private void printsourceFilesData(map[loc,map[str,set[loc]]]  sourceFilesDataMap){
	for(classLoc <- [ k | k <- sourceFilesDataMap ]){
		println("-- Class file: <classLoc>");
		//class related data
		map[str,set[loc]] classData = sourceFilesDataMap[classLoc];
		println("containments: <size(classData["containments"])>");
		println("constructors: <size(classData["constructors"])>");
		println("methods: <size(classData["methods"])>");
		println("fields: <size(classData["fields"])>");
		println("compilationUnit: <size(classData["compilationUnit"])>");
		println("packages: <size(classData["packages"])>");
		println("--");
	}	
}

// ----- helper / print methods
private void fileAst(loc file){
	Declaration fileDeclaration = createAstFromFile(file, true);
	iprint(fileDeclaration);
}

private void folderAst(loc folder){
	set[Declaration] directoryDeclarationSet = createAstsFromDirectory(folder, true);
	println("directoryDeclarationSet size: <size(directoryDeclarationSet)>");
	iprint(directoryDeclarationSet);
}

private void projectM3Ast(loc projectLoc){
//M3 project AST contains annotations: extends, methodInvocation, methods,typeDependency, messages, containment, fieldAccess, names, implements
// documentation, uses, methodOverrides, modifiers, declarations
// Maybe good for complexity analysis. E.g.: Domain and range of maps can be used to see dependencies between classes.
	M3 projectM3Ast = createM3FromEclipseProject(projectLoc);
	iprint(projectM3Ast);
}



