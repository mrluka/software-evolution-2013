module Analyzer

import ProjectAnnotations;
import TreeProcessor;
import IO;
import util::Benchmark;
import duplicate::SetTheoryDuplication;
import complexity::ComplexityAnalyzer;
import Prelude;
        
//Analyzer is the starting point. It uses TreeProcessor to get the project tree, which is then used for further analysis with the help of TreeAnalyzer
public void analyzeProjects(){
	loc smallProjectLocation = |project://smallsql0.21_src/|;
	loc largeProjectLocation = |project://hsqldb-2.3.1/|;
	loc smallPreparedProjectLocation = |project://smallsql_prepared/|;
	
	//MAKE TREE 
	int starts = realTime();
	ProjectTree root = makeProjectTree(smallProjectLocation); 
	ProjectTree project = getOneFrom(root.projects);
	int stops  = realTime();
	println("Finished: Make Tree in: <stops-starts> ms");
	
	//DUPLICATION
	starts  = realTime();
	duplicationSetCheck(project);
	stops  = realTime();
	println("Finished: Duplication checks in: <stops-starts> ms");
	
	////COMPLEXITY
	starts  = realTime();
	compProject = getComplexityTree(project);
	stops = realTime();
	println("completed complexity analysis in: <stops-starts> ms");
	starts  = realTime();
	printRiskLevelOverview(compProject);
	stops = realTime();
	println("comleted risk level analysis in: <stops-starts> ms");
	
}

public void printToFile(value toPrint,bool saveToFile){
	if(saveToFile){
		iprintToFile(|file:///Volumes/Big/Uni/Master02/Software_Evolution/workspace/series1/output.txt|,toPrint);
	}else{
		iprintln(toPrint);
	}
}
		
