module testBoxes

import vis::Render; 
import vis::Figure;
import vis::KeySym;
public void doX(){
render(box(vcat([
//shink is 0.125
//shink is 0.5625
box(fillColor("blue"),vshrink(0.125)),
box(fillColor("red"),vshrink(0.5625))
])));
}
private Figure getMenu(compProject){
return box(
hcat([
box(text("packages"),fillColor(gray(200)),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {render(getPackagePage(compProject)); return true;})),
box(text("methods"),fillColor(gray(200)),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {render(getMethodPage(compProject)); return true;})),
box(text("classes"),fillColor(gray(200)),onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {render(getClassPage(compProject)); return true;}))
]),
vshrink(0.1)
);
}

private Figure getStartPage(compProject){
  return vcat([getMenu(compProject),box()]);
}


private Figure getPackagePage(compProject){
  return vcat([getMenu(compProject),box(text("pack"))]);
}
private Figure getMethodPage(compProject){
  return vcat([getMenu(compProject),box(text("meth"))]);
}
private Figure getClassPage(compProject){
  return vcat([getMenu(compProject),box(text("clas"))]);
}

public void testB(){
compProject = "";
render(getStartPage(compProject));
}
public void testA(){
	a = [
	box(fillColor("red"),height(40), width(20)),
	box(fillColor("red"),height(30), width(20)),
	box(fillColor("red"),height(50), width(20)),
	box(fillColor("red"), height(70),width(20)),
	box(fillColor("red"),height(20), width(20))];
	b = treemap(a, gap(10));
	c = [
	box(fillColor("red"),height(40), width(20)),
	box(fillColor("red"),height(30), width(20)),
	box(fillColor("red"),height(50), width(20)),
	box(fillColor("red"), height(70),width(20)),
	box(fillColor("red"),height(20), width(20))];
	f = [
	box(fillColor("red"),height(40), width(20)),
	box(fillColor("red"),height(30), width(20)),
	box(fillColor("red"),height(50), width(20)),
	box(fillColor("red"), height(70),width(20)),
	box(fillColor("red"),height(20), width(20))];
	g = treemap(f, gap(10));
	d = treemap(c, gap(10));
	e = treemap([b,d], gap(10));
	render(box(e));
}