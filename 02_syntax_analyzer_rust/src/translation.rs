use crate::lexer::{Delimiter, Keyword, Operator, TokenKind};

use crate::Terminal;

// Converte os tipos do lexer para os terminais permitidos pelo Trabalho 2.
pub fn terminal_for(kind: TokenKind) -> Option<Terminal> {
    Some(match kind {
        TokenKind::Identifier => Terminal::Id,
        TokenKind::IntegerLiteral | TokenKind::RealLiteral => Terminal::Num,
        TokenKind::Eof => Terminal::Eof,
        TokenKind::Keyword(keyword) => match keyword {
            Keyword::Public => Terminal::Public,
            Keyword::Class => Terminal::Class,
            Keyword::Static => Terminal::Static,
            Keyword::Void => Terminal::Void,
            Keyword::Int => Terminal::Int,
            Keyword::Float => Terminal::Float,
            Keyword::Char => Terminal::Char,
            Keyword::If => Terminal::If,
            Keyword::Else => Terminal::Else,
            _ => return None,
        },
        TokenKind::Operator(operator) => match operator {
            Operator::Plus => Terminal::Plus,
            Operator::Minus => Terminal::Minus,
            Operator::Star => Terminal::Star,
            Operator::Slash => Terminal::Slash,
            Operator::Assign => Terminal::Assign,
            Operator::Eq => Terminal::Eq,
            Operator::Ne => Terminal::Ne,
            Operator::Lt => Terminal::Lt,
            Operator::Gt => Terminal::Gt,
            _ => return None,
        },
        TokenKind::Delimiter(delimiter) => match delimiter {
            Delimiter::LParen => Terminal::LParen,
            Delimiter::RParen => Terminal::RParen,
            Delimiter::LBrace => Terminal::LBrace,
            Delimiter::RBrace => Terminal::RBrace,
            Delimiter::Semicolon => Terminal::Semicolon,
            _ => return None,
        },
        _ => return None,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn maps_numeric_literals_and_rejects_literals_outside_the_grammar() {
        assert_eq!(terminal_for(TokenKind::IntegerLiteral), Some(Terminal::Num));
        assert_eq!(terminal_for(TokenKind::RealLiteral), Some(Terminal::Num));
        assert_eq!(terminal_for(TokenKind::CharLiteral), None);
    }
}
