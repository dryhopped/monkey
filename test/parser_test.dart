import 'package:test/test.dart';

import 'package:monkey/ast/ast.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/parser/parser.dart';

void main() {

    test("test let statements", () {

        testLetStatementParsing("let x = 5;", "x", 5);
        testLetStatementParsing("let y = true;", "y", true);
        testLetStatementParsing("let foobar = y;", "foobar", "y");

    });

    test("test return statements", () {

        testReturnStatementParsing("return 5;", 5);
        testReturnStatementParsing("return true;", true);
        testReturnStatementParsing("return foobar;", "foobar");

    });

    test("test identifier expression", () {

        Program program = parseProgramChecked('foobar;');

        expectNumStatements(program, 1);

        expect(program.statements.first, new isInstanceOf<ExpressionStatement>());
        ExpressionStatement statement = program.statements.first;

        expect(statement.expression, new isInstanceOf<Identifier>());
        Identifier ident = statement.expression;

        expect(ident.value, equals('foobar'));
        expect(ident.tokenLiteral(), equals('foobar'));

    });

    test("test literal integer expression", () {

        Program program = parseProgramChecked('5;');

        expectNumStatements(program, 1);

        expect(program.statements.first, new isInstanceOf<ExpressionStatement>());
        ExpressionStatement statement = program.statements.first;

        testIntegerLiteral(statement.expression, 5);

    });

    test("test parsing prefix expressions", () {

        testPrefix("!5;", "!", 5);
        testPrefix("-15;", "-", 15);
        testPrefix("!foobar;", "!", "foobar");
        testPrefix("-foobar;", "-", "foobar");
        testPrefix("!true;", "!", true);
        testPrefix("!false;", "!", false);

    });

    test("test parsing infix expressions", () {

        testInfix("5 + 5;", 5, "+", 5);
        testInfix("5 - 5;", 5, "-", 5);
        testInfix("5 * 5;", 5, "*", 5);
        testInfix("5 / 5;", 5, "/", 5);
        testInfix("5 > 5;", 5, ">", 5);
        testInfix("5 < 5;", 5, "<", 5);
        testInfix("5 == 5;", 5, "==", 5);
        testInfix("5 != 5;", 5, "!=", 5);
        testInfix("foobar + barfoo;", "foobar", "+", "barfoo");
        testInfix("foobar - barfoo;", "foobar", "-", "barfoo");
        testInfix("foobar * barfoo;", "foobar", "*", "barfoo");
        testInfix("foobar / barfoo;", "foobar", "/", "barfoo");
        testInfix("foobar > barfoo;", "foobar", ">", "barfoo");
        testInfix("foobar < barfoo;", "foobar", "<", "barfoo");
        testInfix("foobar == barfoo;", "foobar", "==", "barfoo");
        testInfix("foobar != barfoo;", "foobar", "!=", "barfoo");
        testInfix("true == true", true, "==", true);
        testInfix("true != false", true, "!=", false);
        testInfix("false == false", false, "==", false);

    });

    test("test operator precedence parsing", () {

        testPrecedence("-a * b", "((-a) * b)");
        testPrecedence("!-a", "(!(-a))");
        testPrecedence("a + b + c", "((a + b) + c)");
        testPrecedence("a * b * c", "((a * b) * c)");
        testPrecedence("a * b / c", "((a * b) / c)");
        testPrecedence("a + b / c", "(a + (b / c))");
        testPrecedence("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)");
        testPrecedence("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)");
        testPrecedence("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))");
        testPrecedence("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))");
        testPrecedence("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))");
        testPrecedence("true", "true");
        testPrecedence("false", "false");
        testPrecedence("3 > 5 == false", "((3 > 5) == false)");
        testPrecedence("3 < 5 == true", "((3 < 5) == true)");
        testPrecedence("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)");
        testPrecedence("2 / (5 + 5)", "(2 / (5 + 5))");
        testPrecedence("(5 + 5) * 2 * (5 + 5)", "(((5 + 5) * 2) * (5 + 5))");
        testPrecedence("-(5 + 5)", "(-(5 + 5))");
        testPrecedence("!(true == true)", "(!(true == true))");

    });

    test("test boolean expression", () {

        testBooleanParsing("true;", true);
        testBooleanParsing("false;", false);

    });

    test("test if expression", () {

        ExpressionStatement statement = parseExpressionStatement('if (x < y) { x }');
        expect(statement.expression, new isInstanceOf<IfExpression>());

        IfExpression expression = statement.expression;
        testInfixExpression(expression.condition, "x", "<", "y");
        expect(expression.consequence.statements.length, equals(1));

        ExpressionStatement consequence = expression.consequence.statements.first;
        testIdentifier(consequence.expression, "x");

        expect(expression.alternative, isNull);

    });

    test('test if/else expression', () {

        ExpressionStatement statement = parseExpressionStatement('if (x < y) { x } else { y }');
        expect(statement.expression, new isInstanceOf<IfExpression>());

        IfExpression expression = statement.expression;
        testInfixExpression(expression.condition, "x", "<", "y");
        expect(expression.consequence.statements.length, equals(1));

        ExpressionStatement consequence = expression.consequence.statements.first;
        testIdentifier(consequence.expression, "x");
        expect(expression.alternative.statements.length, equals(1));

        ExpressionStatement alternative = expression.alternative.statements.first;
        testIdentifier(alternative.expression, "y");

    });

}

void checkParserErrors(Parser parser) {

    if (parser.errors.isEmpty) {
        return;
    }

    print("parser has ${parser.errors.length} errors.");
    parser.errors.forEach((error) {
        print("parser error: $error");
    });

    fail('');

}

void expectNumStatements(Program program, int expectedStatements) {

    int numStatements = program.statements.length;
    expect(numStatements, equals(expectedStatements), reason: "program.statements does not contain 3 statements. got=$numStatements.");

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
        fail("type of expression not handled: ${expected.runtimeType}");
    }

}

void testPrecedence(String input, String expected) {

    Program program = parseProgramChecked(input);

    expect(program.toString(), equals(expected));

}

void testPrefix(String input, String operator, Object expectedValue) {

    Program program = parseProgramChecked(input);

    expectNumStatements(program, 1);

    expect(program.statements.first, new isInstanceOf<ExpressionStatement>());
    ExpressionStatement statement = program.statements.first;

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