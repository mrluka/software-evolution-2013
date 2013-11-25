module complexity::ComplexityRiskLevels

import TreeProcessor;
import lang::java::m3::AST;
import count::LocCounter;
public int RISK_LEVEL_LOW = 1;
public int RISK_LEVEL_MEDIUM = 2;
public int RISK_LEVEL_HIGH = 3;
public int RISK_LEVEL_VERY_HIGH = 4;

anno int Declaration @ riskLevel;

public int getRiskLevel(int complexity){
	if(complexity<11){
	 return RISK_LEVEL_LOW;
	}
	
	if(complexity<21){
	 return RISK_LEVEL_MEDIUM;
	}
	
	if(complexity<51){
	 return RISK_LEVEL_HIGH;
	}
	
	return RISK_LEVEL_VERY_HIGH;
}

public int sumMethodLengthsWithRiskLevel(ProjectTree tree, int riskLevel){
	int lines = 0;
	visit(tree){
		case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			if(m@riskLevel == riskLevel){
				lines += m@LOC;
			}
		}
	}
	return lines;
}

public int countMethodsWithRiskLevel(ProjectTree tree, int riskLevel){
	int total = 0;
	visit(tree){
		case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			if(m@riskLevel == riskLevel){
				total += 1;
			}
		}
	}
	return total;
}