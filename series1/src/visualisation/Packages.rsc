module visualisation::Packages

import ProjectAnnotations;
import lang::java::m3::AST;
import vis::Figure;
import List;

public Figure getPackages(ProjectTree project){
 folders = [];
 switch(project){
  case f : folder(loc id, set[ProjectTree] contents) :{
   contentsOut = [];
   for(content <- contents){
		contentsOut += getPackages(content);
	}
   if(size(contentsOut)>0){
		folders += box(vcat([box(text("<id>"),fillColor("green"),vshrink(0.25)),box(treemap(contentsOut),fillColor("red"))]));
	}
  }
 case p : project(loc id,str name, set[ProjectTree] contents) : {
  contentsOut = [];
  for(content <- contents){
	 contentsOut += getPackages(content);		
  }
  if(size(contentsOut)>0){
   for(out <- contentsOut){
	folders += out;				
   }
  }
 }
 }
 return box(treemap(folders),fillColor("blue"));
}