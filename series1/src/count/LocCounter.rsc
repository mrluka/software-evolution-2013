module count::LocCounter

import Prelude;
import ProjectAnnotations;
import IO;
import Node;
import lang::java::m3::AST;
import List;
import util::Resources;


public ProjectTree getLocCountedSourceFile(ProjectTree sourceFile){
	return visit(sourceFile) { 
		case ProjectTree sf: sourceFile(loc id, Declaration declaration):{ // source file
			
			list[str] relevantLines = getSourceLocInfo(sourceFile@fileLines);
			sf@LOC = size(relevantLines);
			sf@fileLines = relevantLines;
			sf = visit(sf){
				case Statement block : \block(list[Statement] statements):{ // block
					block@LOC = size(getSpecificLineNrs(block@src,sourceFile@fileLines)); 
					insert block;
				}
				case Declaration declaration: { // method, constructor, etc.
					if("src" in getAnnotations(declaration)){  //check if declaration has annotation @src
						declaration@LOC = size(getSpecificLineNrs(declaration@src,sourceFile@fileLines)); 
						insert declaration;
					}
				}
			}
			insert sf;
		}
	}
}

public int getProjectLOC(list[ProjectTree] files){
	int completeLoc = 0;
	for(file <- files){
		completeLoc += file@LOC;
	}
	return completeLoc;
}

private list[str] getSourceLocInfo(list[str] fileLines){
	list[str] lines =removeUnrelevantLines(fileLines);
	return lines;
}

private list[str] removeUnrelevantLines(list[str] lines){
	list[str] cleanedList = [];
	bool isOpenComment = false; // true if multi-line comment tag was found. i.e.: if true, then is current line commented out
	int linePointer = 0;	
	
	for(line <- lines){
		linePointer += 1;
		
		//if(/^\s*\t*}+$/s := line){ // } //TODO: maybe disable for "real" result
		//	continue;
		//}
		
		if(isWhitespaceLine(line) || isOneLineComment(line)){ //WHITESPACE  && ONE-LINE COMMENT
			continue;
		} 
		
		if(isCommentOpeningTag(line)){ // OPEN TAG -MULTI-LINE COMMENT 
			isOpenComment = true;
			continue;
		} 
		
		if(isCommentClosingTag(line)){ // CLOSING TAG - MULTI-LINE COMMENT
			isOpenComment = false; //reset tag indicator
			continue;
		}
		
		if(!isOpenComment ){ // Line starts NOT with comment tag // && isRelevantLine(line)
			//if(/^\s*\t*}+$/s := line){
			//	lineNrs += -1;
			//}
			//else{
			cleanedList += cleanUpLine(line);
			//}
			continue;
		}
	}
	return cleanedList;
}

private list[int] getSpecificLineNrs(loc location,list[str] fileLines){ //TODO
	list[int] lineNrs = computeRelevantLineNrs(slice(fileLines,location.begin.line-1,(location.end.line-location.begin.line)));
	return lineNrs;
}

private  map[int,str] filterOutUnrelevantLines(list[str] lines){ //such as whitespace, comments ,..
	list[int] relevantLineNrs = computeRelevantLineNrs(lines);
	map[int,str] relevantNrs2Lines = (lineNr : cleanUpLine(lines[lineNr-1]) | int lineNr <-relevantLineNrs); // return value
	return relevantNrs2Lines;
}


private list[int] computeRelevantLineNrs(list[str] lines){
	bool isOpenComment = false; // true if multi-line comment tag was found. i.e.: if true, then is current line commented out
	int linePointer = 0;	
	list[int] lineNrs = [];
	
	for(line <- lines){
		linePointer += 1;
		
		//if(/^\s*\t*}+$/s := line){ // } //TODO: maybe disable for "real" result
		//	continue;
		//}
		
		if(isWhitespaceLine(line) || isOneLineComment(line)){ //WHITESPACE  && ONE-LINE COMMENT
			continue;
		} 
		
		if(isCommentOpeningTag(line)){ // OPEN TAG -MULTI-LINE COMMENT 
			isOpenComment = true;
			continue;
		} 
		
		if(isCommentClosingTag(line)){ // CLOSING TAG - MULTI-LINE COMMENT
			isOpenComment = false; //reset tag indicator
			continue;
		}
		
		if(!isOpenComment ){ // Line starts NOT with comment tag // && isRelevantLine(line)
			//if(/^\s*\t*}+$/s := line){
			//	lineNrs += -1;
			//}
			//else{
				lineNrs += linePointer;
			//}
			continue;
		}
	}
	return lineNrs;
}

private bool isWhitespaceLine(str line){
	return ( /^\s*$/s :=line); // ws
}

private bool isOneLineComment(str line){
	return ( /^\s*\t*\/\/.*/s :=line) || ( /^\s*\t*\/\*.*\*\/\s*\t*$/s :=line);   
}

private bool isCommentOpeningTag(str line){
	return ( /^\s*\t*\/\*.*$/s :=line); 
}

private bool isMultiCommentLine(str line){
	return (/^\s*\*.*$/s :=line); 
}

private bool isCommentClosingTag(str line){
	return ( /^.*\*\/\s*\t*\W*$/s :=line);
}

private str cleanUpLine(str line){  // remove whitespaces and tabs
	str noSpacesLine = replaceAll(line," ","");
	str noTabsLine = replaceAll(noSpacesLine,"	","");
	return noTabsLine;
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
			println("Lines count:<sf@linesList> ");
			printDeclarationInfo(declaration);
		}
		
	}
}//-
//---------------------CONNECTED---------------------// 
private void printDeclarationInfo(Declaration decl){// 
	visit(decl){
		case Declaration m :\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{
			printMethodInfo(m);
			printStatementInfo(impl);
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
	println("MethLines:<method@linesList> "); //CAUTION, sort is slow !!!!!!!!!!!!!!
}//-
//---------------------CONNECTED------------------// 
private void printStatementInfo(Statement block){//
	println("|- - - - --|");
	println("|     Block|");
	println("|- - - - --|");
	println("Block: <block@src> ");
	println("BlockLOC: <block@LOC> ");
	println("BlockLines:<block@linesList> "); //CAUTION, sort is slow !!!!!!!!!!!!!!
}
