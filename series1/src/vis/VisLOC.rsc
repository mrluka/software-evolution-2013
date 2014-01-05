module vis::VisLOC

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import IO;
import TreeProcessor;
import util::Resources;
import ProjectAnnotations;
import lang::java::m3::AST;
import util::Editors;

//public void visualizeIt(){
//	loc smallProjectLocation = |project://smallsql0.21_src/|;
//	loc smallPreparedProjectLocation = |project://smallsql_prepared/|;
//	Resource project = makeTree(smallPreparedProjectLocation);
// 	visualizeItLoc(project);
//}

public void visualizeItLoc(Resource project){
 int totalLoc = project@LOC;
 int onePerc = totalLoc / 100;
 println("vis total loc: <totalLoc>");
 list[Figure] classOutlines = [];
 visit(project){
 	case f:  file(id) : {
 		visit(f@declaration){
			//case c:  \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body): {
	 	//		classOutlines += createClassLOCOutline(c@src,c@LOC,onePerc); 
	 	//		//info(100,"a"), warning(125, "b"), highlight(190, "c")  
 		//	}
 		case c:  \compilationUnit(list[Declaration] imports, list[Declaration] types): {
	 			classOutlines += createClassLOCOutline(c@src,c@LOC,onePerc,f@duplicatedLines); 
 		}
 		case c:  \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types): {
	 			classOutlines += createClassLOCOutline(c@src,c@LOC,onePerc,f@duplicatedLines); 
 		}
 		}
 	}
 }
 render(hcat(classOutlines, [gap(5),ialign(0.0)])); //, justify(false)
}

private Figure createClassLOCOutline(loc fileLocation,int classLOC, int onePerc,list[int] duplicatedLines){
	int classSize = classLOC; 
	int duplicatedLinesCount = size(duplicatedLines);
	list[LineDecoration] hiLines = [];
	if(duplicatedLinesCount >= 6){
		int duplPer = duplicatedLinesCount / onePerc;
		hiLines = [highlight(l,"<l>a") | l <- duplicatedLines];
	}
 	return outline(hiLines, classSize, [size(10,classSize),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
		edit(fileLocation);
		return true;
	})]);
	
	// DYNAMIC SIZE TRY, okay, but duplication not done :) 
	//int classPer = classLOC/onePerc;
	//int classSize = onePerc * classPer;
	//int duplicatedLinesCount = size(duplicatedLines);
	//list[LineDecoration] hiLines = [];
	//if(duplicatedLinesCount >= 6){
	//	int duplPer = duplicatedLinesCount / onePerc;
	//	int duplSize = onePerc * duplPer;
	//	hiLines = [highlight(l,"<l>a") | l <- duplicatedLines];
	//}
 //	return outline(hiLines, 200, [size(20, classSize),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
	//println("ButtonNrPressed: <butnr> ..one: <onePerc> cLoc: <classLOC> filePer: <classPer> classSize: <classSize> duplicatedSize: <duplicatedLinesCount> file: <fileLocation>");
	//	edit(fileLocation);
	//	return true;
	//})]);
}
 	
 	