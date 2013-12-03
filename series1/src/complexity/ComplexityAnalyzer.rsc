module complexity::ComplexityAnalyzer

import ProjectAnnotations;
import Prelude;
import util::Resources;
//import TreeProcessor;
import complexity::ExpressionComplexity;
import complexity::StatementComplexity;
import complexity::ComplexityRiskLevels;
import lang::java::m3::AST;
//import IO; 
import util::Math; 
	

public ProjectTree getComplexityTree(ProjectTree project){
	println("Calulcating complexity");
	return visit(project){
		case ProjectTree p : project(loc id,str name, set[ProjectTree] contents):{
	 		insert(getComplexityOfProject(p));
	    }		  
	}
}

public real getAverageUnitComplexity(ProjectTree project){
 println("Calculating avg. method complexity");
 real total = 0.0;
 real count = 1.0;
 visit(project){
  case ProjectTree sf : sourceFile(id, Declaration declaration) :{
    visit(declaration){
     case Declaration cl : \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
       visit(body){
       case m : \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
        total += m@complexity;
        println("Complexity of <mname> is <m@complexity>");
        count += 1;
       }
      }
     } 
    }
   }
  }
  real ret = total / count;
  return ret;
}

public void printRiskLevelOverview(ProjectTree project){
 int totalLoc = getTotalMethodLoc(project);
 println("total LOC is <totalLoc>");
 real onePerc = toReal(totalLoc)/100;
 if(onePerc == 0){
  onePerc = 1.0;
 }
 println("Calculating risk level distribution over source code");
 int low = countMethodsWithRiskLevel(project, RISK_LEVEL_LOW);
 int lowL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_LOW);
 println("<low> methods with low risk level have a length of <lowL> (<(lowL) / (onePerc)>%)");
 int medium = countMethodsWithRiskLevel(project, RISK_LEVEL_MEDIUM);
 int mediumL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_MEDIUM);
 println("<medium> methods with medium risk level have a length of <mediumL> (<(mediumL) / (onePerc)>%)");
 int high = countMethodsWithRiskLevel(project, RISK_LEVEL_HIGH);
 int highL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_HIGH);
 println("<high> methods with high risk level have a length of <highL> (<(highL) / (onePerc)>%)");
 int very_high = countMethodsWithRiskLevel(project, RISK_LEVEL_VERY_HIGH);
 int very_highL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_VERY_HIGH);
 println("<very_high> methods with very high risk level have a length of <very_highL> (<(very_highL) / (onePerc)>%)");
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
	   c@length = getLinesOfCode(c@src);
	   insert(c);
	  }
	  case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	   methods += 1;
	   //println("Calculating complexity of <mname>");
	   mc = complexity::StatementComplexity::get(impl) + 1;
	   methodComplexity += mc;
	   m@complexity = mc;
	   m@riskLevel = getRiskLevel(mc);
	   m@length = getLinesOfCode(m@src);
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
  total += m@length;
 }
}
return total;
}

private int countMethodsWithRiskLevel(ProjectTree tree, int riskLevel){
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

private int sumMethodLengthsWithRiskLevel(ProjectTree tree, int riskLevel){
int lines = 0;
visit(tree){
 case m: \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
  if(m@riskLevel == riskLevel){
   lines += m@length;
  }
 }
}
return lines;
}

private int getLinesOfCode(loc method){
  return method.end.line - method.begin.line;
}