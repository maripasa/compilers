use std::collections::{HashMap, HashSet};

use crate::grammar::{Production, Symbol};
use crate::{NonTerminal, Terminal, NON_TERMINALS};

pub type MTable = HashMap<(NonTerminal, Terminal), usize>;
pub type FirstSets = HashMap<NonTerminal, HashSet<Terminal>>;
pub type FollowSets = HashMap<NonTerminal, HashSet<Terminal>>;

#[derive(Debug)]
pub struct GrammarAnalysis {
    pub productions: Vec<Production>,
    pub first: FirstSets,
    pub follow: FollowSets,
    pub nullable: HashSet<NonTerminal>,
    pub table: MTable,
}

#[derive(Default)]
pub struct SequenceFirst {
    pub terminals: HashSet<Terminal>,
    pub nullable: bool,
}

pub fn first_of_sequence(
    symbols: &[Symbol],
    first: &FirstSets,
    nullable: &HashSet<NonTerminal>,
) -> SequenceFirst {
    let mut result = SequenceFirst {
        nullable: true,
        ..SequenceFirst::default()
    };
    for symbol in symbols {
        match symbol {
            Symbol::Terminal(terminal) => {
                result.terminals.insert(*terminal);
                result.nullable = false;
                break;
            }
            Symbol::NonTerminal(non_terminal) => {
                result.terminals.extend(first[non_terminal].iter().copied());
                if !nullable.contains(non_terminal) {
                    result.nullable = false;
                    break;
                }
            }
        }
    }
    result
}

pub fn calculate_first(productions: &[Production]) -> (FirstSets, HashSet<NonTerminal>) {
    let mut first: FirstSets = NON_TERMINALS
        .into_iter()
        .map(|non_terminal| (non_terminal, HashSet::new()))
        .collect();
    let mut nullable = HashSet::new();

    loop {
        let mut changed = false;
        for production in productions {
            let sequence = first_of_sequence(&production.right, &first, &nullable);
            changed |= first
                .get_mut(&production.left)
                .unwrap()
                .extend_and_report(sequence.terminals);
            if sequence.nullable {
                changed |= nullable.insert(production.left);
            }
        }
        if !changed {
            return (first, nullable);
        }
    }
}

pub fn calculate_follow(
    productions: &[Production],
    first: &FirstSets,
    nullable: &HashSet<NonTerminal>,
) -> FollowSets {
    let mut follow: FollowSets = NON_TERMINALS
        .into_iter()
        .map(|non_terminal| (non_terminal, HashSet::new()))
        .collect();
    follow
        .get_mut(&NonTerminal::Prog)
        .unwrap()
        .insert(Terminal::Eof);

    loop {
        let mut changed = false;
        for production in productions {
            for (position, symbol) in production.right.iter().enumerate() {
                let Symbol::NonTerminal(non_terminal) = symbol else {
                    continue;
                };
                let suffix = first_of_sequence(&production.right[position + 1..], first, nullable);
                let inherited = if suffix.nullable {
                    follow[&production.left].clone()
                } else {
                    HashSet::new()
                };
                let target = follow.get_mut(non_terminal).unwrap();
                changed |= target.extend_and_report(suffix.terminals);
                changed |= target.extend_and_report(inherited);
            }
        }
        if !changed {
            return follow;
        }
    }
}

trait ExtendAndReport<T> {
    fn extend_and_report(&mut self, items: impl IntoIterator<Item = T>) -> bool;
}

impl<T: Eq + std::hash::Hash> ExtendAndReport<T> for HashSet<T> {
    fn extend_and_report(&mut self, items: impl IntoIterator<Item = T>) -> bool {
        let mut changed = false;
        for item in items {
            changed |= self.insert(item);
        }
        changed
    }
}

pub fn build_m_table(
    productions: &[Production],
    first: &FirstSets,
    follow: &FollowSets,
    nullable: &HashSet<NonTerminal>,
) -> Result<MTable, String> {
    let mut table = MTable::new();
    for (index, production) in productions.iter().enumerate() {
        let sequence = first_of_sequence(&production.right, first, nullable);
        let mut lookaheads = sequence.terminals;
        if sequence.nullable {
            lookaheads.extend(follow[&production.left].iter().copied());
        }
        for lookahead in lookaheads {
            let key = (production.left, lookahead);
            if let Some(previous) = table.insert(key, index) {
                if previous != index {
                    return Err(format!(
                        "Conflito LL(1) em M[{}, {}]: '{}' e '{}'",
                        production.left, lookahead, productions[previous], production
                    ));
                }
            }
        }
    }
    Ok(table)
}

impl GrammarAnalysis {
    pub fn new(productions: Vec<Production>) -> Result<Self, String> {
        let (first, nullable) = calculate_first(&productions);
        let follow = calculate_follow(&productions, &first, &nullable);
        let table = build_m_table(&productions, &first, &follow, &nullable)?;
        Ok(Self {
            productions,
            first,
            follow,
            nullable,
            table,
        })
    }
}
