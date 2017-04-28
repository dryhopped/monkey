library interpreter;

import 'package:monkey/ast/ast.dart';
import 'package:monkey/object/object.dart';

const MonkeyNull NULL = const MonkeyNull();
const Boolean TRUE = const Boolean(true);
const Boolean FALSE = const Boolean(false);

MonkeyObject interpret(Node node) {

    if (node is Program) return interpretStatements(node.statements);
    else if (node is ExpressionStatement) return interpret(node.expression);
    else if (node is IntegerLiteral) return new Integer(node.value);
    else if (node is BooleanLiteral) return nativeBoolToBooleanObject(node.value);
    else if (node is PrefixExpression) return interpretPrefixExpression(node.operator, interpret(node.right));

    return null;

}

MonkeyObject interpretStatements(List<Statement> statements) {

    MonkeyObject result;

    statements.forEach((statement) {
        result = interpret(statement);
    });

    return result;

}

MonkeyObject interpretPrefixExpression(String operator, MonkeyObject right) {

    switch (operator) {

        case '!':
            return interpretBangOperatorExpression(right);

        default:
            return null;

    }

}

MonkeyObject interpretBangOperatorExpression(MonkeyObject right) {

    if (right == TRUE) return FALSE;
    else if (right == FALSE) return TRUE;
    else if (right == NULL) return TRUE; // null evaluates to false, not null is true

    return FALSE; // false and null are false, all other values are true

}

Boolean nativeBoolToBooleanObject(bool value) => value ? TRUE : FALSE;