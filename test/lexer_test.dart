import 'package:test/test.dart';
import 'package:monkey/token/token.dart';
import 'package:monkey/lexer/lexer.dart';

Token t(String tokenType, String literal) {

    return new Token(tokenType, literal);

}

void testLexer(List<Token> expected, String input) {

    Lexer lexer = new Lexer(input);

    for (int i = 0; i < expected.length; i++) {

        Token expectedToken = expected[i];
        Token actualToken   = lexer.nextToken();

        expect(actualToken.tokenType, expectedToken.tokenType, reason: "tests[$i] - tokentype wrong.");
        expect(actualToken.literal, expectedToken.literal, reason: "tests[$i] - literal wrong.");

    }

}

void main() {

    test("monkey language tokens", () {

        String input = """
            let five = 5;
            let ten  = 10;
            let add = fn(x, y) {
                x + y;
            };
            let result = add(five, ten);
            !-/*5;
            5 < 10 > 5;

            if (5 < 10) {
                return true;
            } else {
                return false;
            }

            10 == 10;
            10 != 9;
        """;

        List<Token> expected = [
            t(Token.Let, "let"),
            t(Token.Ident,"five"),
            t(Token.Assign, "="),
            t(Token.Int, "5"),
            t(Token.SemiColon, ";"),
            t(Token.Let, "let"),
            t(Token.Ident,"ten"),
            t(Token.Assign, "="),
            t(Token.Int, "10"),
            t(Token.SemiColon, ";"),
            t(Token.Let, "let"),
            t(Token.Ident,"add"),
            t(Token.Assign, "="),
            t(Token.Function, "fn"),
            t(Token.LeftParen, "("),
            t(Token.Ident, "x"),
            t(Token.Comma, ","),
            t(Token.Ident, "y"),
            t(Token.RightParen, ")"),
            t(Token.LeftBrace, "{"),
            t(Token.Ident, "x"),
            t(Token.Plus, "+"),
            t(Token.Ident, "y"),
            t(Token.SemiColon, ";"),
            t(Token.RightBrace, "}"),
            t(Token.SemiColon, ";"),
            t(Token.Let, "let"),
            t(Token.Ident,"result"),
            t(Token.Assign, "="),
            t(Token.Ident,"add"),
            t(Token.LeftParen, "("),
            t(Token.Ident, "five"),
            t(Token.Comma, ","),
            t(Token.Ident, "ten"),
            t(Token.RightParen, ")"),
            t(Token.SemiColon, ";"),
            t(Token.Bang, "!"),
            t(Token.Minus, "-"),
            t(Token.Slash, "/"),
            t(Token.Asterisk, "*"),
            t(Token.Int, "5"),
            t(Token.SemiColon, ";"),
            t(Token.Int, "5"),
            t(Token.Lt, "<"),
            t(Token.Int, "10"),
            t(Token.Gt, ">"),
            t(Token.Int, "5"),
            t(Token.SemiColon, ";"),
            t(Token.If, "if"),
            t(Token.LeftParen, "("),
            t(Token.Int, "5"),
            t(Token.Lt, "<"),
            t(Token.Int, "10"),
            t(Token.RightParen, ")"),
            t(Token.LeftBrace, "{"),
            t(Token.Return, "return"),
            t(Token.True, "true"),
            t(Token.SemiColon, ";"),
            t(Token.RightBrace, "}"),
            t(Token.Else, "else"),
            t(Token.LeftBrace, "{"),
            t(Token.Return, "return"),
            t(Token.False, "false"),
            t(Token.SemiColon, ";"),
            t(Token.RightBrace, "}"),
            t(Token.Int, "10"),
            t(Token.Equal, "=="),
            t(Token.Int, "10"),
            t(Token.SemiColon, ";"),
            t(Token.Int, "10"),
            t(Token.NotEqual, "!="),
            t(Token.Int, "9"),
            t(Token.SemiColon, ";"),
            t(Token.Eof, "␀")
        ];

        testLexer(expected, input);

    });

}