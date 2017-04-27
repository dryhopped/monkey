library lexer;

import 'package:monkey/token/token.dart';

class Lexer {

    // Code points for whitespace characters
    static final int space    = code(' ');
    static final int tab      = code('\t');
    static final int newline  = code('\n');
    static final int carriage = code('\r');
    static final int zero     = code('0');
    static final int nine     = code('9');

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
            default:
                if (isDigit(ch)) {
                    return new Token(Token.Int, readInteger());
                }

                return new Token(Token.Illegal, ch);

        }

        readChar();
        return token;

    }

    bool isDigit(String ch) {

        // TODO: Figure out how to get lexer to detect \0 as null character instead of numeric 0
        int c = ch.codeUnitAt(0);

        return c >= zero && c <= nine;

    }

    bool isWhitespace(String ch) {

        int c = ch.codeUnitAt(0);

        return c == space || c == tab || c == newline || c == carriage;

    }

    String readInteger() {

        int start = position;

        while (isDigit(ch)) {
            readChar();
        }

        return input.substring(start, position);

    }

    void skipWhitespace() {

        while (isWhitespace(ch)) {
            readChar();
        }

    }

    static int code(String ch) {

        return ch.codeUnitAt(0);

    }

}