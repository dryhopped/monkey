enum Precedence {
    _,
    Lowest,
    /// == !=
    Equals,
    /// > <
    LessGreater,
    /// + -
    Sum,
    /// * /
    Product,
    /// -x !x
    Prefix,
    /// myFunction(x)
    Call
}