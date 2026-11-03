use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

use syntax_analyzer::grammar;
use syntax_analyzer::parser::{parse, InputToken};
use syntax_analyzer::table::GrammarAnalysis;
use syntax_analyzer::{Lexer, NonTerminal, Terminal, NON_TERMINALS, TERMINALS};

fn format_set(non_terminal: NonTerminal, analysis: &GrammarAnalysis, first: bool) -> String {
    let set = if first {
        &analysis.first[&non_terminal]
    } else {
        &analysis.follow[&non_terminal]
    };
    let mut values: Vec<String> = TERMINALS
        .iter()
        .filter(|terminal| set.contains(terminal))
        .map(|terminal| match terminal {
            Terminal::RBrace | Terminal::LBrace => format!("'{terminal}'"),
            _ => terminal.to_string(),
        })
        .collect();
    if first && analysis.nullable.contains(&non_terminal) {
        values.push("ε".to_owned());
    }
    format!("{{ {} }}", values.join(", "))
}

fn print_grammar_analysis(analysis: &GrammarAnalysis) {
    println!("=== FIRST e FOLLOW ===");
    for non_terminal in NON_TERMINALS {
        println!(
            "{non_terminal:<8} FIRST = {:<45} FOLLOW = {}",
            format_set(non_terminal, analysis, true),
            format_set(non_terminal, analysis, false)
        );
    }
    println!("\n=== Tabela M (células preenchidas) ===");
    for non_terminal in NON_TERMINALS {
        for terminal in TERMINALS {
            if let Some(index) = analysis.table.get(&(non_terminal, terminal)) {
                println!(
                    "M[{non_terminal}, {terminal}] = {}",
                    analysis.productions[*index]
                );
            }
        }
    }
}

fn run(source: PathBuf) -> Result<ExitCode, String> {
    if !source.is_file() {
        return Err(format!(
            "Arquivo-fonte não encontrado: {}",
            source.display()
        ));
    }
    let analysis = GrammarAnalysis::new(grammar::productions())?;
    let input: Vec<InputToken> = Lexer::open(&source)?
        .tokenize()?
        .into_iter()
        .map(InputToken::from)
        .collect();

    println!("=== Tokens do lexer ===");
    for token in &input {
        println!(
            "{}:{} {:<24} {:?}",
            token.source.line,
            token.source.column,
            format!("{:?}", token.source.kind),
            token.source.lexeme
        );
    }
    println!();
    print_grammar_analysis(&analysis);

    let report = parse(&analysis, &input);
    println!("\n=== Trace: pilha | entrada | ação ===");
    for (step, entry) in report.trace.iter().enumerate() {
        println!("{:>3}. Pilha: {}", step + 1, entry.stack);
        println!("     Entrada: {}", entry.input);
        println!("     Ação: {}", entry.action);
    }

    if report.accepted {
        println!("\n=== Árvore de derivação (pré-ordem) ===");
        println!("{}", report.tree.preorder());
        println!("\nAceito com sucesso: programa sintaticamente válido.");
        Ok(ExitCode::SUCCESS)
    } else {
        println!("\n=== Erros sintáticos ===");
        for error in &report.errors {
            println!("{error}");
        }
        println!("\nRejeitado: {} erro(s) sintático(s).", report.errors.len());
        Ok(ExitCode::from(1))
    }
}

fn main() -> ExitCode {
    let mut args = env::args_os();
    let program = args.next().unwrap_or_default();
    let Some(source) = args.next() else {
        eprintln!(
            "Uso: {} <arquivo-fonte.java>",
            PathBuf::from(program).display()
        );
        return ExitCode::from(2);
    };
    if args.next().is_some() {
        eprintln!("Forneça apenas um arquivo-fonte .java");
        return ExitCode::from(2);
    }
    match run(PathBuf::from(source)) {
        Ok(code) => code,
        Err(error) => {
            eprintln!("{error}");
            ExitCode::from(1)
        }
    }
}
