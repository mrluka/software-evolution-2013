module count::LocCounter

import Prelude;
import ProjectAnnotations;
import IO;
import Node;
import lang::java::m3::AST;
import List;
import util::Resources;


public Resource getLocCountedSourceFile(Resource sourceFile){ 
	list[str] relevantLines = removeUnrelevantLines(sourceFile@fileLines); //getSourceLocInfo(sourceFile@fileLines);
	sourceFile@LOC = size(relevantLines);
	sourceFile@fileLines = relevantLines;
	
	Declaration decl=  visit(sourceFile@declaration){
		case Statement block : \block(list[Statement] statements):{ // block
			block@LOC = calculateLOC(block@src); //size(getSpecificLineNrs(block@src,sourceFile@fileLines)); 
			insert block;
		}
		case Declaration declaration: { // method, constructor, etc.
			if("src" in getAnnotations(declaration)){  //check if declaration has annotation @src
				declaration@LOC = calculateLOC(declaration@src);//size(getSpecificLineNrs(declaration@src,sourceFile@fileLines)); 
				insert declaration;
			}
		}
		//TODO: CLASS LOC 
	};
	sourceFile@declaration = decl;
	return sourceFile;
	}
	
	private int calculateLOC(loc location){
		return location.end.line - location.begin.line;
	}
	

private list[str] getSourceLocInfo(list[str] fileLines){
	list[str] lines = removeUnrelevantLines(fileLines);
	return lines;
}

public list[str] removeUnrelevantLines(list[str] lines){
	list[str] cleanedList = [];
	bool isOpenComment = false; // true if multi-line comment tag was found. i.e.: if true, then is current line commented out
	int linePointer = 0;	
	
	for(line <- lines){
		if(isWhitespaceLine(line) || isOneLineComment(line)){
			continue;
		}
		if(!isOpenComment && ((/^\s*\w+/s  := line) || (/^\s*\{|\}\s*/s  :=  line))){
			cleanedList += cleanUpLine(line);
			continue;
		}
		
		if(isMultiCommentOpen(line)){
			isOpenComment = true;
			if(isCommentClosingTag(line)){
				isOpenComment = false;
		}
			continue;
		} 
		
		if(isCommentClosingTag(line)){ // CLOSING TAG - MULTI-LINE COMMENT
			isOpenComment = false; //reset tag indicator
			continue;
		}
		if(!isOpenComment && isContentLine(line)){ 
			cleanedList += cleanUpLine(line);
			continue;
		}
	}
	return cleanedList;
}

public list[int] getSpecificLineNrs(loc location,list[str] fileLines){ //TODO
	//println("fileLines: <size(fileLines)>  location: <location>");
	list[int] lineNrs = computeRelevantLineNrs(slice(fileLines,location.begin.line-1,(location.end.line-location.begin.line)));
	return lineNrs;
}

private list[int] computeRelevantLineNrs(list[str] lines){
	bool isOpenComment = false; 
	int linePointer = 0;	
	list[int] lineNrs = [];
	
	for(line <- lines){
		linePointer += 1;
		if(isWhitespaceLine(line) || isOneLineComment(line)){
			continue;
		}
		if(!isOpenComment && ((/^\s*\w+/s  := line) || (/^\s*\{|\}\s*/s  :=  line))){
			lineNrs += linePointer;
			continue;
		}
		
		if(isMultiCommentOpen(line)){
			isOpenComment = true;
			if(isCommentClosingTag(line)){
				isOpenComment = false;
		}
			continue;
		} 
		
		if(isCommentClosingTag(line)){ // CLOSING TAG - MULTI-LINE COMMENT
			isOpenComment = false; //reset tag indicator
			continue;
		}
		if(!isOpenComment && isContentLine(line)){ 
			lineNrs += linePointer;
			continue;
		}
		
	}
	return lineNrs;
}

public bool isContentLine(str line){
	return ((/^.*\w+$/s := line) && !( /^.*\/\/.*/s := line) && ((/^\s*(\w+|\W+).*$/s := line)) && !( /^.*\/\/.*/s := line));
}

public bool isWhitespaceLine(str line){
	return ( /^\s*$/s :=line); // ws
}

public bool isMultiCommentOpen(str line){
	return (/^\s*(\/\*)+.*$/s :=line);
}
public bool isOneLineComment(str line){
	return (/^\s*<indi:(\/\/)+.*>/s :=line);
}

public bool isMultiCommentLine(str line){
	return (/^\s*\*.*$/s :=line); 
}

public bool isCommentClosingTag(str line){
	return (/^.*\*\/\s*$/s :=line);
}

public str cleanUpLine(str line){  // remove whitespaces and tabs
	str noSpacesLine = replaceAll(line," ","");
	str noTabsLine = replaceAll(noSpacesLine,"	","");
	return noTabsLine;
}

//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- PRINT: LOC - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - --------- 
//public void printLOCInfo(ProjectTree project){ // STEP 2
//	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - -- - - - - --- -- - -- - -- - - - - --- -- - -- - --|");
//	println("|	PRINTING Lines Of Code..");
//	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
//	
//	bottom-up visit(project){
//		case ProjectTree sf: sourceFile( id,  declaration):{
//			println("|------ ------ ------ - - --|");
//			println("|       SOURCE FILE         |");
//			println("|------ ------ ------ - - --|");
//			println("Source file: <id>");
//			println("LOC:<sf@LOC>");
//			println("Lines count:<sf@linesList> ");
//			printDeclarationInfo(declaration);
//		}
//		
//	}
//}//-
////---------------------CONNECTED---------------------// 
//private void printDeclarationInfo(Declaration decl){// 
//	visit(decl){
//		case Declaration m :\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{
//			printMethodInfo(m);
//			printStatementInfo(impl);
//		}
//		
//		case Declaration m : \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions):{
//			printMethodInfo(m);
//		}
//	}
//}//-
////---------------------CONNECTED------------------// 
//private void printMethodInfo(Declaration method){//
//	println("|------ - - - --|");
//	println("|         METHOD|");
//	println("|------ - - - --|");
//	println("Method: <method@src> ");
//	println("MethLOC: <method@LOC> ");
//	println("MethLines:<method@linesList> "); //CAUTION, sort is slow !!!!!!!!!!!!!!
//}//-
////---------------------CONNECTED------------------// 
//private void printStatementInfo(Statement block){//
//	println("|- - - - --|");
//	println("|     Block|");
//	println("|- - - - --|");
//	println("Block: <block@src> ");
//	println("BlockLOC: <block@LOC> ");
//	println("BlockLines:<block@linesList> "); //CAUTION, sort is slow !!!!!!!!!!!!!!
//}
