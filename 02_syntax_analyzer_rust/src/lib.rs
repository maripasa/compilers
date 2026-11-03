pub mod grammar;
pub mod lexer;
pub mod parser;
pub mod table;
mod translation;

pub use lexer::{tokenize, TokenKind};
pub use translation::terminal_for;

pub const NON_TERMINALS: [NonTerminal; 15] = [
    NonTerminal::Prog,
    NonTerminal::Cmds,
    NonTerminal::Cmd,
    NonTerminal::Decl,
    NonTerminal::Tipo,
    NonTerminal::Atrib,
    NonTerminal::IfStmt,
    NonTerminal::Senao,
    NonTerminal::Cond,
    NonTerminal::OpRel,
    NonTerminal::E,
    NonTerminal::EPrime,
    NonTerminal::T,
    NonTerminal::TPrime,
    NonTerminal::F,
];

pub const TERMINALS: [Terminal; 26] = [
    Terminal::Public,
    Terminal::Class,
    Terminal::Static,
    Terminal::Void,
    Terminal::Int,
    Terminal::Float,
    Terminal::Char,
    Terminal::If,
    Terminal::Else,
    Terminal::Id,
    Terminal::Num,
    Terminal::Plus,
    Terminal::Minus,
    Terminal::Star,
    Terminal::Slash,
    Terminal::Assign,
    Terminal::Eq,
    Terminal::Ne,
    Terminal::Lt,
    Terminal::Gt,
    Terminal::LParen,
    Terminal::RParen,
    Terminal::LBrace,
    Terminal::RBrace,
    Terminal::Semicolon,
    Terminal::Eof,
];

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum NonTerminal {
    Prog,
    Cmds,
    Cmd,
    Decl,
    Tipo,
    Atrib,
    IfStmt,
    Senao,
    Cond,
    OpRel,
    E,
    EPrime,
    T,
    TPrime,
    F,
}

// Terminais da gramática do Trabalho 2. Num reúne literais inteiros e reais.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Terminal {
    Public,
    Class,
    Static,
    Void,
    Int,
    Float,
    Char,
    If,
    Else,
    Id,
    Num,
    Plus,
    Minus,
    Star,
    Slash,
    Assign,
    Eq,
    Ne,
    Lt,
    Gt,
    LParen,
    RParen,
    LBrace,
    RBrace,
    Semicolon,
    Eof,
}

impl std::fmt::Display for NonTerminal {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let name = match self {
            Self::Prog => "PROG",
            Self::Cmds => "CMDS",
            Self::Cmd => "CMD",
            Self::Decl => "DECL",
            Self::Tipo => "TIPO",
            Self::Atrib => "ATRIB",
            Self::IfStmt => "IF_STMT",
            Self::Senao => "SENAO",
            Self::Cond => "COND",
            Self::OpRel => "OP_REL",
            Self::E => "E",
            Self::EPrime => "E'",
            Self::T => "T",
            Self::TPrime => "T'",
            Self::F => "F",
        };
        f.write_str(name)
    }
}

impl std::fmt::Display for Terminal {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let name = match self {
            Self::Public => "public",
            Self::Class => "class",
            Self::Static => "static",
            Self::Void => "void",
            Self::Int => "int",
            Self::Float => "float",
            Self::Char => "char",
            Self::If => "if",
            Self::Else => "else",
            Self::Id => "id",
            Self::Num => "num",
            Self::Plus => "+",
            Self::Minus => "-",
            Self::Star => "*",
            Self::Slash => "/",
            Self::Assign => "=",
            Self::Eq => "==",
            Self::Ne => "!=",
            Self::Lt => "<",
            Self::Gt => ">",
            Self::LParen => "(",
            Self::RParen => ")",
            Self::LBrace => "{",
            Self::RBrace => "}",
            Self::Semicolon => ";",
            Self::Eof => "$",
        };
        f.write_str(name)
    }
}
