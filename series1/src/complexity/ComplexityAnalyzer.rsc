module complexity::ComplexityAnalyzer

import TreeProcessor;
import complexity::ExpressionComplexity;
import complexity::StatementComplexity;
import complexity::ComplexityRiskLevels;
import count::LocCounter;
import lang::java::m3::AST;
import IO; 
import util::Math; 
	
anno int Declaration @ methodCount;
anno int Declaration @ complexity;
anno int Declaration @ riskLevel;
anno set[Declaration] ProjectTree @ classes;

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
 int totalMLoc = getTotalMethodLoc(project);
 int totalLoc = getTotalLoc(project);
 println("total LOC is <totalLoc>");
 println("total LOC of methods is <totalMLoc>");
 real onePerc = toReal(totalLoc)/100;
 if(onePerc == 0){
  onePerc = 1.0;
 }
 real onePercM = toReal(totalMLoc) / 100;
 if(onePercM == 0){
  onePercM = 1.0;
 }
 println("Calculating risk level distribution over source code");
 int low = countMethodsWithRiskLevel(project, RISK_LEVEL_LOW);
 int lowL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_LOW);
 println("Read output like:");
 println("X methods with Y risk level have a length of Z (percentage of total LOC) (percentage of method LOC)");
 println("<low> methods with low risk level have a length of <lowL> (<(lowL) / (onePerc)>%) (<(lowL) / (onePercM)>%)");
 int medium = countMethodsWithRiskLevel(project, RISK_LEVEL_MEDIUM);
 int mediumL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_MEDIUM);
 println("<medium> methods with medium risk level have a length of <mediumL> (<(mediumL) / (onePerc)>%) (<(mediumL) / (onePercM)>%)");
 int high = countMethodsWithRiskLevel(project, RISK_LEVEL_HIGH);
 int highL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_HIGH);
 println("<high> methods with high risk level have a length of <highL> (<(highL) / (onePerc)>%) (<(highL) / (onePercM)>%)");
 int very_high = countMethodsWithRiskLevel(project, RISK_LEVEL_VERY_HIGH);
 int very_highL = sumMethodLengthsWithRiskLevel(project, RISK_LEVEL_VERY_HIGH);
 println("<very_high> methods with very high risk level have a length of <very_highL> (<(very_highL) / (onePerc)>%) (<(very_highL) / (onePercM)>%)");
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
   lines += m@LOC;
  }
 }
}
return lines;
}

private int getLinesOfCode(loc method){
  return method.end.line - method.begin.line;
}