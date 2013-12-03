module complexity::DeclarationComplexity

import complexity::ExpressionComplexity;
import lang::java::m3::AST;

public int get(Declaration declaration){
 ret = 0;
 switch(declaration){
  case c : \variables(Type \type, list[Expression] \fragments):{
   for(e <- \fragments){
    ret += complexity::ExpressionComplexity::get(e);
   }
  }
 }
 return ret;
}
