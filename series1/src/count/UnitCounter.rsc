module count::UnitCounter

import ProjectAnnotations;
import TreeProcessor;
import Prelude;
import util::Resources;
import IO;
import List;
import lang::java::m3::AST;


public ProjectTree countSourceFileElements(ProjectTree sourceFile){
	int methCount =0;// method / unit count per source file
	int importCount =0; //imports count per source file
	int classesCount = 0; // classes count per source file

	//lrel[Declaration file,list[Declaration]imports,list[Declaration] types] fileEntities = [<sf,[fileImports],types> | Declaration sf <- sourceFile, fileImports <-sf.imports,types <- sf.types,\compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types):=sf];
	list[Declaration] imports = [ imp | Declaration sf <- sourceFile , \compilationUnit :=sf, imp <- sf.imports];
	//int importsCount = size(imports);
	
	list[Declaration] types = [ typ | Declaration sf <- sourceFile , \compilationUnit :=sf, typ <- sf.types]; //,bprintln(typ)
	//lrel[list[Declaration] methods,list[Declaration] constructors,list[Declaration] fields] 
	list[Declaration] methods =  [m | meth <-types, Declaration m: /method := meth,bprintln(m)];
	
	//entities= [ method,constructor,field | Declaration typ <- types , \class :=typ, body<- typ.body,method <- body,/method := method, constructor <-body,/constructor := constructor, field <- body, /field :=field];
	//list[Declaration] methods = [ meth | Declaration meth <- types , \class :=meth && bprintln(meth)];
		println("<size(methods)>");

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


//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- PRINT: COUNT UNITS, IMPORTS,..  - - --------- - -- -- - - --------- - -- -- - - ---------
//- -- -- - - --------- - -- -- - - --------- - -- -- - - --------- - -- -- - - ---------
public void printCountedTreeInfo(ProjectTree project){ //STEP 1
	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - -- - - - - --- -- - -- - -- - - - - --- -- - -- - --|");
	println("|	PRINTING number if sourc files, classes, imports, units, ..");
	println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
	
	top-down visit(project){
		case ProjectTree r: root(set[ProjectTree] projects):{
			println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
			println("|ROOT (projects:<size(projects)>)                    ");
			println("|------ ------ ------ - - - - --- -- - - - - - --- -- - -- - --|");
		}
		case ProjectTree p : project(loc id,str name, set[ProjectTree] contents): {
			println("|------ ------ ------ - - - - --- - --- -- - -- --- --|");
			println("|  PROJECT <name> with <p@sourcesCount> source files   ");
			println("|------ ------ ------ - - - - --- - --- -- - -- - ----|");
			//println("Project location: <id> ");
		}
		
		case ProjectTree f: folder(id,contents):{
			println("|------ ------ ------ - - - - - - -- - - - -- - --|");
			println("|    FOLDER <id.path> with <f@sourcesCount> file(s)");
			println("|------ ------ ------ - - - - - - -- - -- - -- - -|");
			printCountedSourceFiles(f);
		}
	}
}

private void printCountedSourceFiles(ProjectTree project){
	visit(project){
		case ProjectTree sf: sourceFile(loc id, Declaration declaration):{
			println("|------ ------ ------ - - --|");
			println("|       SOURCE FILE         |");
			println("|------ ------ ------ - - --|");
			println("File location: <id>");
			println("Classes: <sf@classesCount>");
			println("Units: <sf@unitsCount>");
			println("Imports: <sf@importsCount>");
		}
	}
}
