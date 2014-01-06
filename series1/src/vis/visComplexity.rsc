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
	 col = false;
	 b= box(hcat(retTemp,size(items*7,2)),fillColor(Color(){return col ? color("darkGray") : color("black");}),onMouseEnter(void () {  col=true; }), onMouseExit(void () { col=false;}),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){
	edit(c@src); return true;})); // ,getRiskText(m@riskLevel) ,grow(1.1)
 	ret += b;
	 } // +stairs(1,"<c@src.file>",c@LOC)
	
	 case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	   retTemp += box(fillColor(getFillColor(m@riskLevel)), vsize(20),hsize(20),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){
		edit(m@src,getRiskText(m@riskLevel)); return true;}));
	 }
	}
	
	return ret;
}

public Figure stairs(int nr,str name,int liOC){
	props = (nr == 0) ? [] : [mouseOver(stairs(nr-1, name, liOC))];
	return box(text("<name> <liOC>",fontColor("white"),( nr %2 == 0 )?  fontSize(20) : fontSize(1)),props + 
        [ ( nr %2 == 0 )?  left() : right(),
          resizable(false),size(10),fillColor("black"),valign(0.25) ]);
}

public str getRiskText(int riskLevel){
	if(riskLevel==RISK_LEVEL_LOW)
		return "Low complexity";
		
	if(riskLevel==RISK_LEVEL_MEDIUM)
	return "Medium complexity";
		
	if(riskLevel==RISK_LEVEL_HIGH)
		return "High complexity!";
		
	if(riskLevel==RISK_LEVEL_VERY_HIGH)
		return "Very HIGH complexity!";
	
return "CheesyFizzleNawizzle";

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


