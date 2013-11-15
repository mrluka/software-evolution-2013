module Analyzer


import TreeProcessor;
import TreeAnalyzer;
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

//Analyzer is the starting point. It uses TreeProcessor to get the project tree, which is then used for further analysis with the help of TreeAnalyzer

public void analyzeProjects(){
	loc smallProjectLocation = |project://smallsql0.21_src/|;
	//Create Project Tree
	ProjectTree project = createProjectTree(smallProjectLocation);
	//iprint(project);
	// First analysis: compute quantities, e.g.: unit count, unit lines, class files count,..
	//ProjectTree firstStepProject = computeQuantitativeInfo(project);
	ProjectTree firstStepProject = getCountedTree(project);
	iprint(firstStepProject);
	//iprint(firstStepProject);
	//printFirstProjectInfo(firstStepProject);
}

private void printFirstProjectInfo(ProjectTree firstStepProject){

	visit(firstStepProject){
		case ProjectTree p : project(loc id, set[Resource] contents):{
			println("project");
		}
		case ProjectTree f: folder(id,contents):{
			println("folder: <id>");
			println("units:<f@unitsCount> ");
		}
		case ProjectTree f: file(loc id):{
			println("file");
		}
		case ProjectTree sf: sourceFile(loc id, Declaration declaration):{
			println("sourceFile units:<sf@unitsCount>");
		}
		
	}

}