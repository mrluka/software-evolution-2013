module ProjectAnnotations

import lang::java::m3::AST;
import util::Resources;
import vis::Render; 
import vis::Figure;
// ProjectTree definition
//data ProjectTree = root(set[ProjectTree] projects) 
//	          | project(loc id,str name, set[ProjectTree] contents)
//              | folder(loc id, set[ProjectTree] contents)
//              | file(loc id)
//              | sourceFile(loc id, Declaration declaration);
        //----
 // UNIT COUNT
anno int Resource @sourcesCount; // Source Files (.java)
anno int Resource @classesCount; // classes count (multiple classes per source file possible)
anno int Resource @unitsCount; //units / methods
anno int Resource @importsCount;
anno Declaration Resource @declaration;
// LOC 
anno list[Resource] Resource @sourceFileList;
anno map[int,str] Resource @nrs2lines; // SourceFile
anno list[int] Resource @linesList; // SourceFile
anno list[str] Resource @fileLines; // SourceFile

anno int Resource @LOC;        
anno int Resource @duplicationLineCount;
        
        //-----
// // UNIT COUNT
//anno int ProjectTree @sourcesCount;
//anno int ProjectTree @classesCount;
//anno int ProjectTree @unitsCount;
//anno int ProjectTree @importsCount;
//
//// LOC 
//anno list[ProjectTree] ProjectTree @sourceFileList;
//anno map[int,str] ProjectTree @nrs2lines; // SourceFile
//anno list[int] ProjectTree @linesList; // SourceFile
//anno list[str] ProjectTree @fileLines; // SourceFile
//
//anno int ProjectTree @LOC;
anno int Declaration @LOC;
anno int Statement @LOC;

//DUPLICATION
//anno int ProjectTree @duplicationLineCount;



// COMPLEXITY ANALYZER 
anno int Declaration @ methodCount;
anno int Declaration @ complexity;
anno int Declaration @ riskLevel;
anno int Declaration @ length;
anno set[Declaration] Resource @ classes;
anno int Declaration @ lengthRiskLevel;
anno int Declaration @ methodCount;
anno set[Declaration] Declaration @ classMethods;
anno int Declaration @ complexity;
anno set[Declaration] Resource @ classes;
 
// COMPLEXITY VISUALIZER 
anno int Figure @ LOC;
anno int Resource @ longestClass;

//RATING
anno int Declaration @ lengthRiskLevel;


