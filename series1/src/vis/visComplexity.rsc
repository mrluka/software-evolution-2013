module vis::visComplexity
import vis::Figure;
import IO;
import util::Resources;
import ProjectAnnotations;
import Type;
import lang::java::m3::AST;
import complexity::ComplexityRiskLevels;
import List;
import util::Editors;
import vis::Render;
import vis::KeySym;

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
retTemp = [];
	visit(decl){
	 case c : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
	 int items = size(retTemp);
	 //println("class 1 <items>");
	 	ret += hcat(retTemp,size(items*5,2));
	 }
	 // case c : \class(list[Declaration] body):{
	 ////println("class 2");
	 //	ret += hcat(retTemp,fillColor("red"),gap(4),size(items*10,items*10));
	 //}
	 case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	   retTemp += box(fillColor(getFillColor(m@riskLevel)), vsize(20),hsize(20),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){
edit(m@src); return true;}));
	   //println("method");
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


