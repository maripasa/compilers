/* Handwritten scanner. Compile with clang -S -emit-llvm -O0 -o lexer.ll lexer_source.c.
 * reader.ll and tables.ll supply the two-buffer reader and symbol table. */
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { void *file, *b0, *b1; bool active; uint64_t forward;
                 bool begin_buffer; uint64_t begin; uint64_t valid0, valid1;
                 bool eof, collecting; int32_t error; } Reader;
typedef struct { const char *first; uint64_t n1; const char *second; uint64_t n2; } Lexeme;
typedef struct { char *name; uint64_t count; } Symbol;
typedef struct { Symbol *items; uint64_t length, capacity; } SymbolTable;
typedef struct { int32_t type; char *lexeme; uint64_t attribute, line, column; } Token;
typedef struct { Token *items; uint64_t length, capacity; } TokenStream;

extern Reader *reader_init(Reader *, const char *);
extern void reader_destroy(Reader *);
extern int reader_peek(Reader *);
extern void reader_step(Reader *);
extern void reader_begin(Reader *);
extern bool reader_lexeme(Reader *, Lexeme *);
extern bool symbol_table_init(SymbolTable *);
extern uint64_t symbol_table_add(SymbolTable *, const char *);
extern void symbol_table_destroy(SymbolTable *);
extern bool token_stream_init(TokenStream *);
extern void token_stream_destroy(TokenStream *);

enum { IDENTIFIER, INTEGER_LITERAL, REAL_LITERAL, CHAR_LITERAL,
       STRING_LITERAL, BOOLEAN_LITERAL, NULL_LITERAL, ERROR_TOKEN, END_TOKEN,
       KEYWORD, OPERATOR, DELIMITER };
static const char *type_names[] = {
    "IDENTIFIER", "INTEGER_LITERAL", "REAL_LITERAL", "CHAR_LITERAL",
    "STRING_LITERAL", "BOOLEAN_LITERAL", "NULL_LITERAL", "ERROR", "EOF",
    "KEYWORD", "OPERATOR", "DELIMITER"
};
static const char *keywords[] = {
    "public", "private", "protected", "class", "static", "void", "int",
    "float", "double", "char", "boolean", "if", "else", "while", "for",
    "return", "new", "break", "continue", "this", 0
};
static const char *operators[] = {
    ">>>=", "<<=", ">>=", ">>>", "<<", ">>", "==", "!=", "<=", ">=",
    "&&", "||", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=",
    "+", "-", "*", "/", "%", "<", ">", "!", "&", "|", "^", "~", "=", 0
};

typedef struct { Reader reader; SymbolTable symbols; TokenStream tokens;
                 uint64_t line, column, start_line, start_column, errors; } Scanner;

static void begin(Scanner *s) {
    s->start_line = s->line;
    s->start_column = s->column;
    reader_begin(&s->reader);
}

static int peek(Scanner *s) { return reader_peek(&s->reader); }
static void step(Scanner *s) {
    int c = peek(s);
    if (c < 0) return;
    reader_step(&s->reader);
    if (c == '\n') { s->line++; s->column = 1; }
    else s->column++;
}
static bool letter(int c) { return (c >= 'a' && c <= 'z') ||
    (c >= 'A' && c <= 'Z') || c == '_'; }
