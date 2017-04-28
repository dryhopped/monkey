import 'package:test/test.dart';

import 'package:monkey/ast/ast.dart';
import 'helpers.dart';

void main() {

    test('test let statements', () {

        testLetStatementParsing('let x = 5;', 'x', 5);
        testLetStatementParsing('let y = true;', 'y', true);
        testLetStatementParsing('let foobar = y;', 'foobar', 'y');

    });

    test('test return statements', () {

        testReturnStatementParsing('return 5;', 5);
        testReturnStatementParsing('return true;', true);
        testReturnStatementParsing('return foobar;', 'foobar');

    });

    test('test identifier expression', () {

        ExpressionStatement statement = parseExpressionStatement('foobar;');
        expect(statement.expression, new isInstanceOf<Identifier>());

        Identifier ident = statement.expression;
        expect(ident.value, equals('foobar'));
        expect(ident.tokenLiteral(), equals('foobar'));

    });

    test('test literal integer expression', () {

        ExpressionStatement statement = parseExpressionStatement('5;');
        testIntegerLiteral(statement.expression, 5);

    });

    test('test parsing prefix expressions', () {

        testPrefix('!5;', '!', 5);
        testPrefix('-15;', '-', 15);
        testPrefix('!foobar;', '!', 'foobar');
        testPrefix('-foobar;', '-', 'foobar');
        testPrefix('!true;', '!', true);
        testPrefix('!false;', '!', false);

    });

    test('test parsing infix expressions', () {

        testInfix('5 + 5;', 5, '+', 5);
        testInfix('5 - 5;', 5, '-', 5);
        testInfix('5 * 5;', 5, '*', 5);
        testInfix('5 / 5;', 5, '/', 5);
        testInfix('5 > 5;', 5, '>', 5);
        testInfix('5 < 5;', 5, '<', 5);
        testInfix('5 == 5;', 5, '==', 5);
        testInfix('5 != 5;', 5, '!=', 5);
        testInfix('foobar + barfoo;', 'foobar', '+', 'barfoo');
        testInfix('foobar - barfoo;', 'foobar', '-', 'barfoo');
        testInfix('foobar * barfoo;', 'foobar', '*', 'barfoo');
        testInfix('foobar / barfoo;', 'foobar', '/', 'barfoo');
        testInfix('foobar > barfoo;', 'foobar', '>', 'barfoo');
        testInfix('foobar < barfoo;', 'foobar', '<', 'barfoo');
        testInfix('foobar == barfoo;', 'foobar', '==', 'barfoo');
        testInfix('foobar != barfoo;', 'foobar', '!=', 'barfoo');
        testInfix('true == true', true, '==', true);
        testInfix('true != false', true, '!=', false);
        testInfix('false == false', false, '==', false);

    });

    test('test operator precedence parsing', () {

        testPrecedence('-a * b', '((-a) * b)');
        testPrecedence('!-a', '(!(-a))');
        testPrecedence('a + b + c', '((a + b) + c)');
        testPrecedence('a * b * c', '((a * b) * c)');
        testPrecedence('a * b / c', '((a * b) / c)');
        testPrecedence('a + b / c', '(a + (b / c))');
        testPrecedence('a + b * c + d / e - f', '(((a + (b * c)) + (d / e)) - f)');
        testPrecedence('3 + 4; -5 * 5', '(3 + 4)((-5) * 5)');
        testPrecedence('5 > 4 == 3 < 4', '((5 > 4) == (3 < 4))');
        testPrecedence('5 < 4 != 3 > 4', '((5 < 4) != (3 > 4))');
        testPrecedence('3 + 4 * 5 == 3 * 1 + 4 * 5', '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))');
        testPrecedence('true', 'true');
        testPrecedence('false', 'false');
        testPrecedence('3 > 5 == false', '((3 > 5) == false)');
        testPrecedence('3 < 5 == true', '((3 < 5) == true)');
        testPrecedence('1 + (2 + 3) + 4', '((1 + (2 + 3)) + 4)');
        testPrecedence('2 / (5 + 5)', '(2 / (5 + 5))');
        testPrecedence('(5 + 5) * 2 * (5 + 5)', '(((5 + 5) * 2) * (5 + 5))');
        testPrecedence('-(5 + 5)', '(-(5 + 5))');
        testPrecedence('!(true == true)', '(!(true == true))');
        testPrecedence('a + add(b * c) + d', '((a + add((b * c))) + d)');
        testPrecedence('add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))', 'add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))');
        testPrecedence('add(a + b + c * d / f + g)', 'add((((a + b) + ((c * d) / f)) + g))');

    });

    test('test boolean expression', () {

        testBooleanParsing('true;', true);
        testBooleanParsing('false;', false);

    });

    test('test if expression', () {

        ExpressionStatement statement = parseExpressionStatement('if (x < y) { x }');
        expect(statement.expression, new isInstanceOf<IfExpression>());

        IfExpression expression = statement.expression;
        testInfixExpression(expression.condition, 'x', '<', 'y');
        expect(expression.consequence.statements.length, equals(1));

        ExpressionStatement consequence = expression.consequence.statements.first;
        testIdentifier(consequence.expression, 'x');

        expect(expression.alternative, isNull);

    });

    test('test if/else expression', () {

        ExpressionStatement statement = parseExpressionStatement('if (x < y) { x } else { y }');
        expect(statement.expression, new isInstanceOf<IfExpression>());

        IfExpression expression = statement.expression;
        testInfixExpression(expression.condition, 'x', '<', 'y');
        expect(expression.consequence.statements.length, equals(1));

        ExpressionStatement consequence = expression.consequence.statements.first;
        testIdentifier(consequence.expression, 'x');
        expect(expression.alternative.statements.length, equals(1));

        ExpressionStatement alternative = expression.alternative.statements.first;
        testIdentifier(alternative.expression, 'y');

    });

    test('test function literal parsing', () {

        ExpressionStatement statement = parseExpressionStatement('fn(x, y) { x + y; }');
        expect(statement.expression, new isInstanceOf<FunctionLiteral>());

        FunctionLiteral function = statement.expression;
        testLiteralExpression(function.parameters[0], 'x');
        testLiteralExpression(function.parameters[1], 'y');

        expect(function.body.statements.length, equals(1));
        expect(function.body.statements.first, new isInstanceOf<ExpressionStatement>());

        ExpressionStatement body = function.body.statements.first;
        testInfixExpression(body.expression, 'x', '+', 'y');

    });

    test('test function parameter parsing', () {

        testFunctionParameters('fn() {};', []);
        testFunctionParameters('fn(x) {};', ['x']);
        testFunctionParameters('fn(x, y) {};', ['x', 'y']);
        testFunctionParameters('fn(x, y, z) {};', ['x', 'y', 'z']);

    });

    test('test call expression parsing', () {

        ExpressionStatement statement = parseExpressionStatement('add(1, 2 * 3, 4 + 5);');
        expect(statement.expression, new isInstanceOf<CallExpression>());

        CallExpression call = statement.expression;
        testIdentifier(call.function, 'add');

        expect(call.arguments, hasLength(3));

        testLiteralExpression(call.arguments[0], 1);
        testInfixExpression(call.arguments[1], 2, '*', 3);
        testInfixExpression(call.arguments[2], 4, '+', 5);

    });

}