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
    expect(numStatements, equals(3), reason: "program.statements does not contain 3 statements. got=$numStatements.");

}

void main() {

    test("test let statements", () {

        String input = """
            let x = 5;
            let y = 10;
            let foobar = 838383;
        """;

        Parser parser   = new Parser(new Lexer(input));
        Program program = parser.parseProgram();
        checkParserErrors(parser);

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

        String input = """
            return 5;
            return 10;
            return 993322;
        """;

        Parser parser   = new Parser(new Lexer(input));
        Program program = parser.parseProgram();
        checkParserErrors(parser);

        expect(program, isNotNull, reason: "parseProgram() returned null");
        expectNumStatements(program, 3);

        List<String> identifiers = ['x', 'y', 'foobar'];

        program.statements.forEach((statement) {

            expect(statement, new isInstanceOf<ReturnStatement>());
            expect(statement.tokenLiteral(), equals('return'));

        });

    });

}