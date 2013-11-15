module TreeAnalyzer

import TreeProcessor;
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


//TreeAnalyzer uses a project tree for further analysis. 
//First step: is gathering information such as: units per file / folder, locode per unit / class file, etc.
//Second step: tba
              
// ------- -- - - - - - - -

//SOURCE FILE
anno int ProjectTree @length; //char count (?)
anno int ProjectTree @locode; 
anno int ProjectTree @units;
anno int ProjectTree @sources;
anno int ProjectTree @classes;


///CLASS
anno int ProjectTree @fields;
anno int ProjectTree @constructors;

//UNIT
anno int ProjectTree @params;


//Declaration annotations
anno int Declaration @unitsCount;
anno int Declaration @unitLineCount; // number of rows
anno int Declaration @unitLength; // number of letters

// ------- -- - - - - - - -


// TREE
public ProjectTree getCountedTree(ProjectTree project){
	return bottom-up visit(project){
		case ProjectTree f : folder(id, contents) :{
			//println("analyze folder: <id>");
			insert getAnalyzedFolder(f);
		}
	}
}

// FOLDER
private ProjectTree getAnalyzedFolder(ProjectTree folder){
	int sourceFiles = 0;
	int totalClasses = 0;
	
	ProjectTree analyzedFolder = bottom-up visit(folder){
		case ProjectTree f : folder(id, contents) :{
			if(sourceFiles>0){
				f@sources = sourceFiles;
				f@classes = totalClasses;
				insert f;
			}else{
				println("empty folder");
			}
		}
		case ProjectTree sf : sourceFile(id, Declaration declaration) :{
			int classes = 0;
			sourceFiles +=1;
			visit(declaration){
				//CLASS
				case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
					classes +=1;
				}
				//ANONYMOUS CLASS
				case cl : \class(list[Declaration] body):{
					classes +=1;
				}
			}
			totalClasses += classes;
			sf@classes = classes;
			insert sf;
		}
	};
	return analyzedFolder;
}










//-------------------- ANALYZE TREE


public ProjectTree computeQuantitativeInfo(ProjectTree project){
	return getAnalyzeProjectTree(project);
}



private ProjectTree getAnalyzeProjectTree(ProjectTree projectTree){
	int sfCount =0, foldersCount =0, unitsCount =0;
	return bottom-up visit(projectTree){
	//FOLDER
		case ProjectTree f : folder(id, contents) :{
			foldersCount+=1;
			f@sourceFileCount=sfCount; // source file count
			f@unitsCount = unitsCount; // unit count (per folder)
			sfCount = 0; 
			unitsCount = 0;
			insert f;//[@sourceFileCount=sfCount][@unitsCount = unitsCount];
		}

	//SOURCE FILE, includes METHOD		
		case ProjectTree sf : sourceFile(id, Declaration declaration) : { //sourceFile(loc id, Declaration declaration):{
			sfCount+=1;
			int mCount =0, impCount =0; // method count			
			declaration  = visit(declaration){ //update declaration with additional information
				case m:  \method( \return,  name, parameters,exceptions, Statement stat) : {
					int mlocode =m@src.end.line- m@src.begin.line;
					mCount+=1;
					unitsCount +=1;
					insert m[@unitLineCount=mlocode][@unitLength=m@src.length];
				}
				case m: \method( \return,  name, parameters,exceptions):{ // WHY & WHAT is the diff. between the 2 method cases
					int mlocode =m@src.end.line- m@src.begin.line;
					mCount+=1;
					unitsCount +=1;
					insert m[@unitLineCount=mlocode][@unitLength=m@src.length];
				}
				
				case \import(str name) :{
					impCount +=1;
				}
			};
			int sflocode = id.end.line - id.begin.line;
			ProjectTree analyzedSF =  sourceFile(id,declaration);
			analyzedSF@unitsCount = mCount; // unit count (per file)
			analyzedSF@length = id.length;  // file length
			analyzedSF@locode = sflocode;  // file locode
			analyzedSF@importCount = impCount;  // import count
			insert analyzedSF;
		}
	}
}
	//case c: \compilationUnit(list[Declaration] imports, list[Declaration] types): {
    //				println("compUnit1");
    //			}	
    //			
    //			case c: \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types): {
    //				println("compUnit2");
    //			}