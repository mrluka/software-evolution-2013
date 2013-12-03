module visualisation::VisualisationAnnotations

import vis::Figure;
import ProjectAnnotations;
import complexity::ComplexityRiskLevels;
import lang::java::m3::AST;
import count::LocCounter;

anno int Figure @ LOC;
anno int ProjectTree @ longestClass;

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

// todo make annotation, only run once
public int longestClass(project){
	longest = 0;
	visit(project){
		case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
		classLOC = 0;
			visit(body){
				case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) :{
					classLOC += m@LOC;
				}
			}
			if(longest <classLOC){
				longest = classLOC;
			}
		}		
	}
	return longest;
}
