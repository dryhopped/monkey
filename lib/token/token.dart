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

                 // Delimiters
                 Comma      = ",",
                 SemiColon  = ";",

                 LeftParen  = "(",
                 RightParen = ")",
                 LeftBrace  = "{",
                 RightBrace = "}",

                 // Keywords
                 Function   = "Function",
                 Let        = "Let";

    String tokenType;
    String literal;

    Token(this.tokenType, this.literal);

    bool operator ==(o) =>
        o is Token && o.tokenType == tokenType && o.literal == literal;

}