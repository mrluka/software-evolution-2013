module vis::Dependency

import IO;
import Set;
import util::Resources;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import TreeProcessor;
import ProjectAnnotations;
import vis::KeySym;

data package = pckg(str name);
anno set[str] package @ dependencies;

public void visualizeIt(){ 
	loc smallProjectLocation = |project://smallsql0.21_src/|;
	loc smallPreparedProjectLocation = |project://smallsql_prepared/|;
	Resource project = makeTree(smallProjectLocation);
	visualizeItDep(project);
}
public Figure visualizeItDep(Resource project){
	set[package] packages = {};
	visit(project){
		case f : file(id):{
			Declaration declaration = f@declaration; //createAstFromFile(id,true);
			str packageName = getPackageName(declaration);
			if(packageName != ""){
				packg = pckg(packageName);
				packg@dependencies = {};
				for(dependency <- getDependencies(declaration)){
					packg@dependencies += dependency;
				}
				packages += packg;
			}
		}
	}
 return visualize(packages);
}

private Figure visualize(set[package] packages){
	nodes = {};
	edges = [];
	
	for(name <- packages){
		nodes += box(text(name.name), id(name.name));
		println("found package <name.name>");
		for(dependency <- name@dependencies){
			nodes += box(text(dependency), id(dependency)); // 
		
			edges += edge(name.name, dependency);
			println("depends on <dependency>");
		}
	}
	
	//render(graph(toList(nodes), edges, hint("layered"), gap(100)));
	return graph(toList(nodes), edges, hint("layered"), gap(100));
}

private str getPackageName(Declaration declaration){
	ret = "";
	visit(declaration){
				case pck : package(str name):{
					ret = name;
				}
				case pck : package(Declaration parentPackage, str name) : {
					ret = getPackageName(parentPackage);
					ret += ".";
					ret += name;
				}
			}	
			
	return ret;
}

private set[str] getDependencies(Declaration declaration){
	ret = {};
	visit(declaration){
		case \import(str name) : {
			ret += name;
		}
	}
	return ret;
}