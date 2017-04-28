library interpreter;

import 'package:monkey/ast/ast.dart';
import 'package:monkey/object/object.dart';

MonkeyObject interpret(Node node) {

    if (node is Program) return interpretStatements(node.statements);
    else if (node is ExpressionStatement) return interpret(node.expression);
    else if (node is IntegerLiteral) return new Integer(node.value);
    else if (node is BooleanLiteral) return new Boolean(node.value);

    return null;

}

MonkeyObject interpretStatements(List<Statement> statements) {

    MonkeyObject result;

    statements.forEach((statement) {
        result = interpret(statement);
    });

    return result;

}