module complexity::ComplexityRiskLevels

public int RISK_LEVEL_LOW = 1;
public int RISK_LEVEL_MEDIUM = 2;
public int RISK_LEVEL_HIGH = 3;
public int RISK_LEVEL_VERY_HIGH = 4;

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