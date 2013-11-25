module count::LocCounter


import TreeProcessor;
import Analyzer;
import count::UnitCounter;
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

anno set[int] ProjectTree @linesSet;
anno int ProjectTree @LOC;

anno set[int] Declaration @linesSet;
anno int Declaration @LOC;

// Count LOC for each source file of project tree
public ProjectTree countLoc(ProjectTree project){
	println("\>counting LOC\<");
	return bottom-up visit(project) { // bottom up needed?!
		case ProjectTree sf: sourceFile(loc id, Declaration declaration):{
				set[int] relevantLineNumbers = regexCountTree(id);
				sf@linesSet = relevantLineNumbers;
				sf@LOC = size(relevantLineNumbers);
				sf.declaration = countUnitsLines(declaration);
				insert sf; 
		}
	}
}

private Declaration countUnitsLines(Declaration declaration){
	return visit(declaration){
		case Declaration m :\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{
			insert countMethodLOC(m);
		}
		case Declaration m : \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions):{
			insert countMethodLOC(m);
		}
	}
}

private Declaration countMethodLOC(Declaration method){
	list[str] fileLines = readFileLines(method@src);
	set[int] relevantLineNumbers = filterOutUnrelevantLines(fileLines);
	int methodBegin = method@src.begin.line;
	set[int] correctedIndexLineNumbers = {(n+methodBegin)-1 | int n <-  relevantLineNumbers};
	//by using readFileLines, we lose the actual line number. therefor add methodBeginLine number. 
	method@linesSet = correctedIndexLineNumbers; 
	method@LOC = size(correctedIndexLineNumbers);
	return method;
}


private set[int] regexCountTree(loc sourceFileLOC){
	list[str] fileLines = readFileLines(sourceFileLOC); //read file and get each line represented as str in list
	set[int] semanticalLines = filterOutUnrelevantLines(fileLines);  
	return semanticalLines; 
}

private set[int] filterOutUnrelevantLines(list[str] lines){ //such as whitespace, comments ,..
	bool isOpenComment = false; // true if multi-line comment tag was found. i.e.: if true, then is current line commented out
	set[int] relevantLines = {};
	int linePointer = 0;	
	for(line <- lines){
		linePointer += 1;
		if(isWhitespaceLine(line)){ //WHITESPACE  && ONE-LINE COMMENT
			continue; //if empty line or one line comment, skip.
		} 
		if(isOneLineComment(line)){
			continue;
		}
		if(isRelevantLine(line) ){ // Line starts NOT with comment tag
			if(!isOpenComment){
				relevantLines += linePointer; //add current line number to relevant line numbers. Not whitespace, not comment or part of comment
			} // do NOT continue, line could be relevant and have a comment tag somewhere
		}
		if(isCommentOpeningTag(line)){ // OPEN TAG -MULTI-LINE COMMENT 
			isOpenComment = true;
			continue;
		} 
		if(isCommentClosingTag(line)){ // CLOSING TAG - MULTI-LINE COMMENT
			isOpenComment = false; //reset tag indicator
			continue;
		}
	}
	return relevantLines;
}
		

// if does not start with comment trigger AND if not in multi-line comment opeing before
private bool isRelevantLine(str line){
	if( /^\s*\t*\w+.*$/s :=line){ // ws, tab, word ...
		return true;
	}
	if( /^.*\*\/.*w+/s :=line){ // ws, tab, /* comment */ word 
		return true;
	}
	if(/^\s*\t*}*\(*\)*\w+.*/s := line){
		return true;
	}
	if(!isWhitespaceLine(line) && !isOneLineComment(line) && ! isCommentOpeningTag(line) && !isMultiCommentLine(line)){
		return true;
	}
	return false;
}

private bool isWhitespaceLine(str line){
	if( /^\s*$/s :=line){ // ws
		return true;
	}
	return false;
}

private bool isOneLineComment(str line){
	if( /^\s*\t*\/\/.*$/s :=line){ // -> ws //comment ..
		return true;
	}
	if( /^\s*\t*\/\*.*\*\/\s*\t*$/s :=line){ // -> /* .. */ 
		return true;
	}
	return false;	
}

private bool isCommentOpeningTag(str line){
	 if( /^\s*\t*\/\*.*$/s :=line){ // ws, tab, /* ..
		return true;
	}
	return false;
}

private bool isMultiCommentLine(str line){
	 if(/^\s*\*.*$/s :=line){ // ws * ...
		return true;
	}
	return false;
}

private bool isCommentClosingTag(str line){
	if( /^.*\*\/\s*\t*$/s :=line){
		return true;
	}
	return false;
}

//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- PRINT: LOC - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - --------- 
public void printLOCInfo(ProjectTree project){ // STEP 2
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
