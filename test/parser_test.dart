import 'package:test/test.dart';

import 'package:monkey/ast/ast.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:monkey/parser/parser.dart';

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

void testIntegerLiteral(Expression expression, int integerValue) {

    expect(expression, new isInstanceOf<IntegerLiteral>());
    IntegerLiteral literal = expression;

    expect(literal.value, equals(integerValue));
    expect(literal.tokenLiteral(), equals('$integerValue'));

}

void testPrefix(String input, String operator, int integerValue) {

    Program program = parseProgramChecked(input);

    expectNumStatements(program, 1);

    expect(program.statements.first, new isInstanceOf<ExpressionStatement>());
    ExpressionStatement statement = program.statements.first;

    expect(statement.expression, new isInstanceOf<PrefixExpression>());
    PrefixExpression expression = statement.expression;

    expect(expression.operator, equals(operator));
    testIntegerLiteral(expression.right, integerValue);

}

void testInfix(String input, int leftValue, String operator, int rightValue) {

    Program program = parseProgramChecked(input);

    expectNumStatements(program, 1);

    expect(program.statements.first, new isInstanceOf<ExpressionStatement>());
    ExpressionStatement statement = program.statements.first;

    expect(statement.expression, new isInstanceOf<InfixExpression>());
    InfixExpression expression = statement.expression;

    testIntegerLiteral(expression.left, leftValue);
    expect(expression.operator, equals(operator));
    testIntegerLiteral(expression.right, rightValue);

}

Program parseProgramChecked(String input) {

    Parser parser   = new Parser(new Lexer(input));
    Program program = parser.parseProgram();
    checkParserErrors(parser);

    return program;

}

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

    });

}