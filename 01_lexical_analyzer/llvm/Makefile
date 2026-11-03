CLANG ?= clang
LLVM_LINK ?= llvm-link
LLI ?= lli

.PHONY: build run clean

build: lexer.bc

lexer.ll: lexer_source.c lexer_api.h
	$(CLANG) -S -emit-llvm -O0 -o $@ $<

lexer.bc: reader.ll tables.ll lexer.ll main.ll
	$(LLVM_LINK) reader.ll tables.ll lexer.ll main.ll -o $@

run: lexer.bc
	$(LLI) lexer.bc $(FILE)

clean:
	rm -f lexer.bc
