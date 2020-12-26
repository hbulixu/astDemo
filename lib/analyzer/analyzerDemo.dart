
import 'dart:io';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

class DemoAstVisitor extends GeneralizingAstVisitor<Map> {
  @override
  Map visitNode(AstNode node) {
    //输出遍历AST Node 节点内容
    stdout.writeln('${node.runtimeType}<---->${node.toSource()}');
    return super.visitNode(node);
  }
}

void  generate(String path)  {
  if (path.isEmpty) {
    stdout.writeln('No file found');
  } else {

      try {
        var parseResult =
        parseFile(path: path, featureSet: FeatureSet.fromEnableFlags([]));
        var compilationUnit = parseResult.unit;
        //遍历AST
        compilationUnit.accept(DemoAstVisitor());
      } catch (e) {
        stdout.writeln('Parse file error: ${e.toString()}');
      }
    }
}