static bool digit(int c) { return c >= '0' && c <= '9'; }
static bool alnum(int c) { return letter(c) || digit(c); }
static bool space(int c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r'; }
static bool delimiter(int c) { return c == ';' || c == ',' || c == '.' ||
    c == '(' || c == ')' || c == '{' || c == '}' || c == '[' || c == ']'; }
static bool escape(int c) { return c == 'b' || c == 't' || c == 'n' || c == 'f' ||
    c == 'r' || c == '"' || c == '\'' || c == '\\'; }
static bool keyword(const char *s) {
    for (int i = 0; keywords[i]; i++) if (!strcmp(s, keywords[i])) return true;
    return false;
}
static bool operator_prefix(const char *s, size_t n) {
    for (int i = 0; operators[i]; i++)
        if (strlen(operators[i]) >= n && !strncmp(s, operators[i], n)) return true;
    return false;
}
static bool operator_exact(const char *s) {
    for (int i = 0; operators[i]; i++) if (!strcmp(s, operators[i])) return true;
    return false;
}
static char *copy_lexeme(Lexeme *l) {
    size_t n = (size_t)(l->n1 + l->n2);
    char *s = malloc(n + 1);
    if (!s) return NULL;
    memcpy(s, l->first, (size_t)l->n1);
    if (l->n2) memcpy(s + l->n1, l->second, (size_t)l->n2);
    s[n] = 0;
    return s;
}
static bool emit(Scanner *s, int type, const char *message) {
    Lexeme span;
    if (!reader_lexeme(&s->reader, &span)) return false;
    char *lexeme = copy_lexeme(&span);
    if (!lexeme) return false;
    uint64_t attribute = 0;
    if (type == IDENTIFIER) {
        attribute = symbol_table_add(&s->symbols, lexeme);
        if (attribute == UINT64_MAX) { free(lexeme); return false; }
    } else if (type == INTEGER_LITERAL) attribute = (uint64_t)strtoll(lexeme, 0, 10);
    else if (type == REAL_LITERAL) {
        double value = strtod(lexeme, 0);
        memcpy(&attribute, &value, sizeof value);
    }
    if (s->tokens.length == s->tokens.capacity) {
        uint64_t capacity = s->tokens.capacity * 2;
        Token *items = realloc(s->tokens.items, capacity * sizeof *items);
        if (!items) { free(lexeme); return false; }
        s->tokens.items = items;
        s->tokens.capacity = capacity;
    }
    s->tokens.items[s->tokens.length++] =
        (Token){ type, lexeme, attribute, s->start_line, s->start_column };
    if (message) {
        s->errors++;
        fprintf(stderr, "Erro lexico na linha %llu, coluna %llu: %s (%s)\n",
            (unsigned long long)s->start_line, (unsigned long long)s->start_column,
            message, lexeme);
    }
    return true;
}
static bool comment_error(Scanner *s, const char *message) {
    if (s->tokens.length == s->tokens.capacity) {
        uint64_t capacity = s->tokens.capacity * 2;
        Token *items = realloc(s->tokens.items, capacity * sizeof *items);
        if (!items) return false;
        s->tokens.items = items; s->tokens.capacity = capacity;
    }
    char *lexeme = malloc(3);
    if (!lexeme) return false;
    memcpy(lexeme, "/*", 3);
    s->tokens.items[s->tokens.length++] =
        (Token){ERROR_TOKEN, lexeme, 0, s->start_line, s->start_column};
    s->errors++;
    fprintf(stderr, "Erro lexico na linha %llu, coluna %llu: %s\n",
        (unsigned long long)s->start_line, (unsigned long long)s->start_column, message);
    return true;
}
static bool scan_word(Scanner *s) {
    do { step(s); } while (alnum(peek(s)));
    Lexeme span;
    if (!reader_lexeme(&s->reader, &span)) return false;
    char *word = copy_lexeme(&span);
    if (!word) return false;
    /* reader_lexeme closes collection; restart at the original span by classifying
       before emission through a separate helper. */
    int type = !strcmp(word,"true") || !strcmp(word,"false") ? BOOLEAN_LITERAL :
               !strcmp(word,"null") ? NULL_LITERAL : keyword(word) ? KEYWORD : IDENTIFIER;
    uint64_t attribute = 0;
    if (type == IDENTIFIER) {
        attribute = symbol_table_add(&s->symbols, word);
        if (attribute == UINT64_MAX) { free(word); return false; }
    }
    if (s->tokens.length == s->tokens.capacity) {
        uint64_t capacity = s->tokens.capacity * 2;
        Token *items = realloc(s->tokens.items, capacity * sizeof *items);
        if (!items) { free(word); return false; }
        s->tokens.items = items; s->tokens.capacity = capacity;
    }
    s->tokens.items[s->tokens.length++] =
        (Token){type, word, attribute, s->start_line, s->start_column};
    return true;
}
static bool scan_number(Scanner *s, bool leading_dot) {
    bool real = leading_dot, bad = false;
    if (leading_dot) step(s);
    while (digit(peek(s))) step(s);
    if (!leading_dot && peek(s) == '.') {
        real = true; step(s);
        while (digit(peek(s))) step(s);
    }
    if (peek(s) == ',' || peek(s) == '.') {
        int mark = peek(s);
        step(s);
        if (digit(peek(s))) {
            bad = true;
            while (digit(peek(s)) || letter(peek(s)) || peek(s) == '.') step(s);
        } else if (mark == '.' && !bad) {
            /* A trailing dot belongs to a malformed number here. */
            bad = true;
        } else bad = true;
    }
    if (letter(peek(s))) {
        bad = true;
        do { step(s); } while (alnum(peek(s)));
    }
    return emit(s, bad ? ERROR_TOKEN : real ? REAL_LITERAL : INTEGER_LITERAL,
                bad ? "numero ou identificador invalido" : NULL);
}
static bool scan_quoted(Scanner *s, int quote) {
    bool bad = false, closed = false;
    int count = 0;
    step(s);
    while (peek(s) >= 0 && peek(s) != '\n' && peek(s) != '\r') {
        int c = peek(s);
        if (c == quote) { step(s); closed = true; break; }
        if (c == '\\') {
            step(s);
            if (!escape(peek(s))) { bad = true; if (peek(s) < 0) break; }
            else count++;
            step(s);
        } else { count++; step(s); }
    }
    if (!closed || (quote == '\'' && count != 1)) bad = true;
    return emit(s, bad ? ERROR_TOKEN : quote == '\'' ? CHAR_LITERAL : STRING_LITERAL,
                bad ? "literal invalido ou nao terminado" : NULL);
}
static bool scan_operator(Scanner *s) {
    char word[5] = {0}; size_t n = 0;
    while (n < 4 && peek(s) >= 0) {
        word[n] = (char)peek(s);
        if (!operator_prefix(word, n + 1)) break;
        step(s); n++;
    }
    word[n] = 0;
    return emit(s, operator_exact(word) ? OPERATOR : ERROR_TOKEN,
                operator_exact(word) ? NULL : "operador invalido");
}
static int scan(Scanner *s) {
    for (;;) {
        int c = peek(s);
        if (c == -1) break;
        if (c < -1) { fprintf(stderr,"Erro de leitura: %d\n",c); return 1; }
        if (space(c)) { step(s); continue; }
        if (c == '/') {
            /* A comment is recognized without collecting a lexeme; arbitrarily long
               comments can therefore cross any number of buffer boundaries. */
            begin(s); step(s);
            int next = peek(s);
            /* Restore by treating slash via the operator path unless this is a
               comment.  The reader has no rewind, so this branch is handled below. */
            if (next == '/' || next == '*') {
                reader_lexeme(&s->reader, &(Lexeme){0});
                step(s);
                if (next == '/') { while (peek(s) >= 0 && peek(s) != '\n') step(s); continue; }
                int previous = 0, closed = 0, nested = 0;
                while (peek(s) >= 0) {
                    int x = peek(s); step(s);
                    if (previous == '/' && x == '*') nested = 1;
                    if (previous == '*' && x == '/') { closed = 1; break; }
                    previous = x;
                }
                if ((!closed || nested) && !comment_error(s,
                    nested ? "comentario aninhado" : "comentario nao terminado")) return 1;
                continue;
            }
            /* Slash was already consumed; complete / or /= from the open span. */
            if (next == '=') step(s);
            if (!emit(s, OPERATOR, NULL)) return 1;
            continue;
        }
        begin(s);
        bool ok;
        if (letter(c)) ok = scan_word(s);
        else if (digit(c)) ok = scan_number(s, false);
        else if (c == '\'' || c == '"') ok = scan_quoted(s, c);
        else if (c == '.') {
            step(s);
            if (digit(peek(s))) {
                while (digit(peek(s))) step(s);
                ok = emit(s, REAL_LITERAL, NULL);
            } else ok = emit(s, DELIMITER, NULL);
        } else if (delimiter(c)) { step(s); ok = emit(s, DELIMITER, NULL); }
        else if (operator_prefix((char[]){(char)c,0},1)) ok = scan_operator(s);
        else { step(s); ok = emit(s, ERROR_TOKEN, "caractere invalido"); }
        if (!ok) return 1;
    }
    if (s->tokens.length == s->tokens.capacity) {
        uint64_t capacity = s->tokens.capacity * 2;
        Token *items = realloc(s->tokens.items, capacity * sizeof *items);
        if (!items) return 1;
        s->tokens.items = items; s->tokens.capacity = capacity;
    }
    char *end = malloc(1);
    if (!end) return 1;
    end[0] = 0;
    s->tokens.items[s->tokens.length++] =
        (Token){ END_TOKEN, end, 0, s->line, s->column };
    return 0;
}
static void show(Scanner *s) {
    puts("TABELA DE TOKENS\nTIPO\tLEXEMA\tATRIBUTO\tLINHA\tCOLUNA");
    for (uint64_t i = 0; i < s->tokens.length; i++) {
        Token *t = &s->tokens.items[i];
        if (t->type == KEYWORD) {
            for (const char *p = t->lexeme; *p; p++)
                putchar(*p >= 'a' && *p <= 'z' ? *p - 32 : *p);
        } else if (t->type == OPERATOR || t->type == DELIMITER) {
            static const char *spelling[] = {
                "+", "-", "*", "/", "%", "==", "!=", "<", "<=", ">", ">=",
                "&&", "||", "!", "&", "|", "^", "~", "<<", ">>", ">>>",
                "=", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=",
                "<<=", ">>=", ">>>=", ";", ",", ".", "(", ")", "{", "}", "[", "]", NULL
            };
            static const char *names[] = {
                "PLUS", "MINUS", "STAR", "SLASH", "MOD", "EQ", "NE", "LT", "LE", "GT", "GE",
                "AND", "OR", "NOT", "BIT_AND", "BIT_OR", "BIT_XOR", "BIT_NOT", "SHL", "SHR", "USHR",
                "ASSIGN", "PLUS_ASSIGN", "MINUS_ASSIGN", "STAR_ASSIGN", "SLASH_ASSIGN", "MOD_ASSIGN",
                "AND_ASSIGN", "OR_ASSIGN", "XOR_ASSIGN", "SHL_ASSIGN", "SHR_ASSIGN", "USHR_ASSIGN",
                "SEMICOLON", "COMMA", "DOT", "LPAREN", "RPAREN", "LBRACE", "RBRACE", "LBRACKET", "RBRACKET"
            };
            int i = 0;
            while (spelling[i] && strcmp(spelling[i], t->lexeme)) i++;
            fputs(spelling[i] ? names[i] : "ERROR", stdout);
        } else fputs(type_names[t->type], stdout);
        printf("\t%s\t", t->type == END_TOKEN ? "-" : t->lexeme);
        if (t->type == IDENTIFIER) printf("%llu", (unsigned long long)t->attribute);
        else if (t->type == INTEGER_LITERAL) printf("%lld", (long long)t->attribute);
        else if (t->type == REAL_LITERAL) {
            double value; memcpy(&value, &t->attribute, sizeof value); printf("%g", value);
        } else printf("-");
        printf("\t%llu\t%llu\n", (unsigned long long)t->line,
               (unsigned long long)t->column);
    }
    puts("\nTABELA DE SIMBOLOS\nINDICE\tIDENTIFICADOR\tOCORRENCIAS");
    for (uint64_t i = 0; i < s->symbols.length; i++)
        printf("%llu\t%s\t%llu\n", (unsigned long long)i,
               s->symbols.items[i].name, (unsigned long long)s->symbols.items[i].count);
}
int lexer_main(int argc, char **argv) {
    if (argc != 2) { fprintf(stderr,"Uso: lexer arquivo.java\n"); return 2; }
    Scanner s = {.line = 1, .column = 1};
    if (!symbol_table_init(&s.symbols)) return 1;
    if (!token_stream_init(&s.tokens)) { symbol_table_destroy(&s.symbols); return 1; }
    if (!reader_init(&s.reader, argv[1])) {
        fprintf(stderr,"Nao foi possivel abrir %s\n",argv[1]);
        token_stream_destroy(&s.tokens); symbol_table_destroy(&s.symbols); return 1;
    }
    int status = scan(&s);
    if (!status) show(&s);
    reader_destroy(&s.reader);
    for (uint64_t i = 0; i < s.tokens.length; i++) free(s.tokens.items[i].lexeme);
    token_stream_destroy(&s.tokens);
    symbol_table_destroy(&s.symbols);
    return status || s.errors ? 1 : 0;
}
