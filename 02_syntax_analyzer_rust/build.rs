use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

fn run(command: &mut Command) {
    let status = command
        .status()
        .expect("não foi possível executar ferramenta LLVM");
    assert!(status.success(), "falha ao compilar o lexer: {command:?}");
}

fn main() {
    let root = PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").unwrap());
    let llvm = root.join("../01_lexical_analyzer/llvm");
    let out = PathBuf::from(env::var_os("OUT_DIR").unwrap());
    let lexer_ir = out.join("lexer.ll");

    for file in ["lexer_source.c", "lexer_api.h", "reader.ll", "tables.ll"] {
        println!("cargo:rerun-if-changed={}", llvm.join(file).display());
    }

    run(Command::new("clang")
        .arg("-S")
        .arg("-emit-llvm")
        .arg("-O0")
        .arg("-I")
        .arg(&llvm)
        .arg("-o")
        .arg(&lexer_ir)
        .arg(llvm.join("lexer_source.c")));

    let reader_ir = llvm.join("reader.ll");
    let tables_ir = llvm.join("tables.ll");
    let inputs: [&Path; 3] = [&lexer_ir, &reader_ir, &tables_ir];
    let mut objects = Vec::new();
    for (index, input) in inputs.iter().enumerate() {
        let object = out.join(format!("lexer_{index}.o"));
        run(Command::new("clang")
            .arg("-c")
            .arg(input)
            .arg("-o")
            .arg(&object));
        objects.push(object);
    }

    let archive = out.join("libcompilers_lexer.a");
    let mut ar = Command::new("ar");
    ar.arg("crs").arg(&archive).args(&objects);
    run(&mut ar);

    println!("cargo:rustc-link-search=native={}", out.display());
    println!("cargo:rustc-link-lib=static=compilers_lexer");
}
