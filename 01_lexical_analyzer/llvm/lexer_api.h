#ifndef LEXER_API_H
#define LEXER_API_H

#include <stdint.h>

typedef struct Lexer Lexer;

typedef struct {
    int32_t type;
    char *lexeme;
    uint64_t attribute;
    uint64_t line;
    uint64_t column;
} LexerToken;

enum {
    LEXER_IDENTIFIER,
    LEXER_INTEGER_LITERAL,
    LEXER_REAL_LITERAL,
    LEXER_CHAR_LITERAL,
    LEXER_STRING_LITERAL,
    LEXER_BOOLEAN_LITERAL,
    LEXER_NULL_LITERAL,
    LEXER_ERROR,
    LEXER_EOF,
    LEXER_KEYWORD,
    LEXER_OPERATOR,
    LEXER_DELIMITER
};

/* Each call returns one token: 1 = token, 0 = after EOF, -1 = failure.
 * The caller owns token.lexeme and must call lexer_token_free for each token.
 * EOF itself is returned once with type LEXER_EOF. */
Lexer *lexer_open(const char *filename);
int32_t lexer_next(Lexer *lexer, LexerToken *out);
void lexer_token_free(LexerToken *token);
void lexer_close(Lexer *lexer);

#endif
