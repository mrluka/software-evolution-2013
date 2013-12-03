module visualisation::Manager

import lang::java::m3::AST;
import vis::KeySym;
import vis::Figure;
import vis::Render;
import ProjectAnnotations;
import visualisation::Blocks;
import visualisation::Classes;
import visualisation::Complexity;
import visualisation::Packages;
import visualisation::ProjectTree;
import visualisation::VisualisationAnnotations;

public void showBlocks(ProjectTree project){
	render(getStartPage(project));
}

private Figure getLoadingPage(){
	return box(text("loading"));
}

private Figure getStartPage(ProjectTree project){
	project@longestClass = longestClass(project);
	pckg = visualisation::Packages::getPackages(project);
	clss = visualisation::Classes::getClassesCanvas(project);
	mthd = visualisation::Blocks::getBlockCanvas(project);
	tre = visualisation::ProjectTree::getTreeCanvas(project);
	risk = visualisation::Complexity::getBar(10.0,20.0,30.0,40.0,1);
	return vcat([getMenu(pckg,clss,mthd,tre, risk),box()]);
}


private Figure getMenu(pckg,clss,mthd,tre,risk){
	
	return box(
		hcat([
			getMenuEntry("risk",risk, pckg,clss,mthd,tre,risk),
			getMenuEntry("packages",pckg,pckg,clss,mthd,tre,risk),
			getMenuEntry("methods",mthd,pckg,clss,mthd,tre,risk),
			getMenuEntry("classes",clss,pckg,clss,mthd,tre,risk),
			getMenuEntry("tree",tre,pckg,clss,mthd,tre,risk)
			]),
		vshrink(0.1)
	);
}

private Figure getMenuEntry(txt,screen,pckg,clss,mthd,tre,risk){
	return box(
				text(txt),
				fillColor(gray(200)),
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
					render(getLoadingPage()); 
					render(vcat([getMenu(pckg,clss,mthd,tre,risk),screen])); 
					return true;}));
}



