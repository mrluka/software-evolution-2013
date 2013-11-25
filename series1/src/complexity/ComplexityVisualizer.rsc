module complexity::ComplexityVisualizer

import vis::Render; 
import vis::Figure;
import util::Math;

public void showRiskLevels(int low, int medium, int high, int veryHigh,int totalLoc){
	 bar1 = getBar(low,medium,high,veryHigh, totalLoc); 
	 render(bar1);
}


private Figure getBar(int v1, int v2, int v3, int v4, int max){
	 b1 = getBox("low",v1,"white", max);
	 b2 = getBox("medium",v2,"green", max);
	 b3 = getBox("high",v3,"orange", max);
	 b4 = getBox("very high",v4,"red", max);
	 return vcat([b1,b2,b3,b4, box(fillColor("gray"))]);
}

private Figure getBox(txt,int hght,color, int max){
	 return box(
	 	text(txt),
	 	vshrink(getRelativeHeight(max, hght)),
	 	fillColor(color)
	 );
}

private real getRelativeHeight(int max, int val){
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

