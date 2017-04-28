import 'package:test/test.dart';

import 'package:monkey/ast/ast.dart';
import 'package:monkey/token/token.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/parser/parser.dart';

Token t(String type, String literal) {

    return new Token(type, literal);

}

void testLexer(List<Token> expected, String input) {

    Lexer lexer = new Lexer(input);

    for (int i = 0; i < expected.length; i++) {

        Token expectedToken = expected[i];
        Token actualToken   = lexer.nextToken();

        expect(actualToken.type, expectedToken.type, reason: 'tests[$i] - type wrong.');
        expect(actualToken.literal, expectedToken.literal, reason: 'tests[$i] - literal wrong.');

    }

}

void checkParserErrors(Parser parser) {

    if (parser.errors.isEmpty) {
        return;
    }

    print('parser has ${parser.errors.length} errors.');
    parser.errors.forEach((error) {
        print('parser error: $error');
    });

    fail('');

}

void expectNumStatements(Program program, int expectedStatements) {

    int numStatements = program.statements.length;
    expect(numStatements, equals(expectedStatements), reason: 'program.statements does not contain 3 statements. got=$numStatements.');

}

Program parseProgramChecked(String input) {

    Parser parser   = new Parser(new Lexer(input));
    Program program = parser.parseProgram();
    checkParserErrors(parser);

    return program;

}

Statement parseSingleStatement(String input) {

    Program program = parseProgramChecked(input);
    expectNumStatements(program, 1);

    return program.statements.first;

}

ExpressionStatement parseExpressionStatement(String input) {

    Statement statement = parseSingleStatement(input);
    expect(statement, new isInstanceOf<ExpressionStatement>());

    ExpressionStatement expressionStatement = statement;

    return expressionStatement;

}

void testBooleanLiteral(Expression expression, bool expected) {

    expect(expression, new isInstanceOf<Boolean>());
    Boolean boolean = expression;

    expect(boolean.value, equals(expected));
    expect(boolean.tokenLiteral(), equals(expected.toString()));

}

void testBooleanParsing(String input, bool expected) {

    ExpressionStatement statement = parseExpressionStatement(input);
    testBooleanLiteral(statement.expression, expected);

}

void testIdentifier(Expression expression, String value) {

    expect(expression, new isInstanceOf<Identifier>());
    Identifier identifier = expression;
    expect(identifier.value, equals(value));
    expect(identifier.tokenLiteral(), equals(value));

}

void testIntegerLiteral(Expression expression, int integerValue) {

    expect(expression, new isInstanceOf<IntegerLiteral>());
    IntegerLiteral literal = expression;

    expect(literal.value, equals(integerValue));
    expect(literal.tokenLiteral(), equals('$integerValue'));

}

void testInfix(String input, Object leftValue, String operator, Object rightValue) {

    ExpressionStatement expressionStatement = parseExpressionStatement(input);
    expect(expressionStatement.expression, new isInstanceOf<InfixExpression>());

    InfixExpression expression = expressionStatement.expression;
    testLiteralExpression(expression.left, leftValue);

    expect(expression.operator, equals(operator));
    testLiteralExpression(expression.right, rightValue);

}

void testInfixExpression(Expression expression, Object left, String operator, Object right) {

    expect(expression, new isInstanceOf<InfixExpression>());

    InfixExpression infixExpression = expression;
    testLiteralExpression(infixExpression.left, left);
    expect(infixExpression.operator, equals(operator));
    testLiteralExpression(infixExpression.right, right);

}

void testLetStatementParsing(String input, String expectedIdentifier, Object expectedValue) {

    Statement statement = parseSingleStatement(input);

    testLetStatement(statement, expectedIdentifier);
    testLiteralExpression((statement as LetStatement).value, expectedValue);

}

void testLetStatement(Statement statement, String name) {

    expect(statement.tokenLiteral(), equals('let'));
    expect(statement, new isInstanceOf<LetStatement>());

    LetStatement letStatement = statement;
    expect(letStatement.name.value, equals(name));
    expect(letStatement.name.tokenLiteral(), equals(name));

}

void testLiteralExpression(Expression expression, Object expected) {

    if (expected is int) {
        testIntegerLiteral(expression, expected);
    } else if (expected is String) {
        testIdentifier(expression, expected);
    } else if (expected is bool) {
        testBooleanLiteral(expression, expected);
    } else {
        fail('type of expression not handled: ${expected.runtimeType}');
    }

}

void testPrecedence(String input, String expected) {

    Program program = parseProgramChecked(input);

    expect(program.toString(), equals(expected));

}

void testPrefix(String input, String operator, Object expectedValue) {

    ExpressionStatement statement = parseExpressionStatement(input);

    expect(statement.expression, new isInstanceOf<PrefixExpression>());
    PrefixExpression expression = statement.expression;

    expect(expression.operator, equals(operator));
    testLiteralExpression(expression.right, expectedValue);

}

void testReturnStatementParsing(String input, Object expectedValue) {

    Statement statement = parseSingleStatement(input);
    expect(statement.tokenLiteral(), equals('return'));
    expect(statement, new isInstanceOf<ReturnStatement>());

    ReturnStatement returnStatement = statement;
    testLiteralExpression(returnStatement.value, expectedValue);

}