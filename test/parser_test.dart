import 'package:test/test.dart';

import 'package:monkey/ast/ast.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/parser/parser.dart';

void main() {

    test("test let statements", () {

        Program program = parseProgramChecked("""
            let x = 5;
            let y = 10;
            let foobar = 838383;
        """);

        expect(program, isNotNull, reason: "parseProgram() returned null");
        expectNumStatements(program, 3);

        List<String> identifiers = ['x', 'y', 'foobar'];

        program.statements.asMap().forEach((i, statement) {

            expect(statement.tokenLiteral(), equals('let'));

            LetStatement letStatement = statement;

            expect(letStatement.name.value, equals(identifiers[i]));
            expect(letStatement.name.tokenLiteral(), equals(identifiers[i]));

        });

    });

    test("test return statements", () {

        Program program = parseProgramChecked("""
            return 5;
            return 10;
            return 993322;
        """);

        expect(program, isNotNull, reason: "parseProgram() returned null");
        expectNumStatements(program, 3);

        List<String> identifiers = ['x', 'y', 'foobar'];

        program.statements.forEach((statement) {

            expect(statement, new isInstanceOf<ReturnStatement>());
            expect(statement.tokenLiteral(), equals('return'));

        });

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

void testBooleanLiteral(Expression expression, bool expected) {

    expect(expression, new isInstanceOf<Boolean>());
    Boolean boolean = expression;

    expect(boolean.value, equals(expected));
    expect(boolean.tokenLiteral(), equals(expected.toString()));

}

void testBooleanParsing(String input, bool expected) {

    Statement statement = parseSingleStatement(input);
    expect(statement, new isInstanceOf<ExpressionStatement>());

    ExpressionStatement expressionStatement = statement;
    testBooleanLiteral(expressionStatement.expression, expected);

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

    Program program = parseProgramChecked(input);

    expectNumStatements(program, 1);

    expect(program.statements.first, new isInstanceOf<ExpressionStatement>());
    ExpressionStatement statement = program.statements.first;

    expect(statement.expression, new isInstanceOf<InfixExpression>());
    InfixExpression expression = statement.expression;

    testLiteralExpression(expression.left, leftValue);
    expect(expression.operator, equals(operator));
    testLiteralExpression(expression.right, rightValue);

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