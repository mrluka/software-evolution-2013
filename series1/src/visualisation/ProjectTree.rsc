module visualisation::ProjectTree

import visualisation::VisualisationAnnotations;
import visualisation::Classes;
import ProjectAnnotations;
import lang::java::m3::AST;
import vis::Figure;

public Figure getTreeCanvas(ProjectTree project){
	figures = [];
	switch(project){
		case f : folder(loc id, set[ProjectTree] contents) :{
			contentsOut = [];
			for(content <- contents){
				content@longestClass = project@longestClass;
				contentsOut += getTreeCanvas(content);
			}
			return tree(box(text("<id>"),fillColor("orange")),contentsOut, gap(10));
		}
		case p : project(loc id,str name, set[ProjectTree] contents) : {
			contentsOut = [];
			for(content <- contents){
				content@longestClass = project@longestClass;
				contentsOut += getTreeCanvas(content);
			}
			return tree(box(text(name),fillColor("yellow")),contentsOut, gap(10));
		}
		case sf : sourceFile(id, Declaration declaration) :{
			return getTreeCanvas(declaration,project);
		}
	}
	return tree(box(text("n/a"),fillColor("blue")),figures);
}
private Figure getTreeCanvas(Declaration decl, ProjectTree project){
figures = [];
	switch(decl){
		case cu : \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types) : {
			arr = [];
			for(t <- types){
				arr += getTreeCanvas(t, project);
			}
			return box(vcat(arr,gap(10),shrink(0.9)));
		}
		case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
	 int totalLoc = 0;
	 list[Figure] canvasses = [];
	 app = [];
	 for(b <- body){
	 	c = visualisation::Classes::getClassesCanvas(b,project);
		
			totalLoc += c@LOC;
			canvasses += c;
		
	 }
	 if(totalLoc==0){
	 	totalLoc = 1;
	 }
	 boxx = box();
	 for(c <- canvasses){
	  hght = (((c@LOC)/(totalLoc/100.0))-0.001)/100;
	  app += box(c,vshrink(hght));
	  boxx = box(box(vcat(app)),vsize(totalLoc));
	  boxx@LOC = totalLoc;
	  figures += boxx;
	 }
	 return tree(box(text("class"),fillColor("green"),onMouseOver(box(text(name)))),[boxx]);
	 //return tree(box(text("CLASS"),fillColor("green")),figures, gap(10));
	}
	case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) :{
		lvl = m@riskLevel;
		b = box(
		  vsize(m@LOC),
		  hsize(20),
		  fillColor(getFillColor(m@riskLevel)),
		  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
		   edit(m@src);
		   return true;							
		  })
		  );
		  b@LOC = m@LOC;
		return b;
		}
	
		
	}
	
	return tree(box(text("n/a"),fillColor("blue"),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
		   edit(decl@src);
		   return true;							
		  })),figures, gap(10));
}
	