module ProjectAnnotations

import lang::java::m3::AST;

// ProjectTree definition
data ProjectTree = root(set[ProjectTree] projects) 
	          | project(loc id,str name, set[ProjectTree] contents)
              | folder(loc id, set[ProjectTree] contents)
              | file(loc id)
              | sourceFile(loc id, Declaration declaration);
        
 // UNIT COUNT
anno int ProjectTree @sourcesCount;
anno int ProjectTree @classesCount;
anno int ProjectTree @unitsCount;
anno int ProjectTree @importsCount;

// LOC 
anno list[ProjectTree] ProjectTree @sourceFileList;
anno map[int,str] ProjectTree @nrs2lines; // SourceFile
anno list[int] ProjectTree @linesList; // SourceFile
anno list[str] ProjectTree @fileLines; // SourceFile

anno int ProjectTree @LOC;
anno int Declaration @LOC;
anno int Statement @LOC;

//DUPLICATION
anno int ProjectTree @duplicationLineCount;


// COMPLEXITY ANALYZER 
anno int Declaration @ methodCount;
anno int Declaration @ complexity;
anno int Declaration @ riskLevel;
anno int Declaration @ length;
anno set[Declaration] ProjectTree @ classes;
 