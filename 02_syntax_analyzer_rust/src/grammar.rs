use crate::{NonTerminal, Terminal};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Symbol {
    NonTerminal(NonTerminal),
    Terminal(Terminal),
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Production {
    pub left: NonTerminal,
    pub right: Vec<Symbol>, // Vetor vazio representa ε.
}

impl std::fmt::Display for Symbol {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NonTerminal(symbol) => write!(f, "{symbol}"),
            Self::Terminal(symbol) => write!(f, "{symbol}"),
        }
    }
}

impl std::fmt::Display for Production {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} ->", self.left)?;
        if self.right.is_empty() {
            write!(f, " ε")?;
        } else {
            for symbol in &self.right {
                write!(f, " {symbol}")?;
            }
        }
        Ok(())
    }
}

pub fn productions() -> Vec<Production> {
    use NonTerminal::*;
    use Symbol::{NonTerminal as N, Terminal as Term};
    use Terminal::*;

    let production = |left, right| Production { left, right };

    vec![
        // PROG -> public class id { public static void id ( ) { CMDS } }
        production(
            Prog,
            vec![
                Term(Public),
                Term(Class),
                Term(Id),
                Term(LBrace),
                Term(Public),
                Term(Static),
                Term(Void),
                Term(Id),
                Term(LParen),
                Term(RParen),
                Term(LBrace),
                N(Cmds),
                Term(RBrace),
                Term(RBrace),
            ],
        ),
        // CMDS -> CMD CMDS | ε
        production(Cmds, vec![N(Cmd), N(Cmds)]),
        production(Cmds, vec![]),
        // CMD -> DECL | ATRIB | IF_STMT
        production(Cmd, vec![N(Decl)]),
        production(Cmd, vec![N(Atrib)]),
        production(Cmd, vec![N(IfStmt)]),
        // DECL -> TIPO id ;
        production(Decl, vec![N(Tipo), Term(Id), Term(Semicolon)]),
        // TIPO -> int | float | char
        production(Tipo, vec![Term(Int)]),
        production(Tipo, vec![Term(Float)]),
        production(Tipo, vec![Term(Char)]),
        // ATRIB -> id = E ;
        production(Atrib, vec![Term(Id), Term(Assign), N(E), Term(Semicolon)]),
        // IF_STMT -> if ( COND ) { CMDS } SENAO
        production(
            IfStmt,
            vec![
                Term(If),
                Term(LParen),
                N(Cond),
                Term(RParen),
                Term(LBrace),
                N(Cmds),
                Term(RBrace),
                N(Senao),
            ],
        ),
        // SENAO -> else { CMDS } | ε
        production(Senao, vec![Term(Else), Term(LBrace), N(Cmds), Term(RBrace)]),
        production(Senao, vec![]),
        // COND -> E OP_REL E
        production(Cond, vec![N(E), N(OpRel), N(E)]),
        // OP_REL -> == | != | < | >
        production(OpRel, vec![Term(Eq)]),
        production(OpRel, vec![Term(Ne)]),
        production(OpRel, vec![Term(Lt)]),
        production(OpRel, vec![Term(Gt)]),
        // E -> T E'
        production(E, vec![N(T), N(EPrime)]),
        // E' -> + T E' | - T E' | ε
        production(EPrime, vec![Term(Plus), N(T), N(EPrime)]),
        production(EPrime, vec![Term(Minus), N(T), N(EPrime)]),
        production(EPrime, vec![]),
        // T -> F T'
        production(T, vec![N(F), N(TPrime)]),
        // T' -> * F T' | / F T' | ε
        production(TPrime, vec![Term(Star), N(F), N(TPrime)]),
        production(TPrime, vec![Term(Slash), N(F), N(TPrime)]),
        production(TPrime, vec![]),
        // F -> ( E ) | id | num
        production(F, vec![Term(LParen), N(E), Term(RParen)]),
        production(F, vec![Term(Id)]),
        production(F, vec![Term(Num)]),
    ]
}
