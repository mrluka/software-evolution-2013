module visualisation::Complexity


import visualisation::VisualisationAnnotations;
import count::LocCounter;
import IO;
import Set;
import vis::Figure;
import vis::Render;
import util::Math;
import TreeProcessor;
import lang::java::m3::AST;
import vis::KeySym;
import util::Editors;



public void showRiskLevels(real low, real medium, real high, real veryHigh,int totalLoc){
	 bar1 = getBar(low,medium,high,veryHigh, totalLoc); 
	 render(bar1);
}

	
private real getVshrink(int LOC, int count){
	return getRelativeHeight(count, toReal(LOC));
}
	
private Figure getBar(real v1, real v2, real v3, real v4, int max){
	 b1 = getBox("low",v1,"white", max);
	 b2 = getBox("medium",v2,"green", max);
	 b3 = getBox("high",v3,"orange", max);
	 b4 = getBox("very high",v4,"red", max);
	 return vcat([b1,b2,b3,b4, box(fillColor("gray"))]);
}
	
private Figure getBox(txt,real hght,color, int max){
	 return box(
	 	text(txt),
	 	vshrink(getRelativeHeight(max, hght)),
	 	fillColor(color)
	 );
}
	
private real getRelativeHeight(int max, real val){
	 real onePerc = toReal(max) / 100;
	 if(onePerc == 0){
	 	onePerc = 1.0;
	 } 
	 ret = val / onePerc / 100;
	 
	 if(ret == 1.0){
	 	ret = 0.99999999;
	 }
	 // workaround: if all block sizes sum up to 100%, grid is overconstrained
	 ret = ret - 0.000000000000001;
	 return ret;
}
	
