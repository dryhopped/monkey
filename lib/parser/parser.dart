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
        Token.Asterisk: Precedence.Product,
        Token.LeftParen: Precedence.Call
    };

    Parser(this.lexer) {

        nextToken();
        nextToken();

        /// Register Prefix Expressions
        registerPrefix(Token.Ident, parseIdentifier);
        registerPrefix(Token.Int, parseIntegerLiteral);
        registerPrefix(Token.Bang, parsePrefixExpression);
        registerPrefix(Token.Minus, parsePrefixExpression);
        registerPrefix(Token.True, parseBooleanLiteral);
        registerPrefix(Token.False, parseBooleanLiteral);
        registerPrefix(Token.LeftParen, parseGroupedExpression);
        registerPrefix(Token.If, parseIfExpression);
        registerPrefix(Token.Function, parseFunctionLiteral);

        /// Register Infix Expressions
        registerInfix(Token.Plus, parseInfixExpression);
        registerInfix(Token.Minus, parseInfixExpression);
        registerInfix(Token.Slash, parseInfixExpression);
        registerInfix(Token.Asterisk, parseInfixExpression);
        registerInfix(Token.Equal, parseInfixExpression);
        registerInfix(Token.NotEqual, parseInfixExpression);
        registerInfix(Token.Lt, parseInfixExpression);
        registerInfix(Token.Gt, parseInfixExpression);
        registerInfix(Token.LeftParen, parseCallExpression);

    }

    void nextToken() {

        currentToken = peekToken;
        peekToken = lexer.nextToken();

    }

    BlockStatement parseBlockStatement() {

        BlockStatement block = new BlockStatement(currentToken);
        nextToken();

        while (!currentTokenIs(Token.RightBrace)) {

            Statement statement = parseStatement();

            if (statement != null) block.statements.add(statement);
            nextToken();

        }

        return block;

    }

    BooleanLiteral parseBooleanLiteral() => new BooleanLiteral(currentToken, currentTokenIs(Token.True));

    CallExpression parseCallExpression(Expression function) {

        CallExpression call = new CallExpression(currentToken, function);
        call.arguments = parseCallArguments();

        return call;

    }

    List<Expression> parseCallArguments() {

        if (peekTokenIs(Token.RightParen)) {
            nextToken();
            return [];
        }

        List<Expression> arguments = [];
        nextToken();

        arguments.add(parseExpression(Precedence.Lowest));
        while (peekTokenIs(Token.Comma)) {
            nextToken();
            nextToken();
            arguments.add(parseExpression(Precedence.Lowest));
        }

        if (!expectPeek(Token.RightParen)) return null;

        return arguments;

    }

    Expression parseGroupedExpression() {

        nextToken();

        Expression expression = parseExpression(Precedence.Lowest);
        if (!expectPeek(Token.RightParen)) return null;

        return expression;

    }

    FunctionLiteral parseFunctionLiteral() {

        FunctionLiteral function = new FunctionLiteral(currentToken);
        if (!expectPeek(Token.LeftParen)) return null;

        function.parameters = parseFunctionParameters();
        if (!expectPeek(Token.LeftBrace)) return null;

        function.body = parseBlockStatement();

        return function;

    }

    List<Identifier> parseFunctionParameters() {

        List<Identifier> parameters = [];

        if (peekTokenIs(Token.RightParen)) {
            nextToken();
            return parameters;
        }

        nextToken();

        parameters.add(new Identifier(currentToken, currentToken.literal));

        while (peekTokenIs(Token.Comma)) {
            nextToken();
            nextToken();
            parameters.add(new Identifier(currentToken, currentToken.literal));
        }

        if (!expectPeek(Token.RightParen)) return null;

        return parameters;

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

    IfExpression parseIfExpression() {

        IfExpression expression = new IfExpression(currentToken);
        if (!expectPeek(Token.LeftParen)) return null;
        nextToken();

        expression.condition = parseExpression(Precedence.Lowest);
        if (!expectPeek(Token.RightParen)) return null;
        if (!expectPeek(Token.LeftBrace)) return null;

        expression.consequence = parseBlockStatement();
        if (peekTokenIs(Token.Else)) {
            nextToken();

            if (!expectPeek(Token.LeftBrace)) return null;

            expression.alternative = parseBlockStatement();
        }

        return expression;

    }

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

            errors.add('could not parse ${currentToken.literal} as integer.');
            return null;

        }

    }

    LetStatement parseLetStatement() {

        LetStatement statement = new LetStatement(currentToken);

        if (!expectPeek(Token.Ident)) return null;

        statement.name = new Identifier(currentToken, currentToken.literal);

        if (!expectPeek(Token.Assign)) return null;
        nextToken();

        statement.value = parseExpression(Precedence.Lowest);

        if (peekTokenIs(Token.SemiColon)) nextToken();

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

        statement.value = parseExpression(Precedence.Lowest);
        if (peekTokenIs(Token.SemiColon)) nextToken();

        return statement;

    }

    Precedence currentPrecedence() => precedences[currentToken.type] ?? Precedence.Lowest;

    bool currentTokenIs(String type) => currentToken.type == type;

    bool expectPeek(String type) {

        if (peekToken.type == type) {
            nextToken();
            return true;
        }

        peekError(type);
        return false;

    }

    void noPrefixParseFnError(String type) {

        errors.add('no prefix parse function for $type found.');

    }

    void peekError(String type) {

        errors.add('expected next token to be $type, but got ${peekToken.type}.');

    }

    Precedence peekPrecedence() => precedences[peekToken.type] ?? Precedence.Lowest;

    bool peekTokenIs(String type) => peekToken.type == type;

    void registerInfix(String type, Function infixParseFn) {

        infixParseFns[type] = infixParseFn;
    }

    void registerPrefix(String type, Function prefixParseFn) {

        prefixParseFns[type] = prefixParseFn;

    }

}