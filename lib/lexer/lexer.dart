library lexer;

import 'package:monkey/token/token.dart';

class Lexer {

    // Code points for whitespace characters
    static final int space    = code(' ');
    static final int tab      = code('\t');
    static final int newline  = code('\n');
    static final int carriage = code('\r');

    String input;

    // current position in input (points to current char)
    int position = 0;

    // current reading position in input (after current char)
    int readPosition = 0;

    // current char under examination
    String ch;

    Lexer(this.input) {

        readChar();

    }

    void readChar() {

        if (readPosition >= input.length) {
            ch = '\0';
        } else {
            ch = input[readPosition];
        }

        position = readPosition;
        readPosition += 1;

    }

    Token nextToken() {

        skipWhitespace();

        Token token;

        switch (ch) {

            case '=':
                token = new Token(Token.Assign, ch);
                break;
            case ';':
                token = new Token(Token.SemiColon, ch);
                break;
            case '(':
                token = new Token(Token.LeftParen, ch);
                break;
            case ')':
                token = new Token(Token.RightParen, ch);
                break;
            case ',':
                token = new Token(Token.Comma, ch);
                break;
            case '+':
                token = new Token(Token.Plus, ch);
                break;
            case '{':
                token = new Token(Token.LeftBrace, ch);
                break;
            case '}':
                token = new Token(Token.RightBrace, ch);
                break;
            case '\0':
                token = new Token(Token.Eof, ch);
                break;

        }

        readChar();
        return token;

    }

    void skipWhitespace() {

        while (isWhitespace(ch)) {
            readChar();
        }

    }

    bool isWhitespace(String ch) {

        int c = ch.codeUnitAt(0);

        return c == space || c == tab || c == newline || c == carriage;

    }

    static int code(String ch) {

        return ch.codeUnitAt(0);

    }

}