module Analyzer


import TreeProcessor;
import count::LocCounter;
import count::UnitCounter;
import duplicate::DuplicationHasher;
import duplicate::DuplicateChecker;
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
import util::Benchmark;

//Analyzer is the starting point. It uses TreeProcessor to get the project tree, which is then used for further analysis with the help of TreeAnalyzer

public void analyzeProjects(){
	loc smallProjectLocation = |project://smallsql0.21_src/|;
	loc largeProjectLocation = |project://smallsql0.21_src/|;
	
	//MAKE TREE 
	int starts = realTime();
	ProjectTree project = makeProjectTree(smallProjectLocation);
	int stops  = realTime();
	println("completed making tree in: <stops-starts> ms");
	
	//COUNT
	starts  = realTime();
	ProjectTree countedTree = countProjectElements(project);
	stops  = realTime();
	println("completed counting project elements in: <stops-starts> ms");
	 	
	//LOC
	starts  = realTime(); // inline-comment text
						// opening tag & inline comment 
						// LOC pro folder, 
						// packes & folder
						// LOC pro project
						// Duplication between projects,...only one interesting for multiple projects
						// Units per Class 
						// Inner classes on wrong class,...
	ProjectTree locProject = countLoc(countedTree);
	stops  = realTime();
	println("completed counting LOCs in: <stops-starts> ms");
	
	//DUPLICATION
	//ProjectTree line2HashMapTree  = makeLine2HashMaps(locProject);
	//checkDuplication(line2HashMapTree);
	 
	//PRINT
	printProjectInformation(locProject);
	
}
private void printProjectInformation(ProjectTree project){
	printCountedTreeInfo(project);
	printLOCInfo(project);
	//writeFile(|project://series1/src/testOutput.txt|,project);
	//iprintToFile(|project://series1/src/testOutput1.txt|,project);
}

//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- COUNT UNITS, IMPORTS,..  - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
private void printCountedTreeInfo(ProjectTree project){ //STEP 1
	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - -- - - - - --- -- - -- - -- - - - - --- -- - -- - --|");
	println("|	PRINTING number if sourc files, classes, imports, units, ..");
	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
	
	top-down visit(project){
		case ProjectTree r: root(set[ProjectTree] projects):{
			println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
			println("|ROOT (projects:<size(projects)>)                    ");
			println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
		}
		case ProjectTree p : project(loc id,str name, set[ProjectTree] contents): {
			println("|------ ------ ------ - - - - --- - --- -- - -- --- --|");
			println("|  PROJECT <name> with <p@sourcesCount> source files   ");
			println("|------ ------ ------ - - - - --- - --- -- - -- - ----|");
			//println("Project location: <id> ");
		}
		
		case ProjectTree f: folder(id,contents):{
			println("|------ ------ ------ - - - - - - -- - - - -- - --|");
			println("|    FOLDER <id.path> with <f@sourcesCount> file(s)");
			println("|------ ------ ------ - - - - - - -- - -- - -- - -|");
			printCountedSourceFiles(f);
		}
	}
}

private void printCountedSourceFiles(ProjectTree project){
	visit(project){
		case ProjectTree sf: sourceFile(loc id, Declaration declaration):{
			println("|------ ------ ------ - - --|");
			println("|       SOURCE FILE         |");
			println("|------ ------ ------ - - --|");
			println("File location: <id>");
			println("Classes: <sf@classesCount>");
			println("Units: <sf@unitsCount>");
			println("Imports: <sf@importsCount>");
		}
	}
}

//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- LOC - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - --------- 
private void printLOCInfo(ProjectTree project){ // STEP 2
	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - -- - - - - --- -- - -- - -- - - - - --- -- - -- - --|");
	println("|	PRINTING Lines Of Code..");
	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
	
	bottom-up visit(project){
		case ProjectTree sf: sourceFile( id,  declaration):{
			println("|------ ------ ------ - - --|");
			println("|       SOURCE FILE         |");
			println("|------ ------ ------ - - --|");
			println("Source file: <id>");
			println("LOC:<sf@LOC>");
			println("Lines count:<sf@linesSet> ");
			//println("units:<sf@unitsCount> ");
			printDeclarationInfo(declaration);
		}
		
	}
}//-
//---------------------CONNECTED---------------------// 
private void printDeclarationInfo(Declaration decl){// 
	visit(decl){
		case Declaration m :\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{
			printMethodInfo(m);
		}
		
		case Declaration m : \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions):{
			printMethodInfo(m);
		}
	}
}//-
//---------------------CONNECTED------------------// 
private void printMethodInfo(Declaration method){//
	println("|------ - - - --|");
	println("|         METHOD|");
	println("|------ - - - --|");
	println("Method: <method@src> ");
	println("MethLOC: <method@LOC> ");
	println("MethLines:<sort(toList(method@linesSet))> "); //CAUTION, sort is slow !!!!!!!!!!!!!!
}










