module duplicate::DuplicationHasher


import Analyzer;
import TreeProcessor;
import count::LocCounter;
import count::UnitCounter;
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

anno map[int,str] ProjectTree @lines2hashes; //map line number 

public void check(){ // Only for testing
	loc a = |project://smallsql0.21_src/src/smallsql/database/Database.java|(10799,260,<309,1>,<313,2>);
	loc b = |project://smallsql0.21_src/src/smallsql/database/Database.java|(0,19620,<1,0>,<546,1>);
	println(md5HashFile(a));
	println(md5HashFile(b));
}

public ProjectTree makeLine2HashMaps(ProjectTree project){
	return visit(project){
		case ProjectTree sf : sourceFile(loc id, Declaration declaration):{
			if(sf@LOC >=6){
				map[int,str] linesHashMap =  hashSourceFileLines(sf); //get map of line number to hash
				sf@lines2hashes = linesHashMap;
				insert sf; 
			}
		}
	}
}

private map[int,str] hashSourceFileLines(ProjectTree sourceFile){
	set[int] fileLines = sourceFile@linesSet;
	map[int,str] line2Hash = ();
	
	list[str] fileLines = readFileLines(sf@src);
	for(line <-m@linesSet){
		str lineHash = hashLine(fileLines[line]); //get Hash of (normalized) line
		line2Hash += (line : lineHash); // map line to hash.
	}
	
	return line2Hash;
}

private str hashLine(str line){
 	str normalizedLine = normalizeLine(line);
 	// TODO: hash 
	return md5HashFile(file);
}

private str normalizeLine(str line){ // allow single whitespaces 
	//TODO: remove whitespaces (?), tabs, all to lower case
	return "";
}