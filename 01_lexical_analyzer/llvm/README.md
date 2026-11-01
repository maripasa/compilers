# Analisador léxico

O algoritmo de varredura foi escrito manualmente em `lexer_source.c`, sem gerador
léxico. O `Makefile` compila essa lógica para `lexer.ll` (LLVM IR) e a liga com
`reader.ll`, `tables.ll` e `main.ll` em `lexer.bc`.

```sh
make build
lli lexer.bc examples/success.java
lli lexer.bc examples/error.java
```

O leitor preserva o modelo de dois buffers. A saída mostra a tabela de tokens
(tipo, lexema, atributo, linha e coluna) e a tabela de símbolos (identificador e
número de ocorrências). O token `EOF` é incluído no fluxo ao fim do arquivo.

O arquivo `.bc` é gerado localmente. O parser em Rust ainda não foi implementado.
