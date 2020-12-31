

import 'CustomAstNode.dart';

abstract class Visitor<T>{

  T visitIdentify(Identify node);
  T visitIntegerLiteral(IntegerLiteralNode node);
  T visitExpression(Expression node);
  T visitFunctionDeclaration(FunctionDeclarationNode node);
  T visitVariableDeclaration(VariableDeclarationNode node);
  T visitAssignmentExpression(AssignmentExpression node);
}


class MapVisitor extends Visitor<Map>{
  @override
  Map visitAssignmentExpression(AssignmentExpression node) {
    return {'AssignmentExpression':{
      'left':node.left.accept(this),
      'eq': node.eq.value,
      'right':node.right.accept(this)
    }};
  }

  @override
  Map visitExpression(Expression node) {
    return {};
  }

  @override
  Map visitFunctionDeclaration(FunctionDeclarationNode node) {
    var mapArray = <Map>[];
    node.body.forEach((element) {
      mapArray.add(element.visitNode());
    });
    return {
      'function':node.functionName.accept(this),
      'body':mapArray,
    };
  }

  @override
  Map visitIdentify(Identify node) {
    return {'identify':node.name};
  }

  @override
  Map visitIntegerLiteral(IntegerLiteralNode node) {
    return { 'IntegerLiteral':node.value };
  }

  @override
  Map visitVariableDeclaration(VariableDeclarationNode node) {
    return {'VariableDeclarationNode':{
      'name':node.varName.accept(this)
    }};
  }


}