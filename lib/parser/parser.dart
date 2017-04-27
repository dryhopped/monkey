library parser;

import 'package:monkey/ast/ast.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/token/token.dart';
import 'package:monkey/parser/precedence.dart';

class Parser {

    Lexer lexer;
    Token currentToken;
    Token peekToken;

    List<String> errors = [];

    Map<String, Function> prefixParseFns = {};
    Map<String, Function> infixParseFns = {};

    Map<String, Precedence> precedences = {
        Token.Equal:    Precedence.Equals,
        Token.NotEqual: Precedence.Equals,
        Token.Lt:       Precedence.LessGreater,
        Token.Gt:       Precedence.LessGreater,
        Token.Plus:     Precedence.Sum,
        Token.Minus:    Precedence.Sum,
        Token.Slash:    Precedence.Product,
        Token.Asterisk: Precedence.Product
    };

    Parser(this.lexer) {

        nextToken();
        nextToken();

        registerPrefix(Token.Ident, parseIdentifier);
        registerPrefix(Token.Int, parseIntegerLiteral);
        registerPrefix(Token.Bang, parsePrefixExpression);
        registerPrefix(Token.Minus, parsePrefixExpression);

        registerInfix(Token.Plus, parseInfixExpression);
        registerInfix(Token.Minus, parseInfixExpression);
        registerInfix(Token.Slash, parseInfixExpression);
        registerInfix(Token.Asterisk, parseInfixExpression);
        registerInfix(Token.Equal, parseInfixExpression);
        registerInfix(Token.NotEqual, parseInfixExpression);
        registerInfix(Token.Lt, parseInfixExpression);
        registerInfix(Token.Gt, parseInfixExpression);

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

            case Token.Return:
                return parseReturnStatement();

            default:
                return parseExpressionStatement();

        }

    }

    ExpressionStatement parseExpressionStatement() {

        ExpressionStatement statement = new ExpressionStatement(currentToken);

        statement.expression = parseExpression(Precedence.Lowest);

        if (peekTokenIs(Token.SemiColon)) nextToken();

        return statement;

    }

    Expression parseExpression(Precedence precedence) {

        Function prefix = prefixParseFns[currentToken.type];

        if (prefix == null) {

            noPrefixParseFnError(currentToken.type);
            return null;

        }

        Expression left = prefix();

        while (!peekTokenIs(Token.SemiColon) && precedence.index < peekPrecedence().index) {

            Function infix = infixParseFns[peekToken.type];
            if (infix == null) return left;

            nextToken();
            left = infix(left);

        }

        return left;

    }

    Expression parseIdentifier() => new Identifier(currentToken, currentToken.literal);

    InfixExpression parseInfixExpression(Expression left) {

        InfixExpression expression = new InfixExpression(currentToken, currentToken.literal, left);
        Precedence precedence = currentPrecedence();
        nextToken();

        expression.right = parseExpression(precedence);

        return expression;

    }

    Expression parseIntegerLiteral() {

        IntegerLiteral literal = new IntegerLiteral(currentToken);

        try {

            int value = int.parse(currentToken.literal);
            literal.value = value;

            return literal;

        } catch (e) {

            errors.add("could not parse ${currentToken.literal} as integer.");
            return null;

        }

    }

    LetStatement parseLetStatement() {

        LetStatement statement = new LetStatement(currentToken);

        if (!expectPeek(Token.Ident)) return null;

        statement.name = new Identifier(currentToken, currentToken.literal);

        if (!expectPeek(Token.Assign)) return null;

        // TODO: We're skipping the expressions until we encounter a semicolon.
        while (!currentTokenIs(Token.SemiColon)) nextToken();

        return statement;

    }

    PrefixExpression parsePrefixExpression() {

        PrefixExpression expression = new PrefixExpression(currentToken, currentToken.literal);
        nextToken();

        expression.right = parseExpression(Precedence.Prefix);

        return expression;

    }

    ReturnStatement parseReturnStatement() {

        ReturnStatement statement = new ReturnStatement(currentToken);
        nextToken();

        // TODO: We're skipping the expressions until we encounter a semicolon.
        while (!currentTokenIs(Token.SemiColon)) nextToken();

        return statement;

    }

    Precedence currentPrecedence() => precedences[currentToken.type] ?? Precedence.Lowest;

    bool currentTokenIs(String type) {

        return currentToken.type == type;

    }

    bool expectPeek(String type) {

        if (peekToken.type == type) {
            nextToken();
            return true;
        }

        peekError(type);
        return false;

    }

    void noPrefixParseFnError(String type) {

        errors.add("no prefix parse function for $type found.");

    }

    void peekError(String type) {

        errors.add("expected next token to be $type, but got ${currentToken.type}.");

    }

    Precedence peekPrecedence() => precedences[peekToken.type] ?? Precedence.Lowest;

    bool peekTokenIs(String type) {

        return peekToken.type == type;

    }

    void registerInfix(String type, Function infixParseFn) {

        infixParseFns[type] = infixParseFn;
    }

    void registerPrefix(String type, Function prefixParseFn) {

        prefixParseFns[type] = prefixParseFn;

    }

}