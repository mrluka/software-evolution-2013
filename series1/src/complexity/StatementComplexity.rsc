module complexity::StatementComplexity

import complexity::ExpressionComplexity;
import complexity::DeclarationComplexity;
import lang::java::m3::AST;
import IO;
	 
public int get(Statement statement){
 int ret =0;
 
 switch(statement){
 
  case \assert(Expression expression):{
   ret +=1;
   ret += complexity::ExpressionComplexity::get(expression);
  }
  
  case \assert(Expression expression, Expression message):{
   ret += 1;
   ret += complexity::ExpressionComplexity::get(expression);
   ret += complexity::ExpressionComplexity::get(message);
  }
  
  case b : \block(list[Statement] statements):{
   for(s <- statements){
    sC = complexity::StatementComplexity::get(s);
    ret += sC;
   }
  }
  
  case \assert(Expression expression):{ 
   ret += 1;
   ret += complexity::ExpressionComplexity::get(expression);
  }
  
  case \break():{
   ret += 0;
  }
  
  case \break(str label):{
   ret += 0;
  }
  
  case \continue():{
   ret += 0;
  }
  
  case \continue(str label):{
   ret += 0;
  }
  
  case \do(Statement body, Expression condition):{
   ret +=1 ;
   ret += complexity::StatementComplexity::get(body);
   ret += complexity::ExpressionComplexity::get(condition);
  }
  
  case \empty():{
   ret += 0;
  }
  
  case \foreach(Declaration parameter, Expression collection, Statement body):{
   ret +=1;
   ret += complexity::DeclarationComplexity::get(parameter);
   ret += complexity::ExpressionComplexity::get(collection);
   ret += complexity::StatementComplexity::get(body);
  }
  
  case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body):{
   ret += 1;
   for(i <- initializers){
    ret += complexity::ExpressionComplexity::get(i);
   }
   ret += complexity::ExpressionComplexity::get(condition);
   for(u<-updaters){
    ret += complexity::ExpressionComplexity::get(u);
   }
   ret += complexity::StatementComplexity::get(body);
  }
  
  case \for(list[Expression] initializers, list[Expression] updaters, Statement body):{
   ret += 1;
   for(i <- initializers){
    ret += complexity::ExpressionComplexity::get(i);
   }
   for(u<-updaters){
    ret += complexity::ExpressionComplexity::get(u);
   }
   ret += complexity::StatementComplexity::get(body);
  }
  
  case \if(Expression condition, Statement thenBranch):{
   ret += 1;
   ret += complexity::ExpressionComplexity::get(condition); 
   thenC = complexity::ExpressionComplexity::get(thenBranch);
   ret += thenC;
  }
  
  case \if(Expression condition, Statement thenBranch, Statement elseBranch):{
   ret += 1;
   ret += complexity::ExpressionComplexity::get(condition);
   thenC = complexity::ExpressionComplexity::get(thenBranch);
   elseC = complexity::ExpressionComplexity::get(elseBranch);
   if(thenC > elseC){
    ret += thenC;
   }else{
    ret += elseC;
   }
  }
  
  case \label(str name, Statement body):{
   ret += 0;
  }
  
  case \return():{
   ret += 0;
  }
  
  case \return(Expression expression):{
   ret += complexity::ExpressionComplexity::get(expression);
  }
  
  case sw : \switch(Expression expression, list[Statement] statements):{
   ret += complexity::ExpressionComplexity::get(expression);
   largestC = 0;
   for(s <- statements){
    sC= complexity::StatementComplexity::get(s);
    if(sC > largestC){
     largestC = sC;
    }
   }
   ret += largestC;
  }
  
  case c : \case(Expression expression):{
   ret += 1;
   ret += complexity::ExpressionComplexity::get(expression);
  }
  
  case c : \defaultCase():{
   ret += 1;
  }
  
  case \synchronizedStatement(Expression lock, Statement body):{
   ret += 0;
   ret += complexity::ExpressionComplexity::get(lock);
   ret += complexity::StatementComplexity::get(body);
  }
  
  case \throw(Expression expression):{
   ret += complexity::ExpressionComplexity::get(expression);   
  }
  
  case \try(Statement body, list[Statement] catchClauses):{
   ret += 1;
   ret += complexity::StatementComplexity::get(body);
   for(cc <- catchClauses){
    ret += complexity::StatementComplexity::get(cc);
   }
  }
  
  case \try(Statement body, list[Statement] catchClauses, Statement \finally):{
   ret += 1;
   ret += complexity::StatementComplexity::get(body);
   for(cc <- catchClauses){
    ret += complexity::StatementComplexity::get(cc);
   }
   ret += complexity::StatementComplexity::get(\finally);
  }
  
  case \catch(Declaration exception, Statement body):{
   ret += 1;
   ret += complexity::DeclarationComplexity::get(exception);
   ret += complexity::StatementComplexity::get(body);
  }
  
  case  dS : \declarationStatement(Declaration declaration):{
   ret += complexity::DeclarationComplexity::get(declaration);
  }
  
  case \while(Expression condition, Statement body):{
   ret += complexity::ExpressionComplexity::get(condition);
   complexity::StatementComplexity::get(body);   
  }
  
  case \expressionStatement(Expression stmt):{
   ret += complexity::ExpressionComplexity::get(stmt);
  }
  
  case \constructorCall(bool isSuper, Expression expr, list[Expression] arguments):{
   for(a <- arguments){
    ret += complexity::ExpressionComplexity::get(a);
   }
   complexity::ExpressionComplexity::get(expr);
  }
  
  case \constructorCall(bool isSuper, list[Expression] arguments):{
   for(a <- arguments){
    ret += complexity::ExpressionComplexity::get(a);
   }
  }
 }
 return ret;
 }