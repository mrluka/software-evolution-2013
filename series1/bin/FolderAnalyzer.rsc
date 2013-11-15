module FolderAnalyzer


 


// Maven etc. gibts schon
// Aber auf methoden basis. 


// Volume: 
	//LOC: Class, Method, Package, (AVG LOC / file)
// CComplexity: Method, Class, Package, Project (Total)
	//Units per Class, Package
	//Files per Package 
	//Classes per Class File
	//Classes per Folder
	//Imports per Class
	// Being imported per Class 
	// Being used cound in LOC
	// Being used by other packages
	//Ratio between source complexity and test complexity.
// Duplication: Absolut, Ignore Var & Method names (analyze structure) 
// Readability:
	// nameLength: var, method, class , //(depends on var scope, e.g. global var name lenght must not be e.g. <=3,...class name length >4,..),
	// parameter count, class name duplication (?)  
//Unit testing:
	//Deprecated lib dependencies (?), assert count, code coverage, code coverage regarding complexity (complex units are more important to test, counterpart: getter&setter)
	// asserts total, asserts per test method, asserts per source method, tests per source method, how isolated are the tests (entering through facade,..?),
	//complexity per test, test call path depth  /tree (should be low -> isolated tests), import count / package references count per test method / test class,
	
// We must not ignore unit tests because they also have to be maintained. They are also dependencies (the other way around, each changed method needs changed  tests. A low complex method 
// could have a complex test which at the end also increases the method's complexity).
// Maybe tests says more about the source methods complexity than the method itself. Counter example: Setter method with hughe complex test context.     

// Additional thoughts:
// Coung of being implemented / extended
// Interface / Abstract Class -count (Count of overrides, specialized methods, inheritance deepness / tree, ...) 

