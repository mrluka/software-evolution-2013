module vis::visComplexity
import vis::Figure;
import IO;
import util::Resources;
import ProjectAnnotations;
import Type;
import lang::java::m3::AST;
import complexity::ComplexityRiskLevels;
 
public Figure getView(project){
boxes = [];
visit(project.contents){
 case sf : file(id) :{
 	boxes += getMethodBoxes(sf@declaration);
 }
}

return box(pack(boxes, gap(10)));
}

public list[Figure] getMethodBoxes(decl){
ret = [];
	visit(decl){
	 case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	 	println(m);
		 ret += box(fillColor(getFillColor(m@riskLevel)), vsize(20),hsize(20));
	 }
	}
	
	return ret;
}

public Color getFillColor(int riskLevel){
	if(riskLevel==RISK_LEVEL_LOW)
		return gray(200);
		
	if(riskLevel==RISK_LEVEL_MEDIUM)
		return gray(160);
		
	if(riskLevel==RISK_LEVEL_HIGH)
		return gray(140);
		
	if(riskLevel==RISK_LEVEL_VERY_HIGH)
		return gray(120);
	
	return gray(90);
}


