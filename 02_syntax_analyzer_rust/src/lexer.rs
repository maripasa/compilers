use std::ffi::{c_char, CStr, CString};
use std::os::unix::ffi::OsStrExt;
use std::path::Path;
use std::ptr::NonNull;

#[repr(C)]
struct LexerHandle {
    _private: [u8; 0],
}

#[repr(C)]
struct RawToken {
    kind: i32,
    lexeme: *mut c_char,
    attribute: u64,
    line: u64,
    column: u64,
}

unsafe extern "C" {
    fn lexer_open(filename: *const c_char) -> *mut LexerHandle;
    fn lexer_next(lexer: *mut LexerHandle, out: *mut RawToken) -> i32;
    fn lexer_token_free(token: *mut RawToken);
    fn lexer_close(lexer: *mut LexerHandle);
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Keyword {
    Public,
    Private,
    Protected,
    Class,
    Static,
    Void,
    Int,
    Float,
    Double,
    Char,
    Boolean,
    If,
    Else,
    While,
    For,
    Return,
    New,
    Break,
    Continue,
    This,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Operator {
    Plus,
    Minus,
    Star,
    Slash,
    Mod,
    Lt,
    Gt,
    Not,
    BitAnd,
    BitOr,
    BitXor,
    BitNot,
    Assign,
    Eq,
    Ne,
    Le,
    Ge,
    And,
    Or,
    Shl,
    Shr,
    Ushr,
    PlusAssign,
    MinusAssign,
    StarAssign,
    SlashAssign,
    ModAssign,
    AndAssign,
    OrAssign,
    XorAssign,
    ShlAssign,
    ShrAssign,
    UshrAssign,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Delimiter {
    Semicolon,
    Comma,
    Dot,
    LParen,
    RParen,
    LBrace,
    RBrace,
    LBracket,
    RBracket,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum TokenKind {
    Identifier,
    IntegerLiteral,
    RealLiteral,
    CharLiteral,
    StringLiteral,
    BooleanLiteral,
    NullLiteral,
    Error,
    Eof,
    Keyword(Keyword),
    Operator(Operator),
    Delimiter(Delimiter),
}

fn classify(code: i32, lexeme: &str) -> Result<TokenKind, String> {
    use TokenKind::*;
    let kind = match code {
        0 => Identifier,
        1 => IntegerLiteral,
        2 => RealLiteral,
        3 => CharLiteral,
        4 => StringLiteral,
        5 => BooleanLiteral,
        6 => NullLiteral,
        7 => Error,
        8 => Eof,
        9 => Keyword(match lexeme {
            "public" => self::Keyword::Public,
            "private" => self::Keyword::Private,
            "protected" => self::Keyword::Protected,
            "class" => self::Keyword::Class,
            "static" => self::Keyword::Static,
            "void" => self::Keyword::Void,
            "int" => self::Keyword::Int,
            "float" => self::Keyword::Float,
            "double" => self::Keyword::Double,
            "char" => self::Keyword::Char,
            "boolean" => self::Keyword::Boolean,
            "if" => self::Keyword::If,
            "else" => self::Keyword::Else,
            "while" => self::Keyword::While,
            "for" => self::Keyword::For,
            "return" => self::Keyword::Return,
            "new" => self::Keyword::New,
            "break" => self::Keyword::Break,
            "continue" => self::Keyword::Continue,
            "this" => self::Keyword::This,
            _ => return Err(format!("Palavra-chave desconhecida: {lexeme}")),
        }),
        10 => Operator(match lexeme {
            "+" => self::Operator::Plus,
            "-" => self::Operator::Minus,
            "*" => self::Operator::Star,
            "/" => self::Operator::Slash,
            "%" => self::Operator::Mod,
            "<" => self::Operator::Lt,
            ">" => self::Operator::Gt,
            "!" => self::Operator::Not,
            "&" => self::Operator::BitAnd,
            "|" => self::Operator::BitOr,
            "^" => self::Operator::BitXor,
            "~" => self::Operator::BitNot,
            "=" => self::Operator::Assign,
            "==" => self::Operator::Eq,
            "!=" => self::Operator::Ne,
            "<=" => self::Operator::Le,
            ">=" => self::Operator::Ge,
            "&&" => self::Operator::And,
            "||" => self::Operator::Or,
            "<<" => self::Operator::Shl,
            ">>" => self::Operator::Shr,
            ">>>" => self::Operator::Ushr,
            "+=" => self::Operator::PlusAssign,
            "-=" => self::Operator::MinusAssign,
            "*=" => self::Operator::StarAssign,
            "/=" => self::Operator::SlashAssign,
            "%=" => self::Operator::ModAssign,
            "&=" => self::Operator::AndAssign,
            "|=" => self::Operator::OrAssign,
            "^=" => self::Operator::XorAssign,
            "<<=" => self::Operator::ShlAssign,
            ">>=" => self::Operator::ShrAssign,
            ">>>=" => self::Operator::UshrAssign,
            _ => return Err(format!("Operador desconhecido: {lexeme}")),
        }),
        11 => Delimiter(match lexeme {
            ";" => self::Delimiter::Semicolon,
            "," => self::Delimiter::Comma,
            "." => self::Delimiter::Dot,
            "(" => self::Delimiter::LParen,
            ")" => self::Delimiter::RParen,
            "{" => self::Delimiter::LBrace,
            "}" => self::Delimiter::RBrace,
            "[" => self::Delimiter::LBracket,
            "]" => self::Delimiter::RBracket,
            _ => return Err(format!("Delimitador desconhecido: {lexeme}")),
        }),
        _ => return Err(format!("Tipo de token desconhecido: {code}")),
    };
    Ok(kind)
}

#[derive(Debug)]
pub struct Token {
    pub kind: TokenKind,
    pub lexeme: String,
    pub attribute: u64,
    pub line: u64,
    pub column: u64,
}

pub struct Lexer(NonNull<LexerHandle>);

impl Lexer {
    pub fn open(path: &Path) -> Result<Self, String> {
        let filename = CString::new(path.as_os_str().as_bytes())
            .map_err(|_| "O caminho contém um byte nulo".to_owned())?;
        let handle = unsafe { lexer_open(filename.as_ptr()) };
        NonNull::new(handle)
            .map(Self)
            .ok_or_else(|| format!("Não foi possível abrir {}", path.display()))
    }

    pub fn next_token(&mut self) -> Result<Option<Token>, String> {
        let mut raw = std::mem::MaybeUninit::<RawToken>::uninit();
        let result = unsafe { lexer_next(self.0.as_ptr(), raw.as_mut_ptr()) };
        match result {
            0 => Ok(None),
            1 => {
                let mut raw = unsafe { raw.assume_init() };
                let lexeme = unsafe { CStr::from_ptr(raw.lexeme) }
                    .to_string_lossy()
                    .into_owned();
                let kind = classify(raw.kind, &lexeme);
                unsafe { lexer_token_free(&mut raw) };
                let token = Token {
                    kind: kind?,
                    lexeme,
                    attribute: raw.attribute,
                    line: raw.line,
                    column: raw.column,
                };
                Ok(Some(token))
            }
            _ => Err("Falha interna ao ler o próximo token".to_owned()),
        }
    }
}

impl Drop for Lexer {
    fn drop(&mut self) {
        unsafe { lexer_close(self.0.as_ptr()) }
    }
}
