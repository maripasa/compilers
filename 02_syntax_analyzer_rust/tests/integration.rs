use std::path::Path;

use syntax_analyzer::grammar;
use syntax_analyzer::parser::{parse, InputToken};
use syntax_analyzer::table::GrammarAnalysis;
use syntax_analyzer::{Lexer, NonTerminal, Terminal};

fn analyze(path: &str) -> syntax_analyzer::parser::ParseReport {
    let analysis = GrammarAnalysis::new(grammar::productions()).unwrap();
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("examples")
        .join(path);
    let mut lexer = Lexer::open(&path).unwrap();
    let mut input = Vec::new();
    loop {
        let token = lexer.next_token().unwrap().unwrap();
        let end = token.kind == syntax_analyzer::TokenKind::Eof;
        input.push(InputToken::from(token));
        if end {
            break;
        }
    }
    parse(&analysis, &input)
}

#[test]
fn calculates_first_follow_and_table() {
    let analysis = GrammarAnalysis::new(grammar::productions()).unwrap();
    assert_eq!(analysis.productions.len(), 30);
    assert!(analysis.first[&NonTerminal::Tipo].contains(&Terminal::Int));
    assert!(analysis.nullable.contains(&NonTerminal::EPrime));
    assert!(analysis.follow[&NonTerminal::Cmds].contains(&Terminal::RBrace));
    assert!(analysis
        .table
        .contains_key(&(NonTerminal::T, Terminal::Num)));
    let epsilon = analysis.table[&(NonTerminal::EPrime, Terminal::Semicolon)];
    assert!(analysis.productions[epsilon].right.is_empty());
}

#[test]
fn accepts_assignment_success_example() {
    let report = analyze("Exemplo1_Sucesso.java");
    assert!(report.accepted, "{:?}", report.errors);
    assert!(report.tree.preorder().starts_with("PROG\n"));
    assert!(report.trace.iter().any(|step| step.action == "casar $"));
}

#[test]
fn reports_empty_m_cell() {
    let report = analyze("Exemplo2_ErroTabela.java");
    assert!(!report.accepted);
    assert!(report
        .errors
        .iter()
        .any(|error| error.contains("derivar T") && error.contains("RParen")));
}

#[test]
fn reports_terminal_stack_mismatch() {
    let report = analyze("Exemplo3_ErroPilha.java");
    assert!(!report.accepted);
    assert!(report
        .errors
        .iter()
        .any(|error| error.contains("esperava-se ')' no topo da pilha")));
}

#[test]
fn recovers_and_reports_multiple_errors() {
    let report = analyze("Exemplo4_MultiplosErros.java");
    assert!(!report.accepted);
    assert!(report
        .errors
        .iter()
        .any(|error| error.contains("derivar T")));
    assert!(report
        .errors
        .iter()
        .any(|error| error.contains("esperava-se ')'")));
}
