module visualisation::Classes

import IO;
import List;
import util::Math;
import visualisation::VisualisationAnnotations;
import vis::Figure;
import ProjectAnnotations;
import count::LocCounter;
import complexity::ComplexityRiskLevels;
import lang::java::m3::AST;
import vis::KeySym;
import util::Editors;

private Figure getClassesCanvas(ProjectTree project){
	figures = getClassesCanvases(project);
	if(size(figures) > 0){
	 	return box(box(pack(figures, gap(10))));
	}
	return box();
}

private list[Figure] getClassesCanvases(ProjectTree project){
	list[Figure] figures = [];
	switch(project){
		case p : project(loc id,str name, set[ProjectTree] contents) : {
			for(content <- contents){
				content@longestClass = project@longestClass;
				figures += getClassesCanvases(content);
			}
		}
		case f : folder(loc id, set[ProjectTree] contents) :{
			for(content <- contents){
				content@longestClass = project@longestClass;
				figures += getClassesCanvases(content);
			}
		}
		case sf : sourceFile(id, Declaration declaration) :{
			figures += getClassesCanvas(declaration,project);
		}
	}
	return figures;
}
	
private Figure getClassesCanvas(Declaration project, ProjectTree projectTree){
	switch(project){
		case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) :{
			lvl = m@riskLevel;
			ret = box(text(mname),
			 //vsize(20),
			 // hsize(20),
			  fillColor(getFillColor(m@riskLevel)),
			  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
			   edit(m@src);
			   return true;							
			  })
		  );
		  b@LOC = m@LOC;
		  return ret;
		}
		case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
		 int totalLoc = 0;
		 int longestPossible = projectTree@longestClass;
		 list[Figure] app = [];
		 app += box(text("class <name>"));
		 list[Figure] body2 = [];
		 for(decl <- body){	
		 	canvas = getClassesCanvas(decl,projectTree);
		 	totalLoc += canvas@LOC;
			body2 += canvas;
		}
		for(b <- body2){
			int methodLength = b@LOC;
			real hght = (toReal(methodLength) / (toReal(totalLoc) / 100.0)) / 100.0;
			app += box(b,vshrink(hght-0.001),top());
		}
		 if(totalLoc>0){
			 real ohght = (toReal(totalLoc) / (toReal(longestPossible)/100.0)/100.0 )- 0.001;
			 Figure boxx = box(vcat(app,top()),vshrink(ohght));
			 boxx@LOC = totalLoc;
			 return boxx;
		 }
		}
		case cu : \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types) : {
			app = [];
			for(t <- types){
			 	app += getClassesCanvas(t,projectTree);
			}
			return box(hcat(app));
		}
	}
	ret = box(text("???"));
	ret@LOC=1;
	return ret;
}
	