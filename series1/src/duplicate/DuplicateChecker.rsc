module duplicate::DuplicateChecker

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


public void checkDuplication(ProjectTree project){
	// put all hashes into set(?) and check afterwards that set size increased, if not, then there is a duplication ! 
	
}