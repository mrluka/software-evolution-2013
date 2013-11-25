module complexity::ComplexityAnalyzer

import TreeProcessor;
import complexity::ExpressionComplexity;
import complexity::StatementComplexity;
import complexity::ComplexityRiskLevels;
import complexity::ComplexityVisualizer;
import sig::Rating;
import count::LocCounter;
import lang::java::m3::AST;
import IO; 
import util::Math; 
	
anno int Declaration @ methodCount;
anno int Declaration @ complexity;
anno set[Declaration] ProjectTree @ classes;

public ProjectTree getComplexityTree(ProjectTree project){
	println("Calulcating complexity");
	return visit(project){
		case ProjectTree p : project(loc id,str name, set[ProjectTree] contents):{
			insert(getComplexityOfProject(p));
		}		  
	}
}

public int printRiskLevelOverview(ProjectTree project){
	 int totalMLoc = getTotalMethodLoc(project);
	 int totalLoc = getTotalLoc(project);
	 println("total LOC is <totalLoc>");
	 println("total LOC of methods is <totalMLoc>");
	 real onePerc = getOnePerc(totalLoc);
	 real onePercM = getOnePerc(totalMLoc);
	 println("Calculating risk level distribution over source code");
	 real lowPerc = printRiskLevel(RISK_LEVEL_LOW, project,onePerc,onePercM, "low");
	 real mediumPerc = printRiskLevel(RISK_LEVEL_MEDIUM, project,onePerc,onePercM, "medium");
	 real highPerc = printRiskLevel(RISK_LEVEL_HIGH, project,onePerc,onePercM, "high");
	 real veryHighPerc = printRiskLevel(RISK_LEVEL_VERY_HIGH, project,onePerc,onePercM, "very high");
	 ret = printComplexityRating(mediumPerc, highPerc, veryHighPerc);
	 complexity::ComplexityVisualizer::showRiskLevels(lowPerc, mediumPerc, highPerc, veryHighPerc,100);
	 return ret;
}

public int getLocRating(ProjectTree project){
	int totalLoc = getTotalLoc(project);	
	return printLocRating(totalLoc);
}

public int getAvgLocRating(ProjectTree project){
	int totalMLoc = getTotalMethodLoc(project);
	int totalLoc = getTotalLoc(project);
	real onePerc = getOnePerc(totalLoc);
	real onePercM = getOnePerc(totalMLoc);	
	return printAverageUnitLocRating(project,onePerc,onePercM);
}

private real getOnePerc(int oneHundred){
	 real onePerc = toReal(oneHundred)/100;
	 if(onePerc == 0){
	  onePerc = 1.0;
	 }	 
	 return onePerc;
}

private real printRiskLevel(level, project, onePerc, onePercM, levelStr){
	 int count = countMethodsWithRiskLevel(project, level);
	 int sum = sumMethodLengthsWithRiskLevel(project, level);
	 perc = (sum) / (onePerc);
	 percM = (sum) / (onePercM);
	 println("<count> methods with <levelStr> risk level have a length of <sum> (<perc>% of total LOC) (<percM>% of method LOC)");
	 return perc;
}

private ProjectTree getComplexityOfProject(ProjectTree project){
 set[Declaration] classes = {};
 int methods = 0;
 int methodComplexity = 0;
 int constructorComplexity = 0;
 return bottom-up visit(project){
	  case f : folder(id, contents) :{
	   insert f;
	  }
	  case sf : sourceFile(id, Declaration declaration) :{
	   sf@classes =  classes;
	   classes = {};
	   insert sf;
	  }
	  case c :  \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{
	   cc = complexity::StatementComplexity::get(impl) + 1;
	   c@complexity = cc;
	   c@riskLevel = getRiskLevel(cc);
	   constructorComplexity += cc;
	   insert(c);
	  }
	  case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	   methods += 1;
	   //println("Calculating complexity of <mname>");
	   mc = complexity::StatementComplexity::get(impl) + 1;
	   methodComplexity += mc;
	   m@complexity = mc;
	   m@riskLevel = getRiskLevel(mc);
	   insert(m);
	  }
	  case cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{						   
	   cl@methodCount = methods;
	   cl@complexity = methodComplexity + constructorComplexity;
	   classes + cl;
	   methods = 0;
	   methodComplexity = 0;	
	   constructorComplexity = 0;					   
	   insert(cl);	
  	  } 
	  case cl : \class(list[Declaration] body):{
	  cl@methodCount = methods;
	   cl@complexity = methodComplexity + constructorComplexity;
	   classes + cl;
	   methods = 0;
	   methodComplexity = 0;	
	   constructorComplexity = 0;							   
	   insert(cl);
	  }
 };
}

private int getTotalMethodLoc(ProjectTree tree){
	int total = 0;
	visit(tree){
		case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
			total += m@LOC;
		}
	}
	return total;
}

private int getTotalLoc(ProjectTree tree){
	int total = 0;
	visit(tree){
		case ProjectTree sf: sourceFile(loc id, Declaration declaration):{
			total += sf@LOC;
		}
	}
	return total;
}