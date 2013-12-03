module complexity::ExpressionComplexity

import complexity::DeclarationComplexity;
import complexity::StatementComplexity;
import lang::java::m3::AST;
import IO;
	
public int get(Expression expression){

int ret = 0;
switch(expression){

case \newObject(Expression expr, Type \type, list[Expression] args, Declaration class):{
 ret += getExpressionComplexity(expr);
 for(a <- args){
  ret += getExpressionComplexity(a);
 }
}

case \bracket(Expression expression):{
 ret += complexity::ExpressionComplexity::get(expression);
}

case \infix(Expression lhs, str operator, Expression rhs, list[Expression] extendedOperands):{ 
 //println("infix");
 if(operator == "&&" || operator == "||"){
  ret += 1;
 }
 ret += complexity::ExpressionComplexity::get(lhs);
 ret += complexity::ExpressionComplexity::get(rhs);
 for(eo <- extendedOperands){
  ret += complexity::ExpressionComplexity::get(eo);
 }
}

case \postfix(Expression operand, str operator):{
 ret += complexity::ExpressionComplexity::get(operand);
}

case \prefix(str operator, Expression operand):{
 ret += complexity::ExpressionComplexity::get(operand);
}

case \qualifiedName(Expression qualifier, Expression expression):{
 ret += complexity::ExpressionComplexity::get(qualifier) + complexity::ExpressionComplexity::get(expression);
}

case \this():{
 ret += 0;
}

case \this(Expression thisExpression):{
 ret += complexity::ExpressionComplexity::get(thisExpression);
}

case \super():{
 ret += 0;
}

case \variable(str name, int extraDimensions):{
 ret += 0;
}

case \variable(str name, int extraDimensions, Expression \initializer):{
 ret += complexity::ExpressionComplexity::get(initializer);
 ret += 0;
}

case \newObject(Expression expr, Type \type, list[Expression] args):{
 for(a <- args){
  ret += complexity::ExpressionComplexity::get(a);
 }
}

case \newObject(Type \type, list[Expression] args, Declaration class):{
 for(a <- args){
  ret += complexity::ExpressionComplexity::get(a);
 }
 ret += complexity::DeclarationComplexity::get(class);
}

case \newObject(Type \type, list[Expression] args):{
 for(a <- args){
  ret += complexity::ExpressionComplexity::get(a);
 }
}

case \fieldAccess(bool isSuper, Expression expression, str name):{
 complexity::ExpressionComplexity::get(expression);
}

case \fieldAccess(bool isSuper, str name):{
 ret += 0;
}

case \conditional(Expression expression, Expression thenBranch, Expression elseBranch):{
 ret += complexity::ExpressionComplexity::get(expression);
 thenC = complexity::ExpressionComplexity::get(thenBranch);
 elseC = complexity::ExpressionComplexity::get(elseBranch);
 if(thenC > elseC){
  ret += thenC;
 }else{
  ret += elseC;
 }
}

case \declarationExpression(Declaration decl):{
 ret += complexity::DeclarationComplexity::get(decl);
}

case \assignment(Expression lhs, str operator, Expression rhs):{
 ret += complexity::ExpressionComplexity::get(lhs) + complexity::ExpressionComplexity::get(rhs);
}

case  \simpleName(str name):{
 ret += 0;
}

case  \methodCall(bool isSuper, str name, list[Expression] arguments):{
 ret += 0;
 for(a <- arguments){
  ret += complexity::ExpressionComplexity::get(a);
 }
}

case \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):{
 ret += complexity::ExpressionComplexity::get(receiver);
 for(a <- arguments){
  ret += complexity::ExpressionComplexity::get(a);
 }
}

case \number(str numberValue):{
 ret += 0;
}

case \booleanLiteral(bool boolValue):{
 ret += 0;
}

case \stringLiteral(str stringValue):{
 ret += 0;
}

case \variable(str name, int extraDimensions):{
 ret += 0;
}

case \while(Expression condition, Statement body):{
 ret += 1;
 ret += complexity::ExpressionComplexity::get(condition);
 ret += complexity::StatementComplexity::get(body);
}

case \variable(str name, int extraDimensions, Expression \initializer):{
 ret += complexity::ExpressionComplexity::get(initializer);}
}

 return ret;
}