module count::UnitCounter


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
anno int ProjectTree @sourcesCount;
anno int ProjectTree @classesCount;
anno int ProjectTree @unitsCount;
anno int ProjectTree @importsCount;


public ProjectTree countProjectElements(ProjectTree project){
	println("counting project\'s physical data");
	return countContent(project);
}

private ProjectTree countContent(ProjectTree projectTree){
	int folderUnitsCount =0, folderClassesCount = 0, totalSFCount =0;	
	return bottom-up visit(projectTree){
	
		case ProjectTree r : root(set[ProjectTree] projects):{ // ROOT
			r@classesCount = totalSFCount;
			insert r;
		}
		
		case ProjectTree p : project(loc id,str name, set[ProjectTree] contents):{ // PROJECT
			p@sourcesCount = totalSFCount;
			insert p;
		}
		
		case ProjectTree f : folder(id, contents) :{ //FOLDER: sourcesCount, unitsCount, classesCount
			set[ProjectTree] sourceFiles = {};  
			for(sFile <- contents){
				ProjectTree countedSourceFile = countSourceFileElements(sFile); 
				sourceFiles += countedSourceFile;
				folderUnitsCount += countedSourceFile@unitsCount;
			
			}
			int folderSFCount = size(id.ls); 
			totalSFCount += folderSFCount;
			f@sourcesCount=folderSFCount; // source files per folder
			f@unitsCount = folderUnitsCount; // unit count per folder
			f@classesCount = folderClassesCount; // classes count per folder
			f.contents = sourceFiles;			
			folderUnitsCount = 0;
			folderClassesCount = 0;
			insert f;
		}
	}
}

private ProjectTree countSourceFileElements(ProjectTree sourceFile){
	int methCount =0;// method / unit count per source file
	int importCount =0; //imports count per source file
	int classesCount = 0; // classes count per source file
	
	visit(sourceFile){ //visit each source files method(unit), import and class. 
		case m:  \method( \return,  name, parameters,exceptions, Statement stat) : { //METHOD(unit)
		methCount+=1;
		insert m;
		}
				
		case m: \method( \return,  name, parameters,exceptions):{ //METHOD(unit)
			methCount+=1;
			insert m; 
		}
				
		case \import(str name) :{ // IMPORT
			importCount +=1;
		}
					
		case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{ //CLASS
			classesCount +=1; //TODO: check unit count per class, also?
		}
					
		case cl : \class(list[Declaration] body):{ //CLASS (ANONYMOUS)
			classesCount +=1;
		}
	};
			
	sourceFile@unitsCount = methCount; // unit count (per file)
	sourceFile@importsCount = importCount;  // import count
	sourceFile@classesCount = classesCount;
	return sourceFile;
}
