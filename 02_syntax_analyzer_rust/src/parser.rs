use crate::grammar::Symbol;
use crate::lexer::{Token, TokenKind};
use crate::table::GrammarAnalysis;
use crate::{terminal_for, NonTerminal, Terminal, TERMINALS};

pub struct InputToken {
    pub source: Token,
    pub terminal: Option<Terminal>,
}

impl From<Token> for InputToken {
    fn from(source: Token) -> Self {
        let terminal = terminal_for(source.kind);
        Self { source, terminal }
    }
}

pub struct TraceStep {
    pub stack: String,
    pub input: String,
    pub action: String,
}

pub struct ParseReport {
    pub trace: Vec<TraceStep>,
    pub errors: Vec<String>,
    pub tree: DerivationTree,
    pub accepted: bool,
}

#[derive(Clone, Copy)]
struct StackEntry {
    symbol: Symbol,
    node: Option<usize>,
}

struct TreeNode {
    symbol: Option<Symbol>, // None é ε.
    lexeme: Option<String>,
    children: Vec<usize>,
}

pub struct DerivationTree {
    nodes: Vec<TreeNode>,
}

impl DerivationTree {
    fn new() -> Self {
        Self {
            nodes: vec![TreeNode {
                symbol: Some(Symbol::NonTerminal(NonTerminal::Prog)),
                lexeme: None,
                children: Vec::new(),
            }],
        }
    }

    pub fn preorder(&self) -> String {
        fn visit(tree: &DerivationTree, index: usize, depth: usize, lines: &mut Vec<String>) {
            let node = &tree.nodes[index];
            let label = match node.symbol {
                Some(symbol) => symbol.to_string(),
                None => "ε".to_owned(),
            };
            let suffix = node
                .lexeme
                .as_ref()
                .map_or(String::new(), |lexeme| format!(" ({lexeme:?})"));
            lines.push(format!("{}{}{}", "  ".repeat(depth), label, suffix));
            for child in &node.children {
                visit(tree, *child, depth + 1, lines);
            }
        }
        let mut lines = Vec::new();
        visit(self, 0, 0, &mut lines);
        lines.join("\n")
    }
}

fn current_label(token: &InputToken) -> String {
    if token.source.kind == TokenKind::Eof {
        "$".to_owned()
    } else {
        format!("{:?} ({:?})", token.source.kind, token.source.lexeme)
    }
}

fn expected_for(non_terminal: NonTerminal, analysis: &GrammarAnalysis) -> String {
    let expected: Vec<String> = TERMINALS
        .iter()
        .filter(|terminal| analysis.table.contains_key(&(non_terminal, **terminal)))
        .map(ToString::to_string)
        .collect();
    expected.join(", ")
}

fn stack_label(stack: &[StackEntry]) -> String {
    stack
        .iter()
        .map(|entry| entry.symbol.to_string())
        .collect::<Vec<_>>()
        .join(" ")
}

fn input_label(input: &[InputToken], position: usize) -> String {
    input[position..]
        .iter()
        .map(|token| {
            token.terminal.map_or_else(
                || format!("{:?}", token.source.kind),
                |terminal| terminal.to_string(),
            )
        })
        .collect::<Vec<_>>()
        .join(" ")
}

pub fn parse(analysis: &GrammarAnalysis, input: &[InputToken]) -> ParseReport {
    let mut tree = DerivationTree::new();
    let mut trace = Vec::new();
    let mut errors = Vec::new();
    let mut stack = vec![
        StackEntry {
            symbol: Symbol::Terminal(Terminal::Eof),
            node: None,
        },
        StackEntry {
            symbol: Symbol::NonTerminal(NonTerminal::Prog),
            node: Some(0),
        },
    ];
    let mut position = 0;

    if input.last().and_then(|token| token.terminal) != Some(Terminal::Eof) {
        errors.push("Entrada sem marcador EOF do lexer".to_owned());
        return ParseReport {
            trace,
            errors,
            tree,
            accepted: false,
        };
    }

    while let Some(top) = stack.last().copied() {
        let Some(current) = input.get(position) else {
            break;
        };
        let stack_before = stack_label(&stack);
        let input_before = input_label(input, position);
        let action;

        match top.symbol {
            Symbol::NonTerminal(non_terminal) => {
                if let Some(index) = current
                    .terminal
                    .and_then(|terminal| analysis.table.get(&(non_terminal, terminal)))
                {
                    let production = &analysis.productions[*index];
                    stack.pop();
                    if let Some(parent) = top.node {
                        if production.right.is_empty() {
                            let child = tree.nodes.len();
                            tree.nodes.push(TreeNode {
                                symbol: None,
                                lexeme: None,
                                children: Vec::new(),
                            });
                            tree.nodes[parent].children.push(child);
                        } else {
                            let mut children = Vec::new();
                            for symbol in &production.right {
                                let child = tree.nodes.len();
                                tree.nodes.push(TreeNode {
                                    symbol: Some(*symbol),
                                    lexeme: None,
                                    children: Vec::new(),
                                });
                                children.push(child);
                            }
                            tree.nodes[parent].children.extend(&children);
                            for (symbol, child) in production.right.iter().zip(children).rev() {
                                stack.push(StackEntry {
                                    symbol: *symbol,
                                    node: Some(child),
                                });
                            }
                        }
                    }
                    action = format!(
                        "M[{non_terminal}, {}] = {production}",
                        current.terminal.unwrap()
                    );
                } else {
                    let error = format!(
                        "{}:{}: erro sintático: encontrado {}; esperava-se {} para derivar {}",
                        current.source.line,
                        current.source.column,
                        current_label(current),
                        expected_for(non_terminal, analysis),
                        non_terminal
                    );
                    errors.push(error.clone());
                    if current.terminal == Some(Terminal::Eof)
                        || current.terminal.is_some_and(|terminal| {
                            analysis.follow[&non_terminal].contains(&terminal)
                        })
                    {
                        stack.pop();
                        action = format!("{error}; sincronizar: retirar {non_terminal} da pilha");
                    } else {
                        position += 1;
                        action = format!("{error}; modo pânico: descartar token");
                    }
                }
            }
            Symbol::Terminal(expected) => {
                if current.terminal == Some(expected) {
                    stack.pop();
                    if let Some(node) = top.node {
                        tree.nodes[node].lexeme = Some(current.source.lexeme.clone());
                    }
                    position += 1;
                    action = format!("casar {expected}");
                } else {
                    let error =
                        format!(
                        "{}:{}: erro sintático: encontrado {}; esperava-se '{}' no topo da pilha",
                        current.source.line, current.source.column, current_label(current), expected
                    );
                    errors.push(error.clone());
                    if expected == Terminal::Eof || current.terminal.is_none() {
                        position += 1;
                        action = format!("{error}; modo pânico: descartar token");
                    } else {
                        stack.pop();
                        action = format!("{error}; modo pânico: inserir '{expected}'");
                    }
                }
            }
        }

        trace.push(TraceStep {
            stack: stack_before,
            input: input_before,
            action,
        });
    }

    let accepted = errors.is_empty() && stack.is_empty() && position == input.len();
    if !accepted && errors.is_empty() {
        errors.push("Erro sintático: análise terminou antes de consumir toda a entrada".to_owned());
    }
    ParseReport {
        trace,
        errors,
        tree,
        accepted,
    }
}
