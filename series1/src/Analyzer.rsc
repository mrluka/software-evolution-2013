module Analyzer

import ProjectAnnotations;
import TreeProcessor;
import IO;
import util::Benchmark;
import duplicate::SetTheoryDuplication;
import complexity::ComplexityAnalyzer;
import visualisation::Manager;
import Prelude;
import sig::Rating;
        
//Analyzer is the starting point. It uses TreeProcessor to get the project tree, which is then used for further analysis with the help of TreeAnalyzer
public void analyzeProjects(){
	loc smallProjectLocation = |project://smallsql0.21_src/|;
	loc largeProjectLocation = |project://hsqldb-2.3.1/|;
	loc smallPreparedProjectLocation = |project://JavaExample/|;
	
	//MAKE TREE 
	int starts = realTime();
	ProjectTree root = makeProjectTree(smallPreparedProjectLocation); 
	ProjectTree project = getOneFrom(root.projects);
	int stops  = realTime();
	println("Finished: Make Tree in: <stops-starts> ms");
	
	//DUPLICATION
    starts  = realTime();
    duplication = 0;
   // duplication = duplicationSetCheck(project);
    stops  = realTime();
    println("Finished: Duplication checks in: <stops-starts> ms");
    
    ////COMPLEXITY
    starts  = realTime();
    compProject = getComplexityTree(project);
    stops = realTime();
    println("completed complexity analysis in: <stops-starts> ms");
    starts  = realTime();
    rating_complexity = printRiskLevelOverview(compProject);
    stops = realTime();
    println("comleted risk level analysis in: <stops-starts> ms");
            
  	////RATING VOLUME
	rating_loc = printLocRating(compProject@LOC);
	
	////RATING UNIT SIZE
	rating_avg_loc = printAverageUnitLocRating(compProject);
	
	////RATING DUPLICATION (should be percentage between 0 and 100)
	rating_duplication = getDuplicationRating(duplication);
	 
	showBlocks(compProject);
	
	printOverview(rating_loc,rating_complexity,rating_duplication,rating_avg_loc);
}

public void printToFile(value toPrint,bool saveToFile){
	if(saveToFile){
		iprintToFile(|file:///Volumes/Big/Uni/Master02/Software_Evolution/workspace/series1/output.txt|,toPrint);
	}else{
		iprintln(toPrint);
	}
}
		
