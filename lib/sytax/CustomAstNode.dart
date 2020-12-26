import 'dart:convert';
import 'dart:math';

import 'package:astDemo/sytax/Visitor.dart';
import 'package:astDemo/token/token.dart';

abstract class CustomAstNode{
  Token token;
  Map visitNode();
  E accept<E>(Visitor<E> visitor);
}

//表达式
class Expression extends CustomAstNode{
  @override
  E accept<E>(Visitor<E> visitor) => visitor.visitExpression(this);
  @override
  Map visitNode() {

  }

}

//标识符
class Identify extends CustomAstNode{
  String name;
  Identify(Token token){
    if(token.kind == TokenKind.$ID){
      this.token = token;
      name = token.value;
    }
  }
  @override
  Map visitNode(){
    return {"identify":name};
  }

  @override
  E accept<E>(Visitor<E> visitor) => visitor.visitIdentify(this);
}

//整数字面量
class IntegerLiteralNode extends CustomAstNode{
  int value;
  IntegerLiteralNode(Token token){
    this.token = token;
    value = int.parse(token.value);
  }
  @override
  Map visitNode(){
    return { 'IntegerLiteral':value };
  }

  @override
  E accept<E>(Visitor<E> visitor) =>visitor.visitIntegerLiteral(this);
}

//赋值表达式
class AssignmentExpression extends  Expression{
  Token eq;
  CustomAstNode left;
  CustomAstNode right;
  AssignmentExpression(this.eq,this.left,this.right);

  @override
  Map visitNode(){
    return {"AssignmentExpression":{
      "left":left.visitNode(),
      "eq": eq.value,
      "right":right.visitNode()
    }};
  }
  @override
  E accept<E>(Visitor<E> visitor) => visitor.visitAssignmentExpression(this);
}

//变量声明
class VariableDeclarationNode extends Expression{
  Identify varName;
  VariableDeclarationNode(this.varName);

  @override
  Map visitNode(){
    return {"VariableDeclarationNode":{
      "name":varName.visitNode()
    }};
  }

  @override
  E accept<E>(Visitor<E> visitor) =>visitor.visitVariableDeclaration(this);
}

//方法声明
class FunctionDeclarationNode extends CustomAstNode{

   Identify functionName;
   List <Expression> params;
   List <Expression> body;

   FunctionDeclarationNode(this.functionName,this.params,this.body);

   @override
   Map visitNode(){
     var mapArray = <Map>[];
     body.forEach((element) {
       mapArray.add(element.visitNode());
     });
     return {
       "function":functionName.visitNode(),
       "body":mapArray,
     };
   }

   @override
   E accept<E>(Visitor<E> visitor) =>visitor.visitFunctionDeclaration(this);
}

class TokenScanner{
  int _offset = -1;
  var _tokens = <Token>[];

  TokenScanner(this._tokens);

  Token advance(){

    if( _offset+1 >= _tokens.length){
      return null;
    }else{
      return _tokens[++_offset];
    }
  }

  Token peek(){
    if( _offset+1 >= _tokens.length){
      return null;
    }else{
      return _tokens[_offset+1];
    }

  }
}

void ast_gen(){

  TokenScanner tokenScanner = TokenScanner(token_gen());

  Token  current  = tokenScanner.advance();
  Identify functionName;
  var Body = <Expression>[];

    if(current.kind == TokenKind.$FUNC){
      current = tokenScanner.advance();
      //找到functionName
      if(current.kind == TokenKind.$ID){
        functionName = Identify(current);
      }
      //找到{
      do{
        current = tokenScanner.advance();
      } while(current.kind != TokenKind.$OPEN_CURLY_BRACKET);

      //遍历body
      do{
        current = tokenScanner.advance();
        if(current == null){
          break;
        }
        //解析声明节点
        if(current.kind == TokenKind.$VAR && tokenScanner.peek().kind ==TokenKind.$ID){
            current = tokenScanner.advance();
            Identify iden = Identify(current);
            Body.add(VariableDeclarationNode(iden));
        }//解析赋值节点
        else if(current.kind == TokenKind.$ID && tokenScanner.peek().kind == TokenKind.$EQ){
            Identify iden = Identify(current);
            var eq = tokenScanner.advance();
            var value = IntegerLiteralNode(tokenScanner.advance());
            Body.add(AssignmentExpression(eq,iden,value));
        }
      }while(current.kind != TokenKind.$CLOSE_CURLY_BRACKET );

      FunctionDeclarationNode functionNode =  FunctionDeclarationNode(functionName,null,Body);

    //  var functionMap = functionNode.visitNode();
      var functionMap = functionNode.accept(MapVisitor());
      var encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(functionMap));
    }

}

