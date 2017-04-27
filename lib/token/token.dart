library token;

class Token {

    static const Illegal    = "Illegal",
                 Eof        = "Eof",

                 // Identifiers + Literals
                 Ident      = "Ident", // add, foobar, x, y, ...
                 Int        = "Int",   // 123456

                 // Operators
                 Assign     = "=",
                 Plus       = "+",
                 Minus      = "-",
                 Bang       = "!",
                 Slash      = "/",
                 Asterisk   = "*",
                 Lt         = "<",
                 Gt         = ">",
                 Equal      = "==",
                 NotEqual   = "!=",

                 // Delimiters
                 Comma      = ",",
                 SemiColon  = ";",

                 LeftParen  = "(",
                 RightParen = ")",
                 LeftBrace  = "{",
                 RightBrace = "}",

                 // Keywords
                 Else       = "Else",
                 False      = "False",
                 Function   = "Function",
                 If         = "If",
                 Let        = "Let",
                 Return     = "Return",
                 True       = "True";

    static const Map<String, String> keywords = const {
        "else":   Token.Else,
        "false":  Token.False,
        "fn":     Token.Function,
        "if":     Token.If,
        "let":    Token.Let,
        "return": Token.Return,
        "true":   Token.True
    };

    String tokenType;
    String literal;

    Token(this.tokenType, this.literal);

    bool operator ==(o) =>
        o is Token && o.tokenType == tokenType && o.literal == literal;

    @override
    String toString() {

        return 'Token<type: $tokenType, literal: $literal>';

    }

    static String lookupIdent(String ident) {

        String value = keywords[ident];

        return value == null ? Token.Ident : value;

    }

}