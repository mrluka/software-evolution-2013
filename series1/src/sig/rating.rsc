module sig::Rating

import IO;
import util::Math;
import lang::java::m3::AST;
import count::LocCounter;
import ProjectAnnotations;
import complexity::ComplexityRiskLevels;

anno int Declaration @ lengthRiskLevel;

public int RATING_PLUSPLUS =2;
public int RATING_PLUS = 1;
public int RATING_NEUTRAL = 0;
public int RATING_MINUS = -1;
public int RATING_MINUSMINUS = -2;

public str getRatingName(int r){
	if(r == 2)
		return "++";
	if(r == 1)
		return "+ ";
	if(r == 0)
		return "o ";
	if(r == -1)
		return "- ";
	if(r == -2)
		return "--";
	return " ";
}

public void printOverview(int volume,int cc,int duplication, int unitSize){
	println("Rating overview:");
	println("Quality | Volume | Complexity per unit | duplication | unit size | total | ");
	printRatingRow(volume,cc,duplication,unitSize,"             ",-90);
	printRatingRowAnalysability(volume,cc,duplication,unitSize);
	printRatingRowChangeability(volume,cc,duplication,unitSize);
	printRatingRowStability(volume,cc,duplication,unitSize);
	printRatingRowTestability(volume,cc,duplication,unitSize);
}

private void printRatingRow(int volume, int cc, int duplication, int unitSize, str title, int largest){
	printRow(title,
			" <getRatingName(volume)>",
			" <getRatingName(cc)>",
			" <getRatingName(duplication)>",
			" <getRatingName(unitSize)>",
			" <getRatingName(largest)>");
}

private void printRow(a,b,c,d,e,f){
	println("<a> | <b> | <c> | <d> | <e> | <f> |");
}


private void printRatingRowStability(volume,cc,duplication,unitSize){
	printRow("Stability    ","   ","   ","   ","   "," ");
}

private void printRatingRowAnalysability(volume,cc,duplication,unitSize){
	l=getAverageRating([volume,duplication,unitSize]);
	printRow("Analysability"," X ","   "," X "," X ",getRatingName(l));
}

private void printRatingRowChangeability(volume,cc,duplication,unitSize){
	l = getAverageRating([cc,duplication]);
	printRow("Changeability","   "," X "," X ","   ",getRatingName(l));
}

private void printRatingRowTestability(volume,cc,duplication,unitSize){
	l = getAverageRating([cc,unitSize]);
	printRow("Testability  ", "   ", " X ","   "," X " ,getRatingName(l));
}

private int getAverageRating(lst){
	total = 0;
	sum = 0;
	for(l <- lst){
		total += 1;
		sum += l;
	}
	return round(toReal(sum) / total);
	
}
public int printLocRating(totalLoc){
	 output = -2;
	 kLoc = totalLoc / 1000;
	 if(kLoc == 0){
	 	kLoc = 1;
	 }
	 if(kLoc <= 1310){
	 	output = -1;
	 }
	 if(kLoc <= 665){
	 	output = 0;
	 }
	 if(kLoc <= 246){
	 	output = 1;
	 }
	 if(kLoc <= 66){
	 	output = 2;
	 }
	 
	 println("Rating for LOC is <getRatingName(output)>");
	 return output;
}

public int getDuplicationRating(perc){
	ret = RATING_MINUSMINUS;
	if(perc <= 20){
		ret = RATING_MINUS;
	}
	if(perc <= 10){
		ret = RATING_NEUTRAL;
	}
	if(perc <= 5){
		ret = RATING_PLUS;
	}
	if(perc <= 3){
		ret = RATING_PLUSPLUS;
	}
	
	return ret;
}

public int printComplexityRating(mediumPerc, highPerc, veryHighPerc){
	int output = RATING_MINUSMINUS;
	if(highPerc <= 15 && veryHighPerc <= 5 && mediumPerc <= 50){
		output = RATING_MINUS;
	}
	if(highPerc <= 10 && veryHighPerc == 0 && mediumPerc  <= 40){
		output = RATING_NEUTRAL;
	}
	if(highPerc <= 5 && veryHighPerc == 0 && mediumPerc <= 30){
		output = RATING_PLUS;
	}
	if(highPerc == 0 && veryHighPerc == 0 && mediumPerc <= 25){
		output = RATING_PLUSPLUS;
	}
		
	println("Complexity rating is <getRatingName(output)>");
	return output;
}

private int printUnitLocRating(mediumPerc, highPerc, veryHighPerc){
	int output = RATING_MINUSMINUS;
	if(highPerc <= 15 && veryHighPerc <= 5 && mediumPerc <= 50){
		output = RATING_MINUS;
	}
	if(highPerc <= 10 && veryHighPerc == 0 && mediumPerc  <= 40){
		output = RATING_NEUTRAL;
	}
	if(highPerc <= 5 && veryHighPerc == 0 && mediumPerc <= 30){
		output = RATING_PLUS;
	}
	if(highPerc == 0 && veryHighPerc == 0 && mediumPerc <= 25){
		output = RATING_PLUSPLUS;
	}
		
	println("Average LOC rating is <getRatingName(output)>");
	return output;
}

public int printAverageUnitLocRating(ProjectTree project){
	onePerc = (project@LOC) / 100.00;
	project = getAvgUnitLoc(project);
	lowPerc = countMethodsWithLocRiskLevel(project,RISK_LEVEL_LOW, onePerc, "low");
	mediumPerc = countMethodsWithLocRiskLevel(project,RISK_LEVEL_MEDIUM, onePerc, "medium");
	highPerc = countMethodsWithLocRiskLevel(project,RISK_LEVEL_HIGH, onePerc, "high");
	veryHighPerc = countMethodsWithLocRiskLevel(project,RISK_LEVEL_VERY_HIGH, onePerc, "very high");
	return printUnitLocRating(mediumPerc,highPerc,veryHighPerc);
}

private real countMethodsWithLocRiskLevel(project, level,onePerc, levelStr){
	len = 0;
	count = 0;
	visit(project){
	  case m : \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	    if(m@lengthRiskLevel == level){
	    	len += m@LOC;
	    	count +=1;
	    }
	  }
	}
	perc = len/onePerc;
	println("<count> methods with a length risk level of <levelStr> have a total length of <len> (<perc>% of total LOC)");
	return toReal(perc);
}

private int getLocRiskLevel(length){
	output = RISK_LEVEL_VERY_HIGH;
	if(length <= 50){
		output = RISK_LEVEL_HIGH;
	}
	if(length <= 20){
		output = RISK_LEVEL_MEDIUM;
	}
	if(length <= 10){
		output = RISK_LEVEL_LOW;
	}
	return output;
}


private ProjectTree getAvgUnitLoc(ProjectTree project){
	return visit(project){
	  case m : \method(Type \return, str mname, list[Declaration] parameters, list[Expression] exceptions, Statement impl) : {
	    m@lengthRiskLevel = getLocRiskLevel(m@LOC);
	    insert(m);
	  }
	}
}
