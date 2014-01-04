module Analyzer

import ProjectAnnotations;
import TreeProcessor;
import IO;
import util::Benchmark;
import util::Resources;
import complexity::ComplexityAnalyzer;
import Prelude;
import sig::rating;



//Analyzer is the starting point. It uses TreeProcessor to get the project tree, which is then used for further analysis with the help of TreeAnalyzer
public void analyzeProjects(){
	loc smallProjectLocation = |project://smallsql0.21_src/|;
	loc largeProjectLocation = |project://hsqldb-2.3.1/|;
	loc smallPreparedProjectLocation = |project://smallsql_prepared/|;
	
	//MAKE TREE 
	int starts = realTime();
	Resource project = makeTree(smallProjectLocation); 
	int stops  = realTime();
	println("Finished: Make Tree in: <stops-starts> ms");
	println("TOTAL loc: <project@LOC>");
	
	//////COMPLEXITY
	starts  = realTime();
	project =  getComplexityTree(project);
	stops = realTime();
	println("completed complexity analysis in: <stops-starts> ms");
	starts  = realTime();
	rating_complexity = printRiskLevelOverview(project);
	stops = realTime();
	println("comleted risk level analysis in: <stops-starts> ms");
	
	// ---------------OLD  ---------------  --------------- --------------- --------------- 
	//MAKE TREE 
//	int starts = realTime();
//	ProjectTree root = makeProjectTree(smallPreparedProjectLocation); 
//	ProjectTree project = getOneFrom(root.projects);
//	int stops  = realTime();
//	println("Finished: Make Tree in: <stops-starts> ms");
//
//	println("TOTAL loc: <project@LOC>");	
	////DUPLICATION
	//starts  = realTime();
	//project = duplicationSetCheck(project);
	//stops  = realTime();
	//println("Finished: Duplication checks in: <stops-starts> ms");
	//
	//////COMPLEXITY
	//starts  = realTime();
	//project = getComplexityTree(project);
	//stops = realTime();
	//println("completed complexity analysis in: <stops-starts> ms");
	//starts  = realTime();
	//rating_complexity = printRiskLevelOverview(project);
	//stops = realTime();
	//println("comleted risk level analysis in: <stops-starts> ms");
	//
	//////RATING VOLUME
	// rating_loc = getLocRating(project);
	// 
	// ////RATING UNIT SIZE
	// rating_avg_loc = getAvgLocRating(project);
	 
	 //DUPLICATION
	 //ProjectTree line2HashMapTree  = makeLine2HashMaps(locProject);
	 //checkDuplication(line2HashMapTree);
	 
	 ////RATING DUPLICATION (should be percentage between 0 and 100)
	//int locVolume =  project@LOC;
	//int duplicatedLineCount = project@duplicationLineCount;
	//int avgUnitSize = 19;
	//real duplication = duplicatedLineCount / (locVolume / 100.0);
	//rating_duplication = getDuplicationRating(duplication);
	//printOverview(rating_loc,rating_complexity,rating_duplication,rating_avg_loc);
	
}

public void printToFile(value toPrint,bool saveToFile){
	if(saveToFile){
		iprintToFile(|file:///Volumes/Big/Uni/Master02/Software_Evolution/workspace/series1/output.txt|,toPrint);
	}else{
		iprintln(toPrint);
	}
}
		
