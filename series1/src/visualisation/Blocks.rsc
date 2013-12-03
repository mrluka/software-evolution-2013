module visualisation::Blocks

import vis::Figure;
import ProjectAnnotations;
import lang::java::m3::AST;
import visualisation::VisualisationAnnotations;
import complexity::ComplexityRiskLevels;
import vis::KeySym;

private Figure getBlockCanvas(Declaration decl, ProjectTree project){
	figures = [];
	switch(decl){
		case cu : \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types) : {
			for(t <- types){
				figures += getBlockCanvas(t,project);
			}
		}
		case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
			arr = [];
			for(part <- body){
				arr += getBlockCanvas(part, project);
			}
			figures += box(vcat([box(fillColor("blue"),shrink(0.8)),box(treemap(arr), fillColor("green"))]));			
		}
		case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) :{
			figures += box(fillColor(getFillColor(m@riskLevel)));
		}
	}
	
	return box(treemap(figures),fillColor("green"));
}
	
	

	

	
public Figure getBlockCanvas(ProjectTree project){
	list[Declaration] classMethods = [];
	list[Figure] figures = [];
	switch(project){
	 		case p : project(loc id,str name, set[ProjectTree] contents) : {
		 		for(content <- contents){
		 			content@longestClass = project@longestClass;
		 			figures += getBlockCanvas(content);		
		 		}
	 		}
	 		case sf : sourceFile(id, Declaration declaration) :{
	 		 figures += getBlockCanvas(declaration,project);		
	 		}
			case f : folder(loc id, set[ProjectTree] contents) :{
			contentsOut = [];
			for(content <- contents){
			 content@longestClass = project@longestClass;
			 contentsOut += getBlockCanvas(content);
			}
			figures += box(
							box(
								vcat([box(
							onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
							edit(id);
							}),
								fillColor("gold")),
								
								treemap(
									contentsOut,
									gap(5),
									vshrink(0.8)
								)]),
								fillColor("orange")
							),
							grow(1.1,1.1),
							fillColor("brown")
						);
			}
	
		};
	
		return treemap(figures, gap(5));
}