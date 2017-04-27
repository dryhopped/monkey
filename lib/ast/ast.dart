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

}

class Identifier extends Expression {

    Token token; // The Ident token
    String value;

    Identifier(this.token, this.value);

    @override
    String tokenLiteral() {

        return token.literal;

    }

}

class LetStatement extends Statement {

    Token token; // The Let token
    Identifier name;
    Expression value;

    LetStatement(this.token);

    @override
    String tokenLiteral() {

        return token.literal;

    }

}