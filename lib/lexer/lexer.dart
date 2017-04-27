library lexer;

import 'package:monkey/token/token.dart';

class Lexer {

    /// Code points for whitespace characters
    static final int space    = code(' ');
    static final int tab      = code('\t');
    static final int newline  = code('\n');
    static final int carriage = code('\r');

    /// Code points for numeric characters
    static final int zero     = code('0');
    static final int nine     = code('9');

    /// Code points for alpha characters and _
    static final int a = code('a');
    static final int z = code('z');
    static final int A = code('A');
    static final int Z = code('Z');
    static final int _ = code('_');

    /// Code point for null character \0
    static final int nil = code('␀');

    String input;

    /// current position in input (points to current char)
    int position = 0;

    /// current reading position in input (after current char)
    int readPosition = 0;

    /// current char under examination
    String ch;

    Lexer(this.input) {

        readChar();

    }

    void readChar() {

        if (readPosition >= input.length) {
            ch = '␀';
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
                if (peekChar() == '=') {
                    String temp = ch;
                    readChar();
                    token = new Token(Token.Equal, temp + ch);
                } else {
                    token = new Token(Token.Assign, ch);
                }
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
            case '-':
                token = new Token(Token.Minus, ch);
                break;
            case '!':
                if (peekChar() == '=') {
                    String temp = ch;
                    readChar();
                    token = new Token(Token.NotEqual, temp + ch);
                } else {
                    token = new Token(Token.Bang, ch);
                }
                break;
            case '/':
                token = new Token(Token.Slash, ch);
                break;
            case '*':
                token = new Token(Token.Asterisk, ch);
                break;
            case '<':
                token = new Token(Token.Lt, ch);
                break;
            case '>':
                token = new Token(Token.Gt, ch);
                break;
            case '{':
                token = new Token(Token.LeftBrace, ch);
                break;
            case '}':
                token = new Token(Token.RightBrace, ch);
                break;
            case '␀':
                token = new Token(Token.Eof, ch);
                break;
            default:
                if (isDigit(ch)) {
                    return new Token(Token.Int, readInteger());
                } else if (isAlpha(ch)) {
                    return readIdentifier();
                }

                return new Token(Token.Illegal, ch);

        }

        readChar();
        return token;

    }

    bool isAlpha(String ch) {

        int c = ch.codeUnitAt(0);

        return c >= a && c <= z || c >= A && c <= Z || c == _;

    }

    bool isAlphaNumeric(String ch) {

        return isAlpha(ch) || isDigit(ch);

    }

    bool isAtEnd() {

        int c = ch.codeUnitAt(0);

        return c == nil;

    }

    bool isDigit(String ch) {

        int c = ch.codeUnitAt(0);

        return c >= zero && c <= nine;

    }

    bool isWhitespace(String ch) {

        int c = ch.codeUnitAt(0);

        return c == space || c == tab || c == newline || c == carriage;

    }

    String peekChar() {

        if (readPosition >= input.length) {
            return null;
        } else {
            return input[readPosition];
        }

    }

    Token readIdentifier() {

        int start = position;

        while(isAlphaNumeric(ch) && !isAtEnd()) {
            readChar();
        }

        String literal = input.substring(start, position);

        return new Token(Token.lookupIdent(literal), literal);

    }

    String readInteger() {

        int start = position;

        while (isDigit(ch) && !isAtEnd()) {
            readChar();
        }

        return input.substring(start, position);

    }

    void skipWhitespace() {

        while (isWhitespace(ch) && !isAtEnd()) {
            readChar();
        }

    }

    static int code(String ch) {

        return ch.codeUnitAt(0);

    }

}