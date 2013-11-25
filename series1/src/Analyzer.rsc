module Analyzer


import TreeProcessor;
import count::LocCounter;
import count::UnitCounter;
import complexity::ComplexityAnalyzer;
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
	
	////COMPLEXITY
	starts  = realTime();
	compProject = getComplexityTree(locProject);
	stops = realTime();
	println("completed complexity analysis in: <stops-starts> ms");
	starts  = realTime();
	printRiskLevelOverview(compProject);
	stops = realTime();
	println("comleted risk level analysis in: <stops-starts> ms");
	
	//DUPLICATION
	//ProjectTree line2HashMapTree  = makeLine2HashMaps(locProject);
	//checkDuplication(line2HashMapTree);
	 
	//PRINT
	printProjectInformation(locProject);	
}


private void printProjectInformation(ProjectTree project){
	//printCountedTreeInfo(project);
	printLOCInfo(project);
	//writeFile(|project://series1/src/testOutput.txt|,project);
	//iprintToFile(|project://series1/src/testOutput1.txt|,project);
}





