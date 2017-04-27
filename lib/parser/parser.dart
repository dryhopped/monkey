library parser;

import 'package:monkey/ast/ast.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/token/token.dart';

class Parser {

    Lexer lexer;
    Token currentToken;
    Token peekToken;

    Parser(this.lexer) {

        nextToken();
        nextToken();

    }

    void nextToken() {

        currentToken = peekToken;
        peekToken = lexer.nextToken();

    }

    Program parseProgram() {

        Program program = new Program();
        program.statements = new List();

        while (!currentTokenIs(Token.Eof)) {

            Statement statement = parseStatement();

            if (statement != null) {
                program.statements.add(statement);
            }

            nextToken();

        }

        return program;

    }

    Statement parseStatement() {

        switch (currentToken.type) {

            case Token.Let:
                return parseLetStatement();

            default:
                return null;

        }

    }

    LetStatement parseLetStatement() {

        LetStatement statement = new LetStatement(currentToken);

        if (!expectPeek(Token.Ident)) return null;

        statement.name = new Identifier(currentToken, currentToken.literal);

        if (!expectPeek(Token.Assign)) return null;

        // TODO: We're skipping the expressions until we encounter a semicolon.
        if (!currentTokenIs(Token.SemiColon)) nextToken();

        return statement;

    }

    bool currentTokenIs(String type) {

        return currentToken.type == type;

    }

    bool peekTokenIs(String type) {

        return peekToken.type == type;

    }

    bool expectPeek(String type) {

        if (peekToken.type == type) {
            nextToken();
            return true;
        }

        return false;

    }

}