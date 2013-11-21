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
	println("counting LOC");
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
	int lineCounter = 0;	
	for(line <- lines){
		lineCounter += 1;
		//WHITESPACE  && ONE-LINE COMMENT
		if(isWhitespaceLine(line) || isOneLineComment(line)){
			continue; //if empty line or one line comment, skip.
		} 
		//INLINE COMMENT
		if(hasInlineComment(line)){ // Extra check for inline comments, such as /*comment*/
			relevantLines += lineCounter;
			continue;
		}
		//MULTI-LINE COMMENT - OPEN TAG
		if(isCommentOpeningTag(line)){ //if opening tag for multi-line comment was found 
			isOpenComment = true;
		} 
		//MULTI-LINE COMMENT - CLOSING TAG
		else if(isCommentClosingTag(line)){ //if closing tag for multi-line comment was found
			if(!isOpenComment){
				println("!!!closing without previous opening: <line>"); //if closing tag without previous opening tag was found
			}
			isOpenComment = false; //reset tag indicator
		}
		//MULTI-LINE COMMENT - LINE (entity of the multi-line comment)
		else if(isMultiCommentLine(line)){
			if(!isOpenComment){
				println("!!!closing without previous opening: <line>"); //if closing tag without previous opening tag was found
			}
		}
		
		else{
			if(isOpenComment){ //if there was a multi-line comment start tag, it's following lines must be comments aswell 
								// until closing tag occurs. So skip this line, it is part of multi-line comment
				continue;
			}			
			relevantLines += lineCounter; //add current line number to relevant line numbers. Not whitespace, not comment or part of comment
		}
	}
	return relevantLines;
}

private bool hasInlineComment(str line){
	if( /^\s*\t*\w+.*\/\*.*\*\/$/s :=line){ // ws, tab, word /* ... */ 
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
	if( /^\s*\/\/.*$/s :=line){ // -> ws //comment ..
		return true;
	}
	if( /^\s*\t*\/\*.*\*\/\s*\t*$/s :=line){ // -> /** .. */ ..
		return true;
	}
	
	return false;	
}

private bool isCommentOpeningTag(str line){
	 if( /^\s*\t*\/\*?(\*).*$/s :=line){ // ws, tab, /* ..
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

//public void ad(){
////|project://smallsql0.21_src/src/smallsql/database/Database.java|(10799,260,<309,1>,<313,2>)
//list[str] fileLines = readFileLines(|project://smallsql0.21_src/src/smallsql/database/Database.java|(10799,260,<309,1>,<313,2>)); //read file and get each line represented as str in list
//println(fileLines);
//}