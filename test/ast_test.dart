import 'package:test/test.dart';

import 'package:monkey/ast/ast.dart';
import 'package:monkey/token/token.dart';

Identifier ident(String name) => new Identifier(new Token(Token.Ident, name), name);

void main() {

    test('test program.toString()', () {

        Program program = new Program()
            ..statements = [
                new LetStatement(new Token(Token.Let, 'let'))
                    ..name = ident('myVar')
                    ..value = ident('anotherVar')
            ];

        expect(program.toString(), equals('let myVar = anotherVar;'));

    });

}