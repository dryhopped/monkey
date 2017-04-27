library ast;

import 'package:monkey/token/token.dart';

abstract class Node {

    String tokenLiteral();

}

abstract class Statement extends Node {}

abstract class Expression extends Node {}

class Program extends Node {

    List<Statement> statements;

    String tokenLiteral() {

        return statements.isEmpty ? "" : statements.first.tokenLiteral;

    }

    @override
    String toString() {

        StringBuffer sb = new StringBuffer();
        statements.forEach((statement) => sb.write(statement));

        return sb.toString();

    }

}

class Identifier extends Expression {

    Token token; // The Ident token
    String value;

    Identifier(this.token, this.value);

    @override
    String tokenLiteral() => token.literal;

    @override
    String toString() => value;

}

class LetStatement extends Statement {

    Token token; // The Let token
    Identifier name;
    Expression value;

    LetStatement(this.token);

    @override
    String tokenLiteral() => token.literal;

    @override
    String toString() => "$tokenLiteral $name = ${value ?? ''};";

}

class ReturnStatement extends Statement {

    Token token; // The Return token
    Expression value;

    ReturnStatement(this.token);

    @override
    String tokenLiteral() => token.literal;

    @override
    String toString() => "$tokenLiteral ${value ?? ''};";

}

class ExpressionStatement extends Statement {

    Token token; // The first token of the expression
    Expression expression;

    @override
    String tokenLiteral => token.literal;

    @override
    String toString() => "${expression ?? ''}";

}