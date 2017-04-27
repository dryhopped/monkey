import 'package:monkey/token/token.dart';
import 'package:monkey/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {

    test("test lexer with input =+(){},;", () {

        String input = "=+(){},;";

        List<Token> expected = [
            new Token(Token.Assign,     "="),
            new Token(Token.Plus,       "+"),
            new Token(Token.LeftParen,  "("),
            new Token(Token.RightParen, ")"),
            new Token(Token.LeftBrace,  "{"),
            new Token(Token.RightBrace, "}"),
            new Token(Token.Comma,      ","),
            new Token(Token.SemiColon,  ";"),
            new Token(Token.Eof,        "\0")
        ];

        Lexer lexer = new Lexer(input);

        for (int i = 0; i < expected.length; i++) {

            Token expectedToken = expected[i];
            Token actualToken   = lexer.nextToken();

            expect(actualToken.tokenType, expectedToken.tokenType, reason: "tests[$i] - tokentype wrong.");
            expect(actualToken.literal, expectedToken.literal, reason: "tests[$i] - literal wrong.");

        }

    });

}