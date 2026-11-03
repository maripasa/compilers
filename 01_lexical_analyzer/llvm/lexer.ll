; ModuleID = 'lexer_source.c'
source_filename = "lexer_source.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Lexer = type { %struct.Reader, %struct.SymbolTable, %struct.TokenStream, i64, i64, i64, i64, i64, i8 }
%struct.Reader = type { ptr, ptr, ptr, i8, i64, i8, i64, i64, i64, i8, i8, i32 }
%struct.SymbolTable = type { ptr, i64, i64 }
%struct.TokenStream = type { ptr, i64, i64 }
%struct.LexerToken = type { i32, ptr, i64, i64, i64 }
%struct.Lexeme = type { ptr, i64, ptr, i64 }
%struct.Symbol = type { ptr, i64 }

@stderr = external global ptr, align 8
@.str = private unnamed_addr constant [25 x i8] c"Uso: lexer arquivo.java\0A\00", align 1
@.str.1 = private unnamed_addr constant [27 x i8] c"Nao foi possivel abrir %s\0A\00", align 1
@.str.2 = private unnamed_addr constant [21 x i8] c"Erro de leitura: %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [20 x i8] c"comentario aninhado\00", align 1
@.str.4 = private unnamed_addr constant [25 x i8] c"comentario nao terminado\00", align 1
@.str.5 = private unnamed_addr constant [19 x i8] c"caractere invalido\00", align 1
@.str.6 = private unnamed_addr constant [3 x i8] c"/*\00", align 1
@.str.7 = private unnamed_addr constant [44 x i8] c"Erro lexico na linha %llu, coluna %llu: %s\0A\00", align 1
@.str.8 = private unnamed_addr constant [49 x i8] c"Erro lexico na linha %llu, coluna %llu: %s (%s)\0A\00", align 1
@.str.9 = private unnamed_addr constant [5 x i8] c"true\00", align 1
@.str.10 = private unnamed_addr constant [6 x i8] c"false\00", align 1
@.str.11 = private unnamed_addr constant [5 x i8] c"null\00", align 1
@keywords = internal global [21 x ptr] [ptr @.str.12, ptr @.str.13, ptr @.str.14, ptr @.str.15, ptr @.str.16, ptr @.str.17, ptr @.str.18, ptr @.str.19, ptr @.str.20, ptr @.str.21, ptr @.str.22, ptr @.str.23, ptr @.str.24, ptr @.str.25, ptr @.str.26, ptr @.str.27, ptr @.str.28, ptr @.str.29, ptr @.str.30, ptr @.str.31, ptr null], align 16
@.str.12 = private unnamed_addr constant [7 x i8] c"public\00", align 1
@.str.13 = private unnamed_addr constant [8 x i8] c"private\00", align 1
@.str.14 = private unnamed_addr constant [10 x i8] c"protected\00", align 1
@.str.15 = private unnamed_addr constant [6 x i8] c"class\00", align 1
@.str.16 = private unnamed_addr constant [7 x i8] c"static\00", align 1
@.str.17 = private unnamed_addr constant [5 x i8] c"void\00", align 1
@.str.18 = private unnamed_addr constant [4 x i8] c"int\00", align 1
@.str.19 = private unnamed_addr constant [6 x i8] c"float\00", align 1
@.str.20 = private unnamed_addr constant [7 x i8] c"double\00", align 1
@.str.21 = private unnamed_addr constant [5 x i8] c"char\00", align 1
@.str.22 = private unnamed_addr constant [8 x i8] c"boolean\00", align 1
@.str.23 = private unnamed_addr constant [3 x i8] c"if\00", align 1
@.str.24 = private unnamed_addr constant [5 x i8] c"else\00", align 1
@.str.25 = private unnamed_addr constant [6 x i8] c"while\00", align 1
@.str.26 = private unnamed_addr constant [4 x i8] c"for\00", align 1
@.str.27 = private unnamed_addr constant [7 x i8] c"return\00", align 1
@.str.28 = private unnamed_addr constant [4 x i8] c"new\00", align 1
@.str.29 = private unnamed_addr constant [6 x i8] c"break\00", align 1
@.str.30 = private unnamed_addr constant [9 x i8] c"continue\00", align 1
@.str.31 = private unnamed_addr constant [5 x i8] c"this\00", align 1
@.str.32 = private unnamed_addr constant [33 x i8] c"numero ou identificador invalido\00", align 1
@.str.33 = private unnamed_addr constant [34 x i8] c"literal invalido ou nao terminado\00", align 1
@operators = internal global [34 x ptr] [ptr @.str.34, ptr @.str.35, ptr @.str.36, ptr @.str.37, ptr @.str.38, ptr @.str.39, ptr @.str.40, ptr @.str.41, ptr @.str.42, ptr @.str.43, ptr @.str.44, ptr @.str.45, ptr @.str.46, ptr @.str.47, ptr @.str.48, ptr @.str.49, ptr @.str.50, ptr @.str.51, ptr @.str.52, ptr @.str.53, ptr @.str.54, ptr @.str.55, ptr @.str.56, ptr @.str.57, ptr @.str.58, ptr @.str.59, ptr @.str.60, ptr @.str.61, ptr @.str.62, ptr @.str.63, ptr @.str.64, ptr @.str.65, ptr @.str.66, ptr null], align 16
@.str.34 = private unnamed_addr constant [5 x i8] c">>>=\00", align 1
@.str.35 = private unnamed_addr constant [4 x i8] c"<<=\00", align 1
@.str.36 = private unnamed_addr constant [4 x i8] c">>=\00", align 1
@.str.37 = private unnamed_addr constant [4 x i8] c">>>\00", align 1
@.str.38 = private unnamed_addr constant [3 x i8] c"<<\00", align 1
@.str.39 = private unnamed_addr constant [3 x i8] c">>\00", align 1
@.str.40 = private unnamed_addr constant [3 x i8] c"==\00", align 1
@.str.41 = private unnamed_addr constant [3 x i8] c"!=\00", align 1
@.str.42 = private unnamed_addr constant [3 x i8] c"<=\00", align 1
@.str.43 = private unnamed_addr constant [3 x i8] c">=\00", align 1
@.str.44 = private unnamed_addr constant [3 x i8] c"&&\00", align 1
@.str.45 = private unnamed_addr constant [3 x i8] c"||\00", align 1
@.str.46 = private unnamed_addr constant [3 x i8] c"+=\00", align 1
@.str.47 = private unnamed_addr constant [3 x i8] c"-=\00", align 1
@.str.48 = private unnamed_addr constant [3 x i8] c"*=\00", align 1
@.str.49 = private unnamed_addr constant [3 x i8] c"/=\00", align 1
@.str.50 = private unnamed_addr constant [3 x i8] c"%=\00", align 1
@.str.51 = private unnamed_addr constant [3 x i8] c"&=\00", align 1
@.str.52 = private unnamed_addr constant [3 x i8] c"|=\00", align 1
@.str.53 = private unnamed_addr constant [3 x i8] c"^=\00", align 1
@.str.54 = private unnamed_addr constant [2 x i8] c"+\00", align 1
@.str.55 = private unnamed_addr constant [2 x i8] c"-\00", align 1
@.str.56 = private unnamed_addr constant [2 x i8] c"*\00", align 1
@.str.57 = private unnamed_addr constant [2 x i8] c"/\00", align 1
@.str.58 = private unnamed_addr constant [2 x i8] c"%\00", align 1
@.str.59 = private unnamed_addr constant [2 x i8] c"<\00", align 1
@.str.60 = private unnamed_addr constant [2 x i8] c">\00", align 1
@.str.61 = private unnamed_addr constant [2 x i8] c"!\00", align 1
@.str.62 = private unnamed_addr constant [2 x i8] c"&\00", align 1
@.str.63 = private unnamed_addr constant [2 x i8] c"|\00", align 1
@.str.64 = private unnamed_addr constant [2 x i8] c"^\00", align 1
@.str.65 = private unnamed_addr constant [2 x i8] c"~\00", align 1
@.str.66 = private unnamed_addr constant [2 x i8] c"=\00", align 1
@.str.67 = private unnamed_addr constant [18 x i8] c"operador invalido\00", align 1
@.str.68 = private unnamed_addr constant [51 x i8] c"TABELA DE TOKENS\0ATIPO\09LEXEMA\09ATRIBUTO\09LINHA\09COLUNA\00", align 1
@show.spelling = internal global [43 x ptr] [ptr @.str.54, ptr @.str.55, ptr @.str.56, ptr @.str.57, ptr @.str.58, ptr @.str.40, ptr @.str.41, ptr @.str.59, ptr @.str.42, ptr @.str.60, ptr @.str.43, ptr @.str.44, ptr @.str.45, ptr @.str.61, ptr @.str.62, ptr @.str.63, ptr @.str.64, ptr @.str.65, ptr @.str.38, ptr @.str.39, ptr @.str.37, ptr @.str.66, ptr @.str.46, ptr @.str.47, ptr @.str.48, ptr @.str.49, ptr @.str.50, ptr @.str.51, ptr @.str.52, ptr @.str.53, ptr @.str.35, ptr @.str.36, ptr @.str.34, ptr @.str.69, ptr @.str.70, ptr @.str.71, ptr @.str.72, ptr @.str.73, ptr @.str.74, ptr @.str.75, ptr @.str.76, ptr @.str.77, ptr null], align 16
@.str.69 = private unnamed_addr constant [2 x i8] c";\00", align 1
@.str.70 = private unnamed_addr constant [2 x i8] c",\00", align 1
@.str.71 = private unnamed_addr constant [2 x i8] c".\00", align 1
@.str.72 = private unnamed_addr constant [2 x i8] c"(\00", align 1
@.str.73 = private unnamed_addr constant [2 x i8] c")\00", align 1
@.str.74 = private unnamed_addr constant [2 x i8] c"{\00", align 1
@.str.75 = private unnamed_addr constant [2 x i8] c"}\00", align 1
@.str.76 = private unnamed_addr constant [2 x i8] c"[\00", align 1
@.str.77 = private unnamed_addr constant [2 x i8] c"]\00", align 1
@show.names = internal global [42 x ptr] [ptr @.str.78, ptr @.str.79, ptr @.str.80, ptr @.str.81, ptr @.str.82, ptr @.str.83, ptr @.str.84, ptr @.str.85, ptr @.str.86, ptr @.str.87, ptr @.str.88, ptr @.str.89, ptr @.str.90, ptr @.str.91, ptr @.str.92, ptr @.str.93, ptr @.str.94, ptr @.str.95, ptr @.str.96, ptr @.str.97, ptr @.str.98, ptr @.str.99, ptr @.str.100, ptr @.str.101, ptr @.str.102, ptr @.str.103, ptr @.str.104, ptr @.str.105, ptr @.str.106, ptr @.str.107, ptr @.str.108, ptr @.str.109, ptr @.str.110, ptr @.str.111, ptr @.str.112, ptr @.str.113, ptr @.str.114, ptr @.str.115, ptr @.str.116, ptr @.str.117, ptr @.str.118, ptr @.str.119], align 16
@.str.78 = private unnamed_addr constant [5 x i8] c"PLUS\00", align 1
@.str.79 = private unnamed_addr constant [6 x i8] c"MINUS\00", align 1
@.str.80 = private unnamed_addr constant [5 x i8] c"STAR\00", align 1
@.str.81 = private unnamed_addr constant [6 x i8] c"SLASH\00", align 1
@.str.82 = private unnamed_addr constant [4 x i8] c"MOD\00", align 1
@.str.83 = private unnamed_addr constant [3 x i8] c"EQ\00", align 1
@.str.84 = private unnamed_addr constant [3 x i8] c"NE\00", align 1
@.str.85 = private unnamed_addr constant [3 x i8] c"LT\00", align 1
@.str.86 = private unnamed_addr constant [3 x i8] c"LE\00", align 1
@.str.87 = private unnamed_addr constant [3 x i8] c"GT\00", align 1
@.str.88 = private unnamed_addr constant [3 x i8] c"GE\00", align 1
@.str.89 = private unnamed_addr constant [4 x i8] c"AND\00", align 1
@.str.90 = private unnamed_addr constant [3 x i8] c"OR\00", align 1
@.str.91 = private unnamed_addr constant [4 x i8] c"NOT\00", align 1
@.str.92 = private unnamed_addr constant [8 x i8] c"BIT_AND\00", align 1
@.str.93 = private unnamed_addr constant [7 x i8] c"BIT_OR\00", align 1
@.str.94 = private unnamed_addr constant [8 x i8] c"BIT_XOR\00", align 1
@.str.95 = private unnamed_addr constant [8 x i8] c"BIT_NOT\00", align 1
@.str.96 = private unnamed_addr constant [4 x i8] c"SHL\00", align 1
@.str.97 = private unnamed_addr constant [4 x i8] c"SHR\00", align 1
@.str.98 = private unnamed_addr constant [5 x i8] c"USHR\00", align 1
@.str.99 = private unnamed_addr constant [7 x i8] c"ASSIGN\00", align 1
@.str.100 = private unnamed_addr constant [12 x i8] c"PLUS_ASSIGN\00", align 1
@.str.101 = private unnamed_addr constant [13 x i8] c"MINUS_ASSIGN\00", align 1
@.str.102 = private unnamed_addr constant [12 x i8] c"STAR_ASSIGN\00", align 1
@.str.103 = private unnamed_addr constant [13 x i8] c"SLASH_ASSIGN\00", align 1
@.str.104 = private unnamed_addr constant [11 x i8] c"MOD_ASSIGN\00", align 1
@.str.105 = private unnamed_addr constant [11 x i8] c"AND_ASSIGN\00", align 1
@.str.106 = private unnamed_addr constant [10 x i8] c"OR_ASSIGN\00", align 1
@.str.107 = private unnamed_addr constant [11 x i8] c"XOR_ASSIGN\00", align 1
@.str.108 = private unnamed_addr constant [11 x i8] c"SHL_ASSIGN\00", align 1
@.str.109 = private unnamed_addr constant [11 x i8] c"SHR_ASSIGN\00", align 1
@.str.110 = private unnamed_addr constant [12 x i8] c"USHR_ASSIGN\00", align 1
@.str.111 = private unnamed_addr constant [10 x i8] c"SEMICOLON\00", align 1
@.str.112 = private unnamed_addr constant [6 x i8] c"COMMA\00", align 1
@.str.113 = private unnamed_addr constant [4 x i8] c"DOT\00", align 1
@.str.114 = private unnamed_addr constant [7 x i8] c"LPAREN\00", align 1
@.str.115 = private unnamed_addr constant [7 x i8] c"RPAREN\00", align 1
@.str.116 = private unnamed_addr constant [7 x i8] c"LBRACE\00", align 1
@.str.117 = private unnamed_addr constant [7 x i8] c"RBRACE\00", align 1
@.str.118 = private unnamed_addr constant [9 x i8] c"LBRACKET\00", align 1
@.str.119 = private unnamed_addr constant [9 x i8] c"RBRACKET\00", align 1
@.str.120 = private unnamed_addr constant [6 x i8] c"ERROR\00", align 1
@stdout = external global ptr, align 8
@type_names = internal global [12 x ptr] [ptr @.str.128, ptr @.str.129, ptr @.str.130, ptr @.str.131, ptr @.str.132, ptr @.str.133, ptr @.str.134, ptr @.str.120, ptr @.str.135, ptr @.str.136, ptr @.str.137, ptr @.str.138], align 16
@.str.121 = private unnamed_addr constant [5 x i8] c"\09%s\09\00", align 1
@.str.122 = private unnamed_addr constant [5 x i8] c"%llu\00", align 1
@.str.123 = private unnamed_addr constant [5 x i8] c"%lld\00", align 1
@.str.124 = private unnamed_addr constant [3 x i8] c"%g\00", align 1
@.str.125 = private unnamed_addr constant [12 x i8] c"\09%llu\09%llu\0A\00", align 1
@.str.126 = private unnamed_addr constant [53 x i8] c"\0ATABELA DE SIMBOLOS\0AINDICE\09IDENTIFICADOR\09OCORRENCIAS\00", align 1
@.str.127 = private unnamed_addr constant [14 x i8] c"%llu\09%s\09%llu\0A\00", align 1
@.str.128 = private unnamed_addr constant [11 x i8] c"IDENTIFIER\00", align 1
@.str.129 = private unnamed_addr constant [16 x i8] c"INTEGER_LITERAL\00", align 1
@.str.130 = private unnamed_addr constant [13 x i8] c"REAL_LITERAL\00", align 1
@.str.131 = private unnamed_addr constant [13 x i8] c"CHAR_LITERAL\00", align 1
@.str.132 = private unnamed_addr constant [15 x i8] c"STRING_LITERAL\00", align 1
@.str.133 = private unnamed_addr constant [16 x i8] c"BOOLEAN_LITERAL\00", align 1
@.str.134 = private unnamed_addr constant [13 x i8] c"NULL_LITERAL\00", align 1
@.str.135 = private unnamed_addr constant [4 x i8] c"EOF\00", align 1
@.str.136 = private unnamed_addr constant [8 x i8] c"KEYWORD\00", align 1
@.str.137 = private unnamed_addr constant [9 x i8] c"OPERATOR\00", align 1
@.str.138 = private unnamed_addr constant [10 x i8] c"DELIMITER\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local ptr @lexer_open(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = icmp ne ptr %5, null
  br i1 %6, label %8, label %7

7:                                                ; preds = %1
  store ptr null, ptr %2, align 8
  br label %45

8:                                                ; preds = %1
  %9 = call noalias ptr @calloc(i64 noundef 1, i64 noundef 176) #9
  store ptr %9, ptr %4, align 8
  %10 = load ptr, ptr %4, align 8
  %11 = icmp ne ptr %10, null
  br i1 %11, label %13, label %12

12:                                               ; preds = %8
  store ptr null, ptr %2, align 8
  br label %45

13:                                               ; preds = %8
  %14 = load ptr, ptr %4, align 8
  %15 = getelementptr inbounds %struct.Lexer, ptr %14, i32 0, i32 3
  store i64 1, ptr %15, align 8
  %16 = load ptr, ptr %4, align 8
  %17 = getelementptr inbounds %struct.Lexer, ptr %16, i32 0, i32 4
  store i64 1, ptr %17, align 8
  %18 = load ptr, ptr %4, align 8
  %19 = getelementptr inbounds %struct.Lexer, ptr %18, i32 0, i32 1
  %20 = call zeroext i1 @symbol_table_init(ptr noundef %19)
  br i1 %20, label %23, label %21

21:                                               ; preds = %13
  %22 = load ptr, ptr %4, align 8
  call void @free(ptr noundef %22) #10
  store ptr null, ptr %2, align 8
  br label %45

23:                                               ; preds = %13
  %24 = load ptr, ptr %4, align 8
  %25 = getelementptr inbounds %struct.Lexer, ptr %24, i32 0, i32 2
  %26 = call zeroext i1 @token_stream_init(ptr noundef %25)
  br i1 %26, label %31, label %27

27:                                               ; preds = %23
  %28 = load ptr, ptr %4, align 8
  %29 = getelementptr inbounds %struct.Lexer, ptr %28, i32 0, i32 1
  call void @symbol_table_destroy(ptr noundef %29)
  %30 = load ptr, ptr %4, align 8
  call void @free(ptr noundef %30) #10
  store ptr null, ptr %2, align 8
  br label %45

31:                                               ; preds = %23
  %32 = load ptr, ptr %4, align 8
  %33 = getelementptr inbounds %struct.Lexer, ptr %32, i32 0, i32 0
  %34 = load ptr, ptr %3, align 8
  %35 = call ptr @reader_init(ptr noundef %33, ptr noundef %34)
  %36 = icmp ne ptr %35, null
  br i1 %36, label %43, label %37

37:                                               ; preds = %31
  %38 = load ptr, ptr %4, align 8
  %39 = getelementptr inbounds %struct.Lexer, ptr %38, i32 0, i32 2
  call void @token_stream_destroy(ptr noundef %39)
  %40 = load ptr, ptr %4, align 8
  %41 = getelementptr inbounds %struct.Lexer, ptr %40, i32 0, i32 1
  call void @symbol_table_destroy(ptr noundef %41)
  %42 = load ptr, ptr %4, align 8
  call void @free(ptr noundef %42) #10
  store ptr null, ptr %2, align 8
  br label %45

43:                                               ; preds = %31
  %44 = load ptr, ptr %4, align 8
  store ptr %44, ptr %2, align 8
  br label %45

45:                                               ; preds = %43, %37, %27, %21, %12, %7
  %46 = load ptr, ptr %2, align 8
  ret ptr %46
}

; Function Attrs: nounwind allocsize(0,1)
declare noalias ptr @calloc(i64 noundef, i64 noundef) #1

declare zeroext i1 @symbol_table_init(ptr noundef) #2

; Function Attrs: nounwind
declare void @free(ptr noundef) #3

declare zeroext i1 @token_stream_init(ptr noundef) #2

declare void @symbol_table_destroy(ptr noundef) #2

declare ptr @reader_init(ptr noundef, ptr noundef) #2

declare void @token_stream_destroy(ptr noundef) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @lexer_next(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %10, label %13

10:                                               ; preds = %2
  %11 = load ptr, ptr %5, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %14, label %13

13:                                               ; preds = %10, %2
  store i32 -1, ptr %3, align 4
  br label %40

14:                                               ; preds = %10
  %15 = load ptr, ptr %4, align 8
  store ptr %15, ptr %6, align 8
  %16 = load ptr, ptr %6, align 8
  %17 = call i32 @scan_next(ptr noundef %16)
  store i32 %17, ptr %7, align 4
  %18 = load i32, ptr %7, align 4
  %19 = icmp slt i32 %18, 0
  br i1 %19, label %20, label %23

20:                                               ; preds = %14
  %21 = load ptr, ptr %6, align 8
  %22 = getelementptr inbounds %struct.Lexer, ptr %21, i32 0, i32 8
  store i8 1, ptr %22, align 8
  br label %23

23:                                               ; preds = %20, %14
  %24 = load i32, ptr %7, align 4
  %25 = icmp ne i32 %24, 1
  br i1 %25, label %26, label %28

26:                                               ; preds = %23
  %27 = load i32, ptr %7, align 4
  store i32 %27, ptr %3, align 4
  br label %40

28:                                               ; preds = %23
  %29 = load ptr, ptr %5, align 8
  %30 = load ptr, ptr %6, align 8
  %31 = getelementptr inbounds %struct.Lexer, ptr %30, i32 0, i32 2
  %32 = getelementptr inbounds %struct.TokenStream, ptr %31, i32 0, i32 0
  %33 = load ptr, ptr %32, align 8
  %34 = load ptr, ptr %6, align 8
  %35 = getelementptr inbounds %struct.Lexer, ptr %34, i32 0, i32 2
  %36 = getelementptr inbounds %struct.TokenStream, ptr %35, i32 0, i32 1
  %37 = load i64, ptr %36, align 8
  %38 = add i64 %37, -1
  store i64 %38, ptr %36, align 8
  %39 = getelementptr inbounds %struct.LexerToken, ptr %33, i64 %38
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %29, ptr align 8 %39, i64 40, i1 false)
  store i32 1, ptr %3, align 4
  br label %40

40:                                               ; preds = %28, %26, %13
  %41 = load i32, ptr %3, align 4
  ret i32 %41
}

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @scan_next(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  %8 = alloca %struct.LexerToken, align 8
  %9 = alloca i32, align 4
  %10 = alloca %struct.Lexeme, align 8
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i8, align 1
  %16 = alloca [2 x i8], align 1
  store ptr %0, ptr %3, align 8
  %17 = load ptr, ptr %3, align 8
  %18 = getelementptr inbounds %struct.Lexer, ptr %17, i32 0, i32 8
  %19 = load i8, ptr %18, align 8
  %20 = trunc i8 %19 to i1
  br i1 %20, label %21, label %22

21:                                               ; preds = %1
  store i32 0, ptr %2, align 4
  br label %279

22:                                               ; preds = %1
  br label %23

23:                                               ; preds = %185, %145, %106, %22
  %24 = load ptr, ptr %3, align 8
  %25 = call i32 @peek(ptr noundef %24)
  store i32 %25, ptr %4, align 4
  %26 = load i32, ptr %4, align 4
  %27 = icmp eq i32 %26, -1
  br i1 %27, label %28, label %96

28:                                               ; preds = %23
  %29 = call noalias ptr @malloc(i64 noundef 1) #11
  store ptr %29, ptr %5, align 8
  %30 = load ptr, ptr %5, align 8
  %31 = icmp ne ptr %30, null
  br i1 %31, label %33, label %32

32:                                               ; preds = %28
  store i32 -1, ptr %2, align 4
  br label %279

33:                                               ; preds = %28
  %34 = load ptr, ptr %5, align 8
  %35 = getelementptr inbounds i8, ptr %34, i64 0
  store i8 0, ptr %35, align 1
  %36 = load ptr, ptr %3, align 8
  %37 = getelementptr inbounds %struct.Lexer, ptr %36, i32 0, i32 2
  %38 = getelementptr inbounds %struct.TokenStream, ptr %37, i32 0, i32 1
  %39 = load i64, ptr %38, align 8
  %40 = load ptr, ptr %3, align 8
  %41 = getelementptr inbounds %struct.Lexer, ptr %40, i32 0, i32 2
  %42 = getelementptr inbounds %struct.TokenStream, ptr %41, i32 0, i32 2
  %43 = load i64, ptr %42, align 8
  %44 = icmp eq i64 %39, %43
  br i1 %44, label %45, label %71

45:                                               ; preds = %33
  %46 = load ptr, ptr %3, align 8
  %47 = getelementptr inbounds %struct.Lexer, ptr %46, i32 0, i32 2
  %48 = getelementptr inbounds %struct.TokenStream, ptr %47, i32 0, i32 2
  %49 = load i64, ptr %48, align 8
  %50 = mul i64 %49, 2
  store i64 %50, ptr %6, align 8
  %51 = load ptr, ptr %3, align 8
  %52 = getelementptr inbounds %struct.Lexer, ptr %51, i32 0, i32 2
  %53 = getelementptr inbounds %struct.TokenStream, ptr %52, i32 0, i32 0
  %54 = load ptr, ptr %53, align 8
  %55 = load i64, ptr %6, align 8
  %56 = mul i64 %55, 40
  %57 = call ptr @realloc(ptr noundef %54, i64 noundef %56) #12
  store ptr %57, ptr %7, align 8
  %58 = load ptr, ptr %7, align 8
  %59 = icmp ne ptr %58, null
  br i1 %59, label %62, label %60

60:                                               ; preds = %45
  %61 = load ptr, ptr %5, align 8
  call void @free(ptr noundef %61) #10
  store i32 -1, ptr %2, align 4
  br label %279

62:                                               ; preds = %45
  %63 = load ptr, ptr %7, align 8
  %64 = load ptr, ptr %3, align 8
  %65 = getelementptr inbounds %struct.Lexer, ptr %64, i32 0, i32 2
  %66 = getelementptr inbounds %struct.TokenStream, ptr %65, i32 0, i32 0
  store ptr %63, ptr %66, align 8
  %67 = load i64, ptr %6, align 8
  %68 = load ptr, ptr %3, align 8
  %69 = getelementptr inbounds %struct.Lexer, ptr %68, i32 0, i32 2
  %70 = getelementptr inbounds %struct.TokenStream, ptr %69, i32 0, i32 2
  store i64 %67, ptr %70, align 8
  br label %71

71:                                               ; preds = %62, %33
  %72 = load ptr, ptr %3, align 8
  %73 = getelementptr inbounds %struct.Lexer, ptr %72, i32 0, i32 2
  %74 = getelementptr inbounds %struct.TokenStream, ptr %73, i32 0, i32 0
  %75 = load ptr, ptr %74, align 8
  %76 = load ptr, ptr %3, align 8
  %77 = getelementptr inbounds %struct.Lexer, ptr %76, i32 0, i32 2
  %78 = getelementptr inbounds %struct.TokenStream, ptr %77, i32 0, i32 1
  %79 = load i64, ptr %78, align 8
  %80 = add i64 %79, 1
  store i64 %80, ptr %78, align 8
  %81 = getelementptr inbounds %struct.LexerToken, ptr %75, i64 %79
  %82 = getelementptr inbounds %struct.LexerToken, ptr %8, i32 0, i32 0
  store i32 8, ptr %82, align 8
  %83 = getelementptr inbounds %struct.LexerToken, ptr %8, i32 0, i32 1
  %84 = load ptr, ptr %5, align 8
  store ptr %84, ptr %83, align 8
  %85 = getelementptr inbounds %struct.LexerToken, ptr %8, i32 0, i32 2
  store i64 0, ptr %85, align 8
  %86 = getelementptr inbounds %struct.LexerToken, ptr %8, i32 0, i32 3
  %87 = load ptr, ptr %3, align 8
  %88 = getelementptr inbounds %struct.Lexer, ptr %87, i32 0, i32 3
  %89 = load i64, ptr %88, align 8
  store i64 %89, ptr %86, align 8
  %90 = getelementptr inbounds %struct.LexerToken, ptr %8, i32 0, i32 4
  %91 = load ptr, ptr %3, align 8
  %92 = getelementptr inbounds %struct.Lexer, ptr %91, i32 0, i32 4
  %93 = load i64, ptr %92, align 8
  store i64 %93, ptr %90, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %81, ptr align 8 %8, i64 40, i1 false)
  %94 = load ptr, ptr %3, align 8
  %95 = getelementptr inbounds %struct.Lexer, ptr %94, i32 0, i32 8
  store i8 1, ptr %95, align 8
  store i32 1, ptr %2, align 4
  br label %279

96:                                               ; preds = %23
  %97 = load i32, ptr %4, align 4
  %98 = icmp slt i32 %97, -1
  br i1 %98, label %99, label %103

99:                                               ; preds = %96
  %100 = load ptr, ptr @stderr, align 8
  %101 = load i32, ptr %4, align 4
  %102 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %100, ptr noundef @.str.2, i32 noundef %101) #10
  store i32 -1, ptr %2, align 4
  br label %279

103:                                              ; preds = %96
  %104 = load i32, ptr %4, align 4
  %105 = call zeroext i1 @space(i32 noundef %104)
  br i1 %105, label %106, label %108

106:                                              ; preds = %103
  %107 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %107)
  br label %23

108:                                              ; preds = %103
  %109 = load i32, ptr %4, align 4
  %110 = icmp eq i32 %109, 47
  br i1 %110, label %111, label %196

111:                                              ; preds = %108
  %112 = load ptr, ptr %3, align 8
  call void @begin(ptr noundef %112)
  %113 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %113)
  %114 = load ptr, ptr %3, align 8
  %115 = call i32 @peek(ptr noundef %114)
  store i32 %115, ptr %9, align 4
  %116 = load i32, ptr %9, align 4
  %117 = icmp eq i32 %116, 47
  br i1 %117, label %121, label %118

118:                                              ; preds = %111
  %119 = load i32, ptr %9, align 4
  %120 = icmp eq i32 %119, 42
  br i1 %120, label %121, label %186

121:                                              ; preds = %118, %111
  %122 = load ptr, ptr %3, align 8
  %123 = getelementptr inbounds %struct.Lexer, ptr %122, i32 0, i32 0
  call void @llvm.memset.p0.i64(ptr align 8 %10, i8 0, i64 32, i1 false)
  %124 = getelementptr inbounds %struct.Lexeme, ptr %10, i32 0, i32 0
  %125 = getelementptr inbounds %struct.Lexeme, ptr %10, i32 0, i32 1
  %126 = getelementptr inbounds %struct.Lexeme, ptr %10, i32 0, i32 2
  %127 = getelementptr inbounds %struct.Lexeme, ptr %10, i32 0, i32 3
  %128 = call zeroext i1 @reader_lexeme(ptr noundef %123, ptr noundef %10)
  %129 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %129)
  %130 = load i32, ptr %9, align 4
  %131 = icmp eq i32 %130, 47
  br i1 %131, label %132, label %146

132:                                              ; preds = %121
  br label %133

133:                                              ; preds = %143, %132
  %134 = load ptr, ptr %3, align 8
  %135 = call i32 @peek(ptr noundef %134)
  %136 = icmp sge i32 %135, 0
  br i1 %136, label %137, label %141

137:                                              ; preds = %133
  %138 = load ptr, ptr %3, align 8
  %139 = call i32 @peek(ptr noundef %138)
  %140 = icmp ne i32 %139, 10
  br label %141

141:                                              ; preds = %137, %133
  %142 = phi i1 [ false, %133 ], [ %140, %137 ]
  br i1 %142, label %143, label %145

143:                                              ; preds = %141
  %144 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %144)
  br label %133, !llvm.loop !6

145:                                              ; preds = %141
  br label %23

146:                                              ; preds = %121
  store i32 0, ptr %11, align 4
  store i32 0, ptr %12, align 4
  store i32 0, ptr %13, align 4
  br label %147

147:                                              ; preds = %168, %146
  %148 = load ptr, ptr %3, align 8
  %149 = call i32 @peek(ptr noundef %148)
  %150 = icmp sge i32 %149, 0
  br i1 %150, label %151, label %170

151:                                              ; preds = %147
  %152 = load ptr, ptr %3, align 8
  %153 = call i32 @peek(ptr noundef %152)
  store i32 %153, ptr %14, align 4
  %154 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %154)
  %155 = load i32, ptr %11, align 4
  %156 = icmp eq i32 %155, 47
  br i1 %156, label %157, label %161

157:                                              ; preds = %151
  %158 = load i32, ptr %14, align 4
  %159 = icmp eq i32 %158, 42
  br i1 %159, label %160, label %161

160:                                              ; preds = %157
  store i32 1, ptr %13, align 4
  br label %161

161:                                              ; preds = %160, %157, %151
  %162 = load i32, ptr %11, align 4
  %163 = icmp eq i32 %162, 42
  br i1 %163, label %164, label %168

164:                                              ; preds = %161
  %165 = load i32, ptr %14, align 4
  %166 = icmp eq i32 %165, 47
  br i1 %166, label %167, label %168

167:                                              ; preds = %164
  store i32 1, ptr %12, align 4
  br label %170

168:                                              ; preds = %164, %161
  %169 = load i32, ptr %14, align 4
  store i32 %169, ptr %11, align 4
  br label %147, !llvm.loop !8

170:                                              ; preds = %167, %147
  %171 = load i32, ptr %12, align 4
  %172 = icmp ne i32 %171, 0
  br i1 %172, label %173, label %176

173:                                              ; preds = %170
  %174 = load i32, ptr %13, align 4
  %175 = icmp ne i32 %174, 0
  br i1 %175, label %176, label %185

176:                                              ; preds = %173, %170
  %177 = load ptr, ptr %3, align 8
  %178 = load i32, ptr %13, align 4
  %179 = icmp ne i32 %178, 0
  %180 = zext i1 %179 to i64
  %181 = select i1 %179, ptr @.str.3, ptr @.str.4
  %182 = call zeroext i1 @comment_error(ptr noundef %177, ptr noundef %181)
  br i1 %182, label %184, label %183

183:                                              ; preds = %176
  store i32 -1, ptr %2, align 4
  br label %279

184:                                              ; preds = %176
  store i32 1, ptr %2, align 4
  br label %279

185:                                              ; preds = %173
  br label %23

186:                                              ; preds = %118
  %187 = load i32, ptr %9, align 4
  %188 = icmp eq i32 %187, 61
  br i1 %188, label %189, label %191

189:                                              ; preds = %186
  %190 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %190)
  br label %191

191:                                              ; preds = %189, %186
  %192 = load ptr, ptr %3, align 8
  %193 = call zeroext i1 @emit(ptr noundef %192, i32 noundef 10, ptr noundef null)
  br i1 %193, label %195, label %194

194:                                              ; preds = %191
  store i32 -1, ptr %2, align 4
  br label %279

195:                                              ; preds = %191
  store i32 1, ptr %2, align 4
  br label %279

196:                                              ; preds = %108
  %197 = load ptr, ptr %3, align 8
  call void @begin(ptr noundef %197)
  %198 = load i32, ptr %4, align 4
  %199 = call zeroext i1 @letter(i32 noundef %198)
  br i1 %199, label %200, label %204

200:                                              ; preds = %196
  %201 = load ptr, ptr %3, align 8
  %202 = call zeroext i1 @scan_word(ptr noundef %201)
  %203 = zext i1 %202 to i8
  store i8 %203, ptr %15, align 1
  br label %274

204:                                              ; preds = %196
  %205 = load i32, ptr %4, align 4
  %206 = call zeroext i1 @digit(i32 noundef %205)
  br i1 %206, label %207, label %211

207:                                              ; preds = %204
  %208 = load ptr, ptr %3, align 8
  %209 = call zeroext i1 @scan_number(ptr noundef %208, i1 noundef zeroext false)
  %210 = zext i1 %209 to i8
  store i8 %210, ptr %15, align 1
  br label %273

211:                                              ; preds = %204
  %212 = load i32, ptr %4, align 4
  %213 = icmp eq i32 %212, 39
  br i1 %213, label %217, label %214

214:                                              ; preds = %211
  %215 = load i32, ptr %4, align 4
  %216 = icmp eq i32 %215, 34
  br i1 %216, label %217, label %222

217:                                              ; preds = %214, %211
  %218 = load ptr, ptr %3, align 8
  %219 = load i32, ptr %4, align 4
  %220 = call zeroext i1 @scan_quoted(ptr noundef %218, i32 noundef %219)
  %221 = zext i1 %220 to i8
  store i8 %221, ptr %15, align 1
  br label %272

222:                                              ; preds = %214
  %223 = load i32, ptr %4, align 4
  %224 = icmp eq i32 %223, 46
  br i1 %224, label %225, label %246

225:                                              ; preds = %222
  %226 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %226)
  %227 = load ptr, ptr %3, align 8
  %228 = call i32 @peek(ptr noundef %227)
  %229 = call zeroext i1 @digit(i32 noundef %228)
  br i1 %229, label %230, label %241

230:                                              ; preds = %225
  br label %231

231:                                              ; preds = %235, %230
  %232 = load ptr, ptr %3, align 8
  %233 = call i32 @peek(ptr noundef %232)
  %234 = call zeroext i1 @digit(i32 noundef %233)
  br i1 %234, label %235, label %237

235:                                              ; preds = %231
  %236 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %236)
  br label %231, !llvm.loop !9

237:                                              ; preds = %231
  %238 = load ptr, ptr %3, align 8
  %239 = call zeroext i1 @emit(ptr noundef %238, i32 noundef 2, ptr noundef null)
  %240 = zext i1 %239 to i8
  store i8 %240, ptr %15, align 1
  br label %245

241:                                              ; preds = %225
  %242 = load ptr, ptr %3, align 8
  %243 = call zeroext i1 @emit(ptr noundef %242, i32 noundef 11, ptr noundef null)
  %244 = zext i1 %243 to i8
  store i8 %244, ptr %15, align 1
  br label %245

245:                                              ; preds = %241, %237
  br label %271

246:                                              ; preds = %222
  %247 = load i32, ptr %4, align 4
  %248 = call zeroext i1 @delimiter(i32 noundef %247)
  br i1 %248, label %249, label %254

249:                                              ; preds = %246
  %250 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %250)
  %251 = load ptr, ptr %3, align 8
  %252 = call zeroext i1 @emit(ptr noundef %251, i32 noundef 11, ptr noundef null)
  %253 = zext i1 %252 to i8
  store i8 %253, ptr %15, align 1
  br label %270

254:                                              ; preds = %246
  %255 = load i32, ptr %4, align 4
  %256 = trunc i32 %255 to i8
  store i8 %256, ptr %16, align 1
  %257 = getelementptr inbounds i8, ptr %16, i64 1
  store i8 0, ptr %257, align 1
  %258 = getelementptr inbounds [2 x i8], ptr %16, i64 0, i64 0
  %259 = call zeroext i1 @operator_prefix(ptr noundef %258, i64 noundef 1)
  br i1 %259, label %260, label %264

260:                                              ; preds = %254
  %261 = load ptr, ptr %3, align 8
  %262 = call zeroext i1 @scan_operator(ptr noundef %261)
  %263 = zext i1 %262 to i8
  store i8 %263, ptr %15, align 1
  br label %269

264:                                              ; preds = %254
  %265 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %265)
  %266 = load ptr, ptr %3, align 8
  %267 = call zeroext i1 @emit(ptr noundef %266, i32 noundef 7, ptr noundef @.str.5)
  %268 = zext i1 %267 to i8
  store i8 %268, ptr %15, align 1
  br label %269

269:                                              ; preds = %264, %260
  br label %270

270:                                              ; preds = %269, %249
  br label %271

271:                                              ; preds = %270, %245
  br label %272

272:                                              ; preds = %271, %217
  br label %273

273:                                              ; preds = %272, %207
  br label %274

274:                                              ; preds = %273, %200
  %275 = load i8, ptr %15, align 1
  %276 = trunc i8 %275 to i1
  br i1 %276, label %278, label %277

277:                                              ; preds = %274
  store i32 -1, ptr %2, align 4
  br label %279

278:                                              ; preds = %274
  store i32 1, ptr %2, align 4
  br label %279

279:                                              ; preds = %278, %277, %195, %194, %184, %183, %99, %71, %60, %32, %21
  %280 = load i32, ptr %2, align 4
  ret i32 %280
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @lexer_token_free(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = icmp ne ptr %3, null
  br i1 %4, label %6, label %5

5:                                                ; preds = %1
  br label %12

6:                                                ; preds = %1
  %7 = load ptr, ptr %2, align 8
  %8 = getelementptr inbounds %struct.LexerToken, ptr %7, i32 0, i32 1
  %9 = load ptr, ptr %8, align 8
  call void @free(ptr noundef %9) #10
  %10 = load ptr, ptr %2, align 8
  %11 = getelementptr inbounds %struct.LexerToken, ptr %10, i32 0, i32 1
  store ptr null, ptr %11, align 8
  br label %12

12:                                               ; preds = %6, %5
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @lexer_close(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %2, align 8
  %5 = load ptr, ptr %2, align 8
  %6 = icmp ne ptr %5, null
  br i1 %6, label %8, label %7

7:                                                ; preds = %1
  br label %37

8:                                                ; preds = %1
  %9 = load ptr, ptr %2, align 8
  store ptr %9, ptr %3, align 8
  %10 = load ptr, ptr %3, align 8
  %11 = getelementptr inbounds %struct.Lexer, ptr %10, i32 0, i32 0
  call void @reader_destroy(ptr noundef %11)
  store i64 0, ptr %4, align 8
  br label %12

12:                                               ; preds = %28, %8
  %13 = load i64, ptr %4, align 8
  %14 = load ptr, ptr %3, align 8
  %15 = getelementptr inbounds %struct.Lexer, ptr %14, i32 0, i32 2
  %16 = getelementptr inbounds %struct.TokenStream, ptr %15, i32 0, i32 1
  %17 = load i64, ptr %16, align 8
  %18 = icmp ult i64 %13, %17
  br i1 %18, label %19, label %31

19:                                               ; preds = %12
  %20 = load ptr, ptr %3, align 8
  %21 = getelementptr inbounds %struct.Lexer, ptr %20, i32 0, i32 2
  %22 = getelementptr inbounds %struct.TokenStream, ptr %21, i32 0, i32 0
  %23 = load ptr, ptr %22, align 8
  %24 = load i64, ptr %4, align 8
  %25 = getelementptr inbounds %struct.LexerToken, ptr %23, i64 %24
  %26 = getelementptr inbounds %struct.LexerToken, ptr %25, i32 0, i32 1
  %27 = load ptr, ptr %26, align 8
  call void @free(ptr noundef %27) #10
  br label %28

28:                                               ; preds = %19
  %29 = load i64, ptr %4, align 8
  %30 = add i64 %29, 1
  store i64 %30, ptr %4, align 8
  br label %12, !llvm.loop !10

31:                                               ; preds = %12
  %32 = load ptr, ptr %3, align 8
  %33 = getelementptr inbounds %struct.Lexer, ptr %32, i32 0, i32 2
  call void @token_stream_destroy(ptr noundef %33)
  %34 = load ptr, ptr %3, align 8
  %35 = getelementptr inbounds %struct.Lexer, ptr %34, i32 0, i32 1
  call void @symbol_table_destroy(ptr noundef %35)
  %36 = load ptr, ptr %3, align 8
  call void @free(ptr noundef %36) #10
  br label %37

37:                                               ; preds = %31, %7
  ret void
}

declare void @reader_destroy(ptr noundef) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @lexer_main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  %9 = load i32, ptr %4, align 4
  %10 = icmp ne i32 %9, 2
  br i1 %10, label %11, label %14

11:                                               ; preds = %2
  %12 = load ptr, ptr @stderr, align 8
  %13 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %12, ptr noundef @.str) #10
  store i32 2, ptr %3, align 4
  br label %49

14:                                               ; preds = %2
  %15 = load ptr, ptr %5, align 8
  %16 = getelementptr inbounds ptr, ptr %15, i64 1
  %17 = load ptr, ptr %16, align 8
  %18 = call ptr @lexer_open(ptr noundef %17)
  store ptr %18, ptr %6, align 8
  %19 = load ptr, ptr %6, align 8
  %20 = icmp ne ptr %19, null
  br i1 %20, label %27, label %21

21:                                               ; preds = %14
  %22 = load ptr, ptr @stderr, align 8
  %23 = load ptr, ptr %5, align 8
  %24 = getelementptr inbounds ptr, ptr %23, i64 1
  %25 = load ptr, ptr %24, align 8
  %26 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %22, ptr noundef @.str.1, ptr noundef %25) #10
  store i32 1, ptr %3, align 4
  br label %49

27:                                               ; preds = %14
  %28 = load ptr, ptr %6, align 8
  %29 = call i32 @scan(ptr noundef %28)
  store i32 %29, ptr %7, align 4
  %30 = load i32, ptr %7, align 4
  %31 = icmp ne i32 %30, 0
  br i1 %31, label %34, label %32

32:                                               ; preds = %27
  %33 = load ptr, ptr %6, align 8
  call void @show(ptr noundef %33)
  br label %34

34:                                               ; preds = %32, %27
  %35 = load ptr, ptr %6, align 8
  %36 = getelementptr inbounds %struct.Lexer, ptr %35, i32 0, i32 7
  %37 = load i64, ptr %36, align 8
  %38 = trunc i64 %37 to i32
  store i32 %38, ptr %8, align 4
  %39 = load ptr, ptr %6, align 8
  call void @lexer_close(ptr noundef %39)
  %40 = load i32, ptr %7, align 4
  %41 = icmp ne i32 %40, 0
  br i1 %41, label %45, label %42

42:                                               ; preds = %34
  %43 = load i32, ptr %8, align 4
  %44 = icmp ne i32 %43, 0
  br label %45

45:                                               ; preds = %42, %34
  %46 = phi i1 [ true, %34 ], [ %44, %42 ]
  %47 = zext i1 %46 to i64
  %48 = select i1 %46, i32 1, i32 0
  store i32 %48, ptr %3, align 4
  br label %49

49:                                               ; preds = %45, %21, %11
  %50 = load i32, ptr %3, align 4
  ret i32 %50
}

; Function Attrs: nounwind
declare i32 @fprintf(ptr noundef, ptr noundef, ...) #3

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @scan(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca i32, align 4
  store ptr %0, ptr %2, align 8
  br label %4

4:                                                ; preds = %7, %1
  %5 = load ptr, ptr %2, align 8
  %6 = call i32 @scan_next(ptr noundef %5)
  store i32 %6, ptr %3, align 4
  br label %7

7:                                                ; preds = %4
  %8 = load i32, ptr %3, align 4
  %9 = icmp sgt i32 %8, 0
  br i1 %9, label %4, label %10, !llvm.loop !11

10:                                               ; preds = %7
  %11 = load i32, ptr %3, align 4
  %12 = icmp slt i32 %11, 0
  %13 = zext i1 %12 to i64
  %14 = select i1 %12, i32 1, i32 0
  ret i32 %14
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @show(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca i64, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca double, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %2, align 8
  %9 = call i32 @puts(ptr noundef @.str.68)
  store i64 0, ptr %3, align 8
  br label %10

10:                                               ; preds = %174, %1
  %11 = load i64, ptr %3, align 8
  %12 = load ptr, ptr %2, align 8
  %13 = getelementptr inbounds %struct.Lexer, ptr %12, i32 0, i32 2
  %14 = getelementptr inbounds %struct.TokenStream, ptr %13, i32 0, i32 1
  %15 = load i64, ptr %14, align 8
  %16 = icmp ult i64 %11, %15
  br i1 %16, label %17, label %177

17:                                               ; preds = %10
  %18 = load ptr, ptr %2, align 8
  %19 = getelementptr inbounds %struct.Lexer, ptr %18, i32 0, i32 2
  %20 = getelementptr inbounds %struct.TokenStream, ptr %19, i32 0, i32 0
  %21 = load ptr, ptr %20, align 8
  %22 = load i64, ptr %3, align 8
  %23 = getelementptr inbounds %struct.LexerToken, ptr %21, i64 %22
  store ptr %23, ptr %4, align 8
  %24 = load ptr, ptr %4, align 8
  %25 = getelementptr inbounds %struct.LexerToken, ptr %24, i32 0, i32 0
  %26 = load i32, ptr %25, align 8
  %27 = icmp eq i32 %26, 9
  br i1 %27, label %28, label %62

28:                                               ; preds = %17
  %29 = load ptr, ptr %4, align 8
  %30 = getelementptr inbounds %struct.LexerToken, ptr %29, i32 0, i32 1
  %31 = load ptr, ptr %30, align 8
  store ptr %31, ptr %5, align 8
  br label %32

32:                                               ; preds = %58, %28
  %33 = load ptr, ptr %5, align 8
  %34 = load i8, ptr %33, align 1
  %35 = icmp ne i8 %34, 0
  br i1 %35, label %36, label %61

36:                                               ; preds = %32
  %37 = load ptr, ptr %5, align 8
  %38 = load i8, ptr %37, align 1
  %39 = sext i8 %38 to i32
  %40 = icmp sge i32 %39, 97
  br i1 %40, label %41, label %51

41:                                               ; preds = %36
  %42 = load ptr, ptr %5, align 8
  %43 = load i8, ptr %42, align 1
  %44 = sext i8 %43 to i32
  %45 = icmp sle i32 %44, 122
  br i1 %45, label %46, label %51

46:                                               ; preds = %41
  %47 = load ptr, ptr %5, align 8
  %48 = load i8, ptr %47, align 1
  %49 = sext i8 %48 to i32
  %50 = sub nsw i32 %49, 32
  br label %55

51:                                               ; preds = %41, %36
  %52 = load ptr, ptr %5, align 8
  %53 = load i8, ptr %52, align 1
  %54 = sext i8 %53 to i32
  br label %55

55:                                               ; preds = %51, %46
  %56 = phi i32 [ %50, %46 ], [ %54, %51 ]
  %57 = call i32 @putchar(i32 noundef %56)
  br label %58

58:                                               ; preds = %55
  %59 = load ptr, ptr %5, align 8
  %60 = getelementptr inbounds i8, ptr %59, i32 1
  store ptr %60, ptr %5, align 8
  br label %32, !llvm.loop !12

61:                                               ; preds = %32
  br label %120

62:                                               ; preds = %17
  %63 = load ptr, ptr %4, align 8
  %64 = getelementptr inbounds %struct.LexerToken, ptr %63, i32 0, i32 0
  %65 = load i32, ptr %64, align 8
  %66 = icmp eq i32 %65, 10
  br i1 %66, label %72, label %67

67:                                               ; preds = %62
  %68 = load ptr, ptr %4, align 8
  %69 = getelementptr inbounds %struct.LexerToken, ptr %68, i32 0, i32 0
  %70 = load i32, ptr %69, align 8
  %71 = icmp eq i32 %70, 11
  br i1 %71, label %72, label %110

72:                                               ; preds = %67, %62
  store i32 0, ptr %6, align 4
  br label %73

73:                                               ; preds = %91, %72
  %74 = load i32, ptr %6, align 4
  %75 = sext i32 %74 to i64
  %76 = getelementptr inbounds [43 x ptr], ptr @show.spelling, i64 0, i64 %75
  %77 = load ptr, ptr %76, align 8
  %78 = icmp ne ptr %77, null
  br i1 %78, label %79, label %89

79:                                               ; preds = %73
  %80 = load i32, ptr %6, align 4
  %81 = sext i32 %80 to i64
  %82 = getelementptr inbounds [43 x ptr], ptr @show.spelling, i64 0, i64 %81
  %83 = load ptr, ptr %82, align 8
  %84 = load ptr, ptr %4, align 8
  %85 = getelementptr inbounds %struct.LexerToken, ptr %84, i32 0, i32 1
  %86 = load ptr, ptr %85, align 8
  %87 = call i32 @strcmp(ptr noundef %83, ptr noundef %86) #13
  %88 = icmp ne i32 %87, 0
  br label %89

89:                                               ; preds = %79, %73
  %90 = phi i1 [ false, %73 ], [ %88, %79 ]
  br i1 %90, label %91, label %94

91:                                               ; preds = %89
  %92 = load i32, ptr %6, align 4
  %93 = add nsw i32 %92, 1
  store i32 %93, ptr %6, align 4
  br label %73, !llvm.loop !13

94:                                               ; preds = %89
  %95 = load i32, ptr %6, align 4
  %96 = sext i32 %95 to i64
  %97 = getelementptr inbounds [43 x ptr], ptr @show.spelling, i64 0, i64 %96
  %98 = load ptr, ptr %97, align 8
  %99 = icmp ne ptr %98, null
  br i1 %99, label %100, label %105

100:                                              ; preds = %94
  %101 = load i32, ptr %6, align 4
  %102 = sext i32 %101 to i64
  %103 = getelementptr inbounds [42 x ptr], ptr @show.names, i64 0, i64 %102
  %104 = load ptr, ptr %103, align 8
  br label %106

105:                                              ; preds = %94
  br label %106

106:                                              ; preds = %105, %100
  %107 = phi ptr [ %104, %100 ], [ @.str.120, %105 ]
  %108 = load ptr, ptr @stdout, align 8
  %109 = call i32 @fputs(ptr noundef %107, ptr noundef %108)
  br label %119

110:                                              ; preds = %67
  %111 = load ptr, ptr %4, align 8
  %112 = getelementptr inbounds %struct.LexerToken, ptr %111, i32 0, i32 0
  %113 = load i32, ptr %112, align 8
  %114 = sext i32 %113 to i64
  %115 = getelementptr inbounds [12 x ptr], ptr @type_names, i64 0, i64 %114
  %116 = load ptr, ptr %115, align 8
  %117 = load ptr, ptr @stdout, align 8
  %118 = call i32 @fputs(ptr noundef %116, ptr noundef %117)
  br label %119

119:                                              ; preds = %110, %106
  br label %120

120:                                              ; preds = %119, %61
  %121 = load ptr, ptr %4, align 8
  %122 = getelementptr inbounds %struct.LexerToken, ptr %121, i32 0, i32 0
  %123 = load i32, ptr %122, align 8
  %124 = icmp eq i32 %123, 8
  br i1 %124, label %125, label %126

125:                                              ; preds = %120
  br label %130

126:                                              ; preds = %120
  %127 = load ptr, ptr %4, align 8
  %128 = getelementptr inbounds %struct.LexerToken, ptr %127, i32 0, i32 1
  %129 = load ptr, ptr %128, align 8
  br label %130

130:                                              ; preds = %126, %125
  %131 = phi ptr [ @.str.55, %125 ], [ %129, %126 ]
  %132 = call i32 (ptr, ...) @printf(ptr noundef @.str.121, ptr noundef %131)
  %133 = load ptr, ptr %4, align 8
  %134 = getelementptr inbounds %struct.LexerToken, ptr %133, i32 0, i32 0
  %135 = load i32, ptr %134, align 8
  %136 = icmp eq i32 %135, 0
  br i1 %136, label %137, label %142

137:                                              ; preds = %130
  %138 = load ptr, ptr %4, align 8
  %139 = getelementptr inbounds %struct.LexerToken, ptr %138, i32 0, i32 2
  %140 = load i64, ptr %139, align 8
  %141 = call i32 (ptr, ...) @printf(ptr noundef @.str.122, i64 noundef %140)
  br label %166

142:                                              ; preds = %130
  %143 = load ptr, ptr %4, align 8
  %144 = getelementptr inbounds %struct.LexerToken, ptr %143, i32 0, i32 0
  %145 = load i32, ptr %144, align 8
  %146 = icmp eq i32 %145, 1
  br i1 %146, label %147, label %152

147:                                              ; preds = %142
  %148 = load ptr, ptr %4, align 8
  %149 = getelementptr inbounds %struct.LexerToken, ptr %148, i32 0, i32 2
  %150 = load i64, ptr %149, align 8
  %151 = call i32 (ptr, ...) @printf(ptr noundef @.str.123, i64 noundef %150)
  br label %165

152:                                              ; preds = %142
  %153 = load ptr, ptr %4, align 8
  %154 = getelementptr inbounds %struct.LexerToken, ptr %153, i32 0, i32 0
  %155 = load i32, ptr %154, align 8
  %156 = icmp eq i32 %155, 2
  br i1 %156, label %157, label %162

157:                                              ; preds = %152
  %158 = load ptr, ptr %4, align 8
  %159 = getelementptr inbounds %struct.LexerToken, ptr %158, i32 0, i32 2
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %7, ptr align 8 %159, i64 8, i1 false)
  %160 = load double, ptr %7, align 8
  %161 = call i32 (ptr, ...) @printf(ptr noundef @.str.124, double noundef %160)
  br label %164

162:                                              ; preds = %152
  %163 = call i32 (ptr, ...) @printf(ptr noundef @.str.55)
  br label %164

164:                                              ; preds = %162, %157
  br label %165

165:                                              ; preds = %164, %147
  br label %166

166:                                              ; preds = %165, %137
  %167 = load ptr, ptr %4, align 8
  %168 = getelementptr inbounds %struct.LexerToken, ptr %167, i32 0, i32 3
  %169 = load i64, ptr %168, align 8
  %170 = load ptr, ptr %4, align 8
  %171 = getelementptr inbounds %struct.LexerToken, ptr %170, i32 0, i32 4
  %172 = load i64, ptr %171, align 8
  %173 = call i32 (ptr, ...) @printf(ptr noundef @.str.125, i64 noundef %169, i64 noundef %172)
  br label %174

174:                                              ; preds = %166
  %175 = load i64, ptr %3, align 8
  %176 = add i64 %175, 1
  store i64 %176, ptr %3, align 8
  br label %10, !llvm.loop !14

177:                                              ; preds = %10
  %178 = call i32 @puts(ptr noundef @.str.126)
  store i64 0, ptr %8, align 8
  br label %179

179:                                              ; preds = %205, %177
  %180 = load i64, ptr %8, align 8
  %181 = load ptr, ptr %2, align 8
  %182 = getelementptr inbounds %struct.Lexer, ptr %181, i32 0, i32 1
  %183 = getelementptr inbounds %struct.SymbolTable, ptr %182, i32 0, i32 1
  %184 = load i64, ptr %183, align 8
  %185 = icmp ult i64 %180, %184
  br i1 %185, label %186, label %208

186:                                              ; preds = %179
  %187 = load i64, ptr %8, align 8
  %188 = load ptr, ptr %2, align 8
  %189 = getelementptr inbounds %struct.Lexer, ptr %188, i32 0, i32 1
  %190 = getelementptr inbounds %struct.SymbolTable, ptr %189, i32 0, i32 0
  %191 = load ptr, ptr %190, align 8
  %192 = load i64, ptr %8, align 8
  %193 = getelementptr inbounds %struct.Symbol, ptr %191, i64 %192
  %194 = getelementptr inbounds %struct.Symbol, ptr %193, i32 0, i32 0
  %195 = load ptr, ptr %194, align 8
  %196 = load ptr, ptr %2, align 8
  %197 = getelementptr inbounds %struct.Lexer, ptr %196, i32 0, i32 1
  %198 = getelementptr inbounds %struct.SymbolTable, ptr %197, i32 0, i32 0
  %199 = load ptr, ptr %198, align 8
  %200 = load i64, ptr %8, align 8
  %201 = getelementptr inbounds %struct.Symbol, ptr %199, i64 %200
  %202 = getelementptr inbounds %struct.Symbol, ptr %201, i32 0, i32 1
  %203 = load i64, ptr %202, align 8
  %204 = call i32 (ptr, ...) @printf(ptr noundef @.str.127, i64 noundef %187, ptr noundef %195, i64 noundef %203)
  br label %205

205:                                              ; preds = %186
  %206 = load i64, ptr %8, align 8
  %207 = add i64 %206, 1
  store i64 %207, ptr %8, align 8
  br label %179, !llvm.loop !15

208:                                              ; preds = %179
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @peek(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds %struct.Lexer, ptr %3, i32 0, i32 0
  %5 = call i32 @reader_peek(ptr noundef %4)
  ret i32 %5
}

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #5

; Function Attrs: nounwind allocsize(1)
declare ptr @realloc(ptr noundef, i64 noundef) #6

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @space(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = icmp eq i32 %3, 32
  br i1 %4, label %14, label %5

5:                                                ; preds = %1
  %6 = load i32, ptr %2, align 4
  %7 = icmp eq i32 %6, 9
  br i1 %7, label %14, label %8

8:                                                ; preds = %5
  %9 = load i32, ptr %2, align 4
  %10 = icmp eq i32 %9, 10
  br i1 %10, label %14, label %11

11:                                               ; preds = %8
  %12 = load i32, ptr %2, align 4
  %13 = icmp eq i32 %12, 13
  br label %14

14:                                               ; preds = %11, %8, %5, %1
  %15 = phi i1 [ true, %8 ], [ true, %5 ], [ true, %1 ], [ %13, %11 ]
  ret i1 %15
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @step(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca i32, align 4
  store ptr %0, ptr %2, align 8
  %4 = load ptr, ptr %2, align 8
  %5 = call i32 @peek(ptr noundef %4)
  store i32 %5, ptr %3, align 4
  %6 = load i32, ptr %3, align 4
  %7 = icmp slt i32 %6, 0
  br i1 %7, label %8, label %9

8:                                                ; preds = %1
  br label %26

9:                                                ; preds = %1
  %10 = load ptr, ptr %2, align 8
  %11 = getelementptr inbounds %struct.Lexer, ptr %10, i32 0, i32 0
  call void @reader_step(ptr noundef %11)
  %12 = load i32, ptr %3, align 4
  %13 = icmp eq i32 %12, 10
  br i1 %13, label %14, label %21

14:                                               ; preds = %9
  %15 = load ptr, ptr %2, align 8
  %16 = getelementptr inbounds %struct.Lexer, ptr %15, i32 0, i32 3
  %17 = load i64, ptr %16, align 8
  %18 = add i64 %17, 1
  store i64 %18, ptr %16, align 8
  %19 = load ptr, ptr %2, align 8
  %20 = getelementptr inbounds %struct.Lexer, ptr %19, i32 0, i32 4
  store i64 1, ptr %20, align 8
  br label %26

21:                                               ; preds = %9
  %22 = load ptr, ptr %2, align 8
  %23 = getelementptr inbounds %struct.Lexer, ptr %22, i32 0, i32 4
  %24 = load i64, ptr %23, align 8
  %25 = add i64 %24, 1
  store i64 %25, ptr %23, align 8
  br label %26

26:                                               ; preds = %8, %21, %14
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @begin(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds %struct.Lexer, ptr %3, i32 0, i32 3
  %5 = load i64, ptr %4, align 8
  %6 = load ptr, ptr %2, align 8
  %7 = getelementptr inbounds %struct.Lexer, ptr %6, i32 0, i32 5
  store i64 %5, ptr %7, align 8
  %8 = load ptr, ptr %2, align 8
  %9 = getelementptr inbounds %struct.Lexer, ptr %8, i32 0, i32 4
  %10 = load i64, ptr %9, align 8
  %11 = load ptr, ptr %2, align 8
  %12 = getelementptr inbounds %struct.Lexer, ptr %11, i32 0, i32 6
  store i64 %10, ptr %12, align 8
  %13 = load ptr, ptr %2, align 8
  %14 = getelementptr inbounds %struct.Lexer, ptr %13, i32 0, i32 0
  call void @reader_begin(ptr noundef %14)
  ret void
}

declare zeroext i1 @reader_lexeme(ptr noundef, ptr noundef) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #7

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @comment_error(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i1, align 1
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  %9 = alloca %struct.LexerToken, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %10 = load ptr, ptr %4, align 8
  %11 = getelementptr inbounds %struct.Lexer, ptr %10, i32 0, i32 2
  %12 = getelementptr inbounds %struct.TokenStream, ptr %11, i32 0, i32 1
  %13 = load i64, ptr %12, align 8
  %14 = load ptr, ptr %4, align 8
  %15 = getelementptr inbounds %struct.Lexer, ptr %14, i32 0, i32 2
  %16 = getelementptr inbounds %struct.TokenStream, ptr %15, i32 0, i32 2
  %17 = load i64, ptr %16, align 8
  %18 = icmp eq i64 %13, %17
  br i1 %18, label %19, label %44

19:                                               ; preds = %2
  %20 = load ptr, ptr %4, align 8
  %21 = getelementptr inbounds %struct.Lexer, ptr %20, i32 0, i32 2
  %22 = getelementptr inbounds %struct.TokenStream, ptr %21, i32 0, i32 2
  %23 = load i64, ptr %22, align 8
  %24 = mul i64 %23, 2
  store i64 %24, ptr %6, align 8
  %25 = load ptr, ptr %4, align 8
  %26 = getelementptr inbounds %struct.Lexer, ptr %25, i32 0, i32 2
  %27 = getelementptr inbounds %struct.TokenStream, ptr %26, i32 0, i32 0
  %28 = load ptr, ptr %27, align 8
  %29 = load i64, ptr %6, align 8
  %30 = mul i64 %29, 40
  %31 = call ptr @realloc(ptr noundef %28, i64 noundef %30) #12
  store ptr %31, ptr %7, align 8
  %32 = load ptr, ptr %7, align 8
  %33 = icmp ne ptr %32, null
  br i1 %33, label %35, label %34

34:                                               ; preds = %19
  store i1 false, ptr %3, align 1
  br label %86

35:                                               ; preds = %19
  %36 = load ptr, ptr %7, align 8
  %37 = load ptr, ptr %4, align 8
  %38 = getelementptr inbounds %struct.Lexer, ptr %37, i32 0, i32 2
  %39 = getelementptr inbounds %struct.TokenStream, ptr %38, i32 0, i32 0
  store ptr %36, ptr %39, align 8
  %40 = load i64, ptr %6, align 8
  %41 = load ptr, ptr %4, align 8
  %42 = getelementptr inbounds %struct.Lexer, ptr %41, i32 0, i32 2
  %43 = getelementptr inbounds %struct.TokenStream, ptr %42, i32 0, i32 2
  store i64 %40, ptr %43, align 8
  br label %44

44:                                               ; preds = %35, %2
  %45 = call noalias ptr @malloc(i64 noundef 3) #11
  store ptr %45, ptr %8, align 8
  %46 = load ptr, ptr %8, align 8
  %47 = icmp ne ptr %46, null
  br i1 %47, label %49, label %48

48:                                               ; preds = %44
  store i1 false, ptr %3, align 1
  br label %86

49:                                               ; preds = %44
  %50 = load ptr, ptr %8, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %50, ptr align 1 @.str.6, i64 3, i1 false)
  %51 = load ptr, ptr %4, align 8
  %52 = getelementptr inbounds %struct.Lexer, ptr %51, i32 0, i32 2
  %53 = getelementptr inbounds %struct.TokenStream, ptr %52, i32 0, i32 0
  %54 = load ptr, ptr %53, align 8
  %55 = load ptr, ptr %4, align 8
  %56 = getelementptr inbounds %struct.Lexer, ptr %55, i32 0, i32 2
  %57 = getelementptr inbounds %struct.TokenStream, ptr %56, i32 0, i32 1
  %58 = load i64, ptr %57, align 8
  %59 = add i64 %58, 1
  store i64 %59, ptr %57, align 8
  %60 = getelementptr inbounds %struct.LexerToken, ptr %54, i64 %58
  %61 = getelementptr inbounds %struct.LexerToken, ptr %9, i32 0, i32 0
  store i32 7, ptr %61, align 8
  %62 = getelementptr inbounds %struct.LexerToken, ptr %9, i32 0, i32 1
  %63 = load ptr, ptr %8, align 8
  store ptr %63, ptr %62, align 8
  %64 = getelementptr inbounds %struct.LexerToken, ptr %9, i32 0, i32 2
  store i64 0, ptr %64, align 8
  %65 = getelementptr inbounds %struct.LexerToken, ptr %9, i32 0, i32 3
  %66 = load ptr, ptr %4, align 8
  %67 = getelementptr inbounds %struct.Lexer, ptr %66, i32 0, i32 5
  %68 = load i64, ptr %67, align 8
  store i64 %68, ptr %65, align 8
  %69 = getelementptr inbounds %struct.LexerToken, ptr %9, i32 0, i32 4
  %70 = load ptr, ptr %4, align 8
  %71 = getelementptr inbounds %struct.Lexer, ptr %70, i32 0, i32 6
  %72 = load i64, ptr %71, align 8
  store i64 %72, ptr %69, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %60, ptr align 8 %9, i64 40, i1 false)
  %73 = load ptr, ptr %4, align 8
  %74 = getelementptr inbounds %struct.Lexer, ptr %73, i32 0, i32 7
  %75 = load i64, ptr %74, align 8
  %76 = add i64 %75, 1
  store i64 %76, ptr %74, align 8
  %77 = load ptr, ptr @stderr, align 8
  %78 = load ptr, ptr %4, align 8
  %79 = getelementptr inbounds %struct.Lexer, ptr %78, i32 0, i32 5
  %80 = load i64, ptr %79, align 8
  %81 = load ptr, ptr %4, align 8
  %82 = getelementptr inbounds %struct.Lexer, ptr %81, i32 0, i32 6
  %83 = load i64, ptr %82, align 8
  %84 = load ptr, ptr %5, align 8
  %85 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %77, ptr noundef @.str.7, i64 noundef %80, i64 noundef %83, ptr noundef %84) #10
  store i1 true, ptr %3, align 1
  br label %86

86:                                               ; preds = %49, %48, %34
  %87 = load i1, ptr %3, align 1
  ret i1 %87
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @emit(ptr noundef %0, i32 noundef %1, ptr noundef %2) #0 {
  %4 = alloca i1, align 1
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca ptr, align 8
  %8 = alloca %struct.Lexeme, align 8
  %9 = alloca ptr, align 8
  %10 = alloca i64, align 8
  %11 = alloca double, align 8
  %12 = alloca i64, align 8
  %13 = alloca ptr, align 8
  %14 = alloca %struct.LexerToken, align 8
  store ptr %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store ptr %2, ptr %7, align 8
  %15 = load ptr, ptr %5, align 8
  %16 = getelementptr inbounds %struct.Lexer, ptr %15, i32 0, i32 0
  %17 = call zeroext i1 @reader_lexeme(ptr noundef %16, ptr noundef %8)
  br i1 %17, label %19, label %18

18:                                               ; preds = %3
  store i1 false, ptr %4, align 1
  br label %130

19:                                               ; preds = %3
  %20 = call ptr @copy_lexeme(ptr noundef %8)
  store ptr %20, ptr %9, align 8
  %21 = load ptr, ptr %9, align 8
  %22 = icmp ne ptr %21, null
  br i1 %22, label %24, label %23

23:                                               ; preds = %19
  store i1 false, ptr %4, align 1
  br label %130

24:                                               ; preds = %19
  store i64 0, ptr %10, align 8
  %25 = load i32, ptr %6, align 4
  %26 = icmp eq i32 %25, 0
  br i1 %26, label %27, label %37

27:                                               ; preds = %24
  %28 = load ptr, ptr %5, align 8
  %29 = getelementptr inbounds %struct.Lexer, ptr %28, i32 0, i32 1
  %30 = load ptr, ptr %9, align 8
  %31 = call i64 @symbol_table_add(ptr noundef %29, ptr noundef %30)
  store i64 %31, ptr %10, align 8
  %32 = load i64, ptr %10, align 8
  %33 = icmp eq i64 %32, -1
  br i1 %33, label %34, label %36

34:                                               ; preds = %27
  %35 = load ptr, ptr %9, align 8
  call void @free(ptr noundef %35) #10
  store i1 false, ptr %4, align 1
  br label %130

36:                                               ; preds = %27
  br label %51

37:                                               ; preds = %24
  %38 = load i32, ptr %6, align 4
  %39 = icmp eq i32 %38, 1
  br i1 %39, label %40, label %43

40:                                               ; preds = %37
  %41 = load ptr, ptr %9, align 8
  %42 = call i64 @strtoll(ptr noundef %41, ptr noundef null, i32 noundef 10) #10
  store i64 %42, ptr %10, align 8
  br label %50

43:                                               ; preds = %37
  %44 = load i32, ptr %6, align 4
  %45 = icmp eq i32 %44, 2
  br i1 %45, label %46, label %49

46:                                               ; preds = %43
  %47 = load ptr, ptr %9, align 8
  %48 = call double @strtod(ptr noundef %47, ptr noundef null) #10
  store double %48, ptr %11, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %10, ptr align 8 %11, i64 8, i1 false)
  br label %49

49:                                               ; preds = %46, %43
  br label %50

50:                                               ; preds = %49, %40
  br label %51

51:                                               ; preds = %50, %36
  %52 = load ptr, ptr %5, align 8
  %53 = getelementptr inbounds %struct.Lexer, ptr %52, i32 0, i32 2
  %54 = getelementptr inbounds %struct.TokenStream, ptr %53, i32 0, i32 1
  %55 = load i64, ptr %54, align 8
  %56 = load ptr, ptr %5, align 8
  %57 = getelementptr inbounds %struct.Lexer, ptr %56, i32 0, i32 2
  %58 = getelementptr inbounds %struct.TokenStream, ptr %57, i32 0, i32 2
  %59 = load i64, ptr %58, align 8
  %60 = icmp eq i64 %55, %59
  br i1 %60, label %61, label %87

61:                                               ; preds = %51
  %62 = load ptr, ptr %5, align 8
  %63 = getelementptr inbounds %struct.Lexer, ptr %62, i32 0, i32 2
  %64 = getelementptr inbounds %struct.TokenStream, ptr %63, i32 0, i32 2
  %65 = load i64, ptr %64, align 8
  %66 = mul i64 %65, 2
  store i64 %66, ptr %12, align 8
  %67 = load ptr, ptr %5, align 8
  %68 = getelementptr inbounds %struct.Lexer, ptr %67, i32 0, i32 2
  %69 = getelementptr inbounds %struct.TokenStream, ptr %68, i32 0, i32 0
  %70 = load ptr, ptr %69, align 8
  %71 = load i64, ptr %12, align 8
  %72 = mul i64 %71, 40
  %73 = call ptr @realloc(ptr noundef %70, i64 noundef %72) #12
  store ptr %73, ptr %13, align 8
  %74 = load ptr, ptr %13, align 8
  %75 = icmp ne ptr %74, null
  br i1 %75, label %78, label %76

76:                                               ; preds = %61
  %77 = load ptr, ptr %9, align 8
  call void @free(ptr noundef %77) #10
  store i1 false, ptr %4, align 1
  br label %130

78:                                               ; preds = %61
  %79 = load ptr, ptr %13, align 8
  %80 = load ptr, ptr %5, align 8
  %81 = getelementptr inbounds %struct.Lexer, ptr %80, i32 0, i32 2
  %82 = getelementptr inbounds %struct.TokenStream, ptr %81, i32 0, i32 0
  store ptr %79, ptr %82, align 8
  %83 = load i64, ptr %12, align 8
  %84 = load ptr, ptr %5, align 8
  %85 = getelementptr inbounds %struct.Lexer, ptr %84, i32 0, i32 2
  %86 = getelementptr inbounds %struct.TokenStream, ptr %85, i32 0, i32 2
  store i64 %83, ptr %86, align 8
  br label %87

87:                                               ; preds = %78, %51
  %88 = load ptr, ptr %5, align 8
  %89 = getelementptr inbounds %struct.Lexer, ptr %88, i32 0, i32 2
  %90 = getelementptr inbounds %struct.TokenStream, ptr %89, i32 0, i32 0
  %91 = load ptr, ptr %90, align 8
  %92 = load ptr, ptr %5, align 8
  %93 = getelementptr inbounds %struct.Lexer, ptr %92, i32 0, i32 2
  %94 = getelementptr inbounds %struct.TokenStream, ptr %93, i32 0, i32 1
  %95 = load i64, ptr %94, align 8
  %96 = add i64 %95, 1
  store i64 %96, ptr %94, align 8
  %97 = getelementptr inbounds %struct.LexerToken, ptr %91, i64 %95
  %98 = getelementptr inbounds %struct.LexerToken, ptr %14, i32 0, i32 0
  %99 = load i32, ptr %6, align 4
  store i32 %99, ptr %98, align 8
  %100 = getelementptr inbounds %struct.LexerToken, ptr %14, i32 0, i32 1
  %101 = load ptr, ptr %9, align 8
  store ptr %101, ptr %100, align 8
  %102 = getelementptr inbounds %struct.LexerToken, ptr %14, i32 0, i32 2
  %103 = load i64, ptr %10, align 8
  store i64 %103, ptr %102, align 8
  %104 = getelementptr inbounds %struct.LexerToken, ptr %14, i32 0, i32 3
  %105 = load ptr, ptr %5, align 8
  %106 = getelementptr inbounds %struct.Lexer, ptr %105, i32 0, i32 5
  %107 = load i64, ptr %106, align 8
  store i64 %107, ptr %104, align 8
  %108 = getelementptr inbounds %struct.LexerToken, ptr %14, i32 0, i32 4
  %109 = load ptr, ptr %5, align 8
  %110 = getelementptr inbounds %struct.Lexer, ptr %109, i32 0, i32 6
  %111 = load i64, ptr %110, align 8
  store i64 %111, ptr %108, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %97, ptr align 8 %14, i64 40, i1 false)
  %112 = load ptr, ptr %7, align 8
  %113 = icmp ne ptr %112, null
  br i1 %113, label %114, label %129

114:                                              ; preds = %87
  %115 = load ptr, ptr %5, align 8
  %116 = getelementptr inbounds %struct.Lexer, ptr %115, i32 0, i32 7
  %117 = load i64, ptr %116, align 8
  %118 = add i64 %117, 1
  store i64 %118, ptr %116, align 8
  %119 = load ptr, ptr @stderr, align 8
  %120 = load ptr, ptr %5, align 8
  %121 = getelementptr inbounds %struct.Lexer, ptr %120, i32 0, i32 5
  %122 = load i64, ptr %121, align 8
  %123 = load ptr, ptr %5, align 8
  %124 = getelementptr inbounds %struct.Lexer, ptr %123, i32 0, i32 6
  %125 = load i64, ptr %124, align 8
  %126 = load ptr, ptr %7, align 8
  %127 = load ptr, ptr %9, align 8
  %128 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %119, ptr noundef @.str.8, i64 noundef %122, i64 noundef %125, ptr noundef %126, ptr noundef %127) #10
  br label %129

129:                                              ; preds = %114, %87
  store i1 true, ptr %4, align 1
  br label %130

130:                                              ; preds = %129, %76, %34, %23, %18
  %131 = load i1, ptr %4, align 1
  ret i1 %131
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @letter(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = icmp sge i32 %3, 97
  br i1 %4, label %5, label %8

5:                                                ; preds = %1
  %6 = load i32, ptr %2, align 4
  %7 = icmp sle i32 %6, 122
  br i1 %7, label %17, label %8

8:                                                ; preds = %5, %1
  %9 = load i32, ptr %2, align 4
  %10 = icmp sge i32 %9, 65
  br i1 %10, label %11, label %14

11:                                               ; preds = %8
  %12 = load i32, ptr %2, align 4
  %13 = icmp sle i32 %12, 90
  br i1 %13, label %17, label %14

14:                                               ; preds = %11, %8
  %15 = load i32, ptr %2, align 4
  %16 = icmp eq i32 %15, 95
  br label %17

17:                                               ; preds = %14, %11, %5
  %18 = phi i1 [ true, %11 ], [ true, %5 ], [ %16, %14 ]
  ret i1 %18
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @scan_word(ptr noundef %0) #0 {
  %2 = alloca i1, align 1
  %3 = alloca ptr, align 8
  %4 = alloca %struct.Lexeme, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca ptr, align 8
  %10 = alloca %struct.LexerToken, align 8
  store ptr %0, ptr %3, align 8
  br label %11

11:                                               ; preds = %13, %1
  %12 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %12)
  br label %13

13:                                               ; preds = %11
  %14 = load ptr, ptr %3, align 8
  %15 = call i32 @peek(ptr noundef %14)
  %16 = call zeroext i1 @alnum(i32 noundef %15)
  br i1 %16, label %11, label %17, !llvm.loop !16

17:                                               ; preds = %13
  %18 = load ptr, ptr %3, align 8
  %19 = getelementptr inbounds %struct.Lexer, ptr %18, i32 0, i32 0
  %20 = call zeroext i1 @reader_lexeme(ptr noundef %19, ptr noundef %4)
  br i1 %20, label %22, label %21

21:                                               ; preds = %17
  store i1 false, ptr %2, align 1
  br label %123

22:                                               ; preds = %17
  %23 = call ptr @copy_lexeme(ptr noundef %4)
  store ptr %23, ptr %5, align 8
  %24 = load ptr, ptr %5, align 8
  %25 = icmp ne ptr %24, null
  br i1 %25, label %27, label %26

26:                                               ; preds = %22
  store i1 false, ptr %2, align 1
  br label %123

27:                                               ; preds = %22
  %28 = load ptr, ptr %5, align 8
  %29 = call i32 @strcmp(ptr noundef %28, ptr noundef @.str.9) #13
  %30 = icmp ne i32 %29, 0
  br i1 %30, label %31, label %35

31:                                               ; preds = %27
  %32 = load ptr, ptr %5, align 8
  %33 = call i32 @strcmp(ptr noundef %32, ptr noundef @.str.10) #13
  %34 = icmp ne i32 %33, 0
  br i1 %34, label %36, label %35

35:                                               ; preds = %31, %27
  br label %48

36:                                               ; preds = %31
  %37 = load ptr, ptr %5, align 8
  %38 = call i32 @strcmp(ptr noundef %37, ptr noundef @.str.11) #13
  %39 = icmp ne i32 %38, 0
  br i1 %39, label %41, label %40

40:                                               ; preds = %36
  br label %46

41:                                               ; preds = %36
  %42 = load ptr, ptr %5, align 8
  %43 = call zeroext i1 @keyword(ptr noundef %42)
  %44 = zext i1 %43 to i64
  %45 = select i1 %43, i32 9, i32 0
  br label %46

46:                                               ; preds = %41, %40
  %47 = phi i32 [ 6, %40 ], [ %45, %41 ]
  br label %48

48:                                               ; preds = %46, %35
  %49 = phi i32 [ 5, %35 ], [ %47, %46 ]
  store i32 %49, ptr %6, align 4
  store i64 0, ptr %7, align 8
  %50 = load i32, ptr %6, align 4
  %51 = icmp eq i32 %50, 0
  br i1 %51, label %52, label %62

52:                                               ; preds = %48
  %53 = load ptr, ptr %3, align 8
  %54 = getelementptr inbounds %struct.Lexer, ptr %53, i32 0, i32 1
  %55 = load ptr, ptr %5, align 8
  %56 = call i64 @symbol_table_add(ptr noundef %54, ptr noundef %55)
  store i64 %56, ptr %7, align 8
  %57 = load i64, ptr %7, align 8
  %58 = icmp eq i64 %57, -1
  br i1 %58, label %59, label %61

59:                                               ; preds = %52
  %60 = load ptr, ptr %5, align 8
  call void @free(ptr noundef %60) #10
  store i1 false, ptr %2, align 1
  br label %123

61:                                               ; preds = %52
  br label %62

62:                                               ; preds = %61, %48
  %63 = load ptr, ptr %3, align 8
  %64 = getelementptr inbounds %struct.Lexer, ptr %63, i32 0, i32 2
  %65 = getelementptr inbounds %struct.TokenStream, ptr %64, i32 0, i32 1
  %66 = load i64, ptr %65, align 8
  %67 = load ptr, ptr %3, align 8
  %68 = getelementptr inbounds %struct.Lexer, ptr %67, i32 0, i32 2
  %69 = getelementptr inbounds %struct.TokenStream, ptr %68, i32 0, i32 2
  %70 = load i64, ptr %69, align 8
  %71 = icmp eq i64 %66, %70
  br i1 %71, label %72, label %98

72:                                               ; preds = %62
  %73 = load ptr, ptr %3, align 8
  %74 = getelementptr inbounds %struct.Lexer, ptr %73, i32 0, i32 2
  %75 = getelementptr inbounds %struct.TokenStream, ptr %74, i32 0, i32 2
  %76 = load i64, ptr %75, align 8
  %77 = mul i64 %76, 2
  store i64 %77, ptr %8, align 8
  %78 = load ptr, ptr %3, align 8
  %79 = getelementptr inbounds %struct.Lexer, ptr %78, i32 0, i32 2
  %80 = getelementptr inbounds %struct.TokenStream, ptr %79, i32 0, i32 0
  %81 = load ptr, ptr %80, align 8
  %82 = load i64, ptr %8, align 8
  %83 = mul i64 %82, 40
  %84 = call ptr @realloc(ptr noundef %81, i64 noundef %83) #12
  store ptr %84, ptr %9, align 8
  %85 = load ptr, ptr %9, align 8
  %86 = icmp ne ptr %85, null
  br i1 %86, label %89, label %87

87:                                               ; preds = %72
  %88 = load ptr, ptr %5, align 8
  call void @free(ptr noundef %88) #10
  store i1 false, ptr %2, align 1
  br label %123

89:                                               ; preds = %72
  %90 = load ptr, ptr %9, align 8
  %91 = load ptr, ptr %3, align 8
  %92 = getelementptr inbounds %struct.Lexer, ptr %91, i32 0, i32 2
  %93 = getelementptr inbounds %struct.TokenStream, ptr %92, i32 0, i32 0
  store ptr %90, ptr %93, align 8
  %94 = load i64, ptr %8, align 8
  %95 = load ptr, ptr %3, align 8
  %96 = getelementptr inbounds %struct.Lexer, ptr %95, i32 0, i32 2
  %97 = getelementptr inbounds %struct.TokenStream, ptr %96, i32 0, i32 2
  store i64 %94, ptr %97, align 8
  br label %98

98:                                               ; preds = %89, %62
  %99 = load ptr, ptr %3, align 8
  %100 = getelementptr inbounds %struct.Lexer, ptr %99, i32 0, i32 2
  %101 = getelementptr inbounds %struct.TokenStream, ptr %100, i32 0, i32 0
  %102 = load ptr, ptr %101, align 8
  %103 = load ptr, ptr %3, align 8
  %104 = getelementptr inbounds %struct.Lexer, ptr %103, i32 0, i32 2
  %105 = getelementptr inbounds %struct.TokenStream, ptr %104, i32 0, i32 1
  %106 = load i64, ptr %105, align 8
  %107 = add i64 %106, 1
  store i64 %107, ptr %105, align 8
  %108 = getelementptr inbounds %struct.LexerToken, ptr %102, i64 %106
  %109 = getelementptr inbounds %struct.LexerToken, ptr %10, i32 0, i32 0
  %110 = load i32, ptr %6, align 4
  store i32 %110, ptr %109, align 8
  %111 = getelementptr inbounds %struct.LexerToken, ptr %10, i32 0, i32 1
  %112 = load ptr, ptr %5, align 8
  store ptr %112, ptr %111, align 8
  %113 = getelementptr inbounds %struct.LexerToken, ptr %10, i32 0, i32 2
  %114 = load i64, ptr %7, align 8
  store i64 %114, ptr %113, align 8
  %115 = getelementptr inbounds %struct.LexerToken, ptr %10, i32 0, i32 3
  %116 = load ptr, ptr %3, align 8
  %117 = getelementptr inbounds %struct.Lexer, ptr %116, i32 0, i32 5
  %118 = load i64, ptr %117, align 8
  store i64 %118, ptr %115, align 8
  %119 = getelementptr inbounds %struct.LexerToken, ptr %10, i32 0, i32 4
  %120 = load ptr, ptr %3, align 8
  %121 = getelementptr inbounds %struct.Lexer, ptr %120, i32 0, i32 6
  %122 = load i64, ptr %121, align 8
  store i64 %122, ptr %119, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %108, ptr align 8 %10, i64 40, i1 false)
  store i1 true, ptr %2, align 1
  br label %123

123:                                              ; preds = %98, %87, %59, %26, %21
  %124 = load i1, ptr %2, align 1
  ret i1 %124
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @digit(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = icmp sge i32 %3, 48
  br i1 %4, label %5, label %8

5:                                                ; preds = %1
  %6 = load i32, ptr %2, align 4
  %7 = icmp sle i32 %6, 57
  br label %8

8:                                                ; preds = %5, %1
  %9 = phi i1 [ false, %1 ], [ %7, %5 ]
  ret i1 %9
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @scan_number(ptr noundef %0, i1 noundef zeroext %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i8, align 1
  %5 = alloca i8, align 1
  %6 = alloca i8, align 1
  %7 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  %8 = zext i1 %1 to i8
  store i8 %8, ptr %4, align 1
  %9 = load i8, ptr %4, align 1
  %10 = trunc i8 %9 to i1
  %11 = zext i1 %10 to i8
  store i8 %11, ptr %5, align 1
  store i8 0, ptr %6, align 1
  %12 = load i8, ptr %4, align 1
  %13 = trunc i8 %12 to i1
  br i1 %13, label %14, label %16

14:                                               ; preds = %2
  %15 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %15)
  br label %16

16:                                               ; preds = %14, %2
  br label %17

17:                                               ; preds = %21, %16
  %18 = load ptr, ptr %3, align 8
  %19 = call i32 @peek(ptr noundef %18)
  %20 = call zeroext i1 @digit(i32 noundef %19)
  br i1 %20, label %21, label %23

21:                                               ; preds = %17
  %22 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %22)
  br label %17, !llvm.loop !17

23:                                               ; preds = %17
  %24 = load i8, ptr %4, align 1
  %25 = trunc i8 %24 to i1
  br i1 %25, label %39, label %26

26:                                               ; preds = %23
  %27 = load ptr, ptr %3, align 8
  %28 = call i32 @peek(ptr noundef %27)
  %29 = icmp eq i32 %28, 46
  br i1 %29, label %30, label %39

30:                                               ; preds = %26
  store i8 1, ptr %5, align 1
  %31 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %31)
  br label %32

32:                                               ; preds = %36, %30
  %33 = load ptr, ptr %3, align 8
  %34 = call i32 @peek(ptr noundef %33)
  %35 = call zeroext i1 @digit(i32 noundef %34)
  br i1 %35, label %36, label %38

36:                                               ; preds = %32
  %37 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %37)
  br label %32, !llvm.loop !18

38:                                               ; preds = %32
  br label %39

39:                                               ; preds = %38, %26, %23
  %40 = load ptr, ptr %3, align 8
  %41 = call i32 @peek(ptr noundef %40)
  %42 = icmp eq i32 %41, 44
  br i1 %42, label %47, label %43

43:                                               ; preds = %39
  %44 = load ptr, ptr %3, align 8
  %45 = call i32 @peek(ptr noundef %44)
  %46 = icmp eq i32 %45, 46
  br i1 %46, label %47, label %82

47:                                               ; preds = %43, %39
  %48 = load ptr, ptr %3, align 8
  %49 = call i32 @peek(ptr noundef %48)
  store i32 %49, ptr %7, align 4
  %50 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %50)
  %51 = load ptr, ptr %3, align 8
  %52 = call i32 @peek(ptr noundef %51)
  %53 = call zeroext i1 @digit(i32 noundef %52)
  br i1 %53, label %54, label %72

54:                                               ; preds = %47
  store i8 1, ptr %6, align 1
  br label %55

55:                                               ; preds = %69, %54
  %56 = load ptr, ptr %3, align 8
  %57 = call i32 @peek(ptr noundef %56)
  %58 = call zeroext i1 @digit(i32 noundef %57)
  br i1 %58, label %67, label %59

59:                                               ; preds = %55
  %60 = load ptr, ptr %3, align 8
  %61 = call i32 @peek(ptr noundef %60)
  %62 = call zeroext i1 @letter(i32 noundef %61)
  br i1 %62, label %67, label %63

63:                                               ; preds = %59
  %64 = load ptr, ptr %3, align 8
  %65 = call i32 @peek(ptr noundef %64)
  %66 = icmp eq i32 %65, 46
  br label %67

67:                                               ; preds = %63, %59, %55
  %68 = phi i1 [ true, %59 ], [ true, %55 ], [ %66, %63 ]
  br i1 %68, label %69, label %71

69:                                               ; preds = %67
  %70 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %70)
  br label %55, !llvm.loop !19

71:                                               ; preds = %67
  br label %81

72:                                               ; preds = %47
  %73 = load i32, ptr %7, align 4
  %74 = icmp eq i32 %73, 46
  br i1 %74, label %75, label %79

75:                                               ; preds = %72
  %76 = load i8, ptr %6, align 1
  %77 = trunc i8 %76 to i1
  br i1 %77, label %79, label %78

78:                                               ; preds = %75
  store i8 1, ptr %6, align 1
  br label %80

79:                                               ; preds = %75, %72
  store i8 1, ptr %6, align 1
  br label %80

80:                                               ; preds = %79, %78
  br label %81

81:                                               ; preds = %80, %71
  br label %82

82:                                               ; preds = %81, %43
  %83 = load ptr, ptr %3, align 8
  %84 = call i32 @peek(ptr noundef %83)
  %85 = call zeroext i1 @letter(i32 noundef %84)
  br i1 %85, label %86, label %94

86:                                               ; preds = %82
  store i8 1, ptr %6, align 1
  br label %87

87:                                               ; preds = %89, %86
  %88 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %88)
  br label %89

89:                                               ; preds = %87
  %90 = load ptr, ptr %3, align 8
  %91 = call i32 @peek(ptr noundef %90)
  %92 = call zeroext i1 @alnum(i32 noundef %91)
  br i1 %92, label %87, label %93, !llvm.loop !20

93:                                               ; preds = %89
  br label %94

94:                                               ; preds = %93, %82
  %95 = load ptr, ptr %3, align 8
  %96 = load i8, ptr %6, align 1
  %97 = trunc i8 %96 to i1
  br i1 %97, label %98, label %99

98:                                               ; preds = %94
  br label %104

99:                                               ; preds = %94
  %100 = load i8, ptr %5, align 1
  %101 = trunc i8 %100 to i1
  %102 = zext i1 %101 to i64
  %103 = select i1 %101, i32 2, i32 1
  br label %104

104:                                              ; preds = %99, %98
  %105 = phi i32 [ 7, %98 ], [ %103, %99 ]
  %106 = load i8, ptr %6, align 1
  %107 = trunc i8 %106 to i1
  %108 = zext i1 %107 to i64
  %109 = select i1 %107, ptr @.str.32, ptr null
  %110 = call zeroext i1 @emit(ptr noundef %95, i32 noundef %105, ptr noundef %109)
  ret i1 %110
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @scan_quoted(ptr noundef %0, i32 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i8, align 1
  %6 = alloca i8, align 1
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 %1, ptr %4, align 4
  store i8 0, ptr %5, align 1
  store i8 0, ptr %6, align 1
  store i32 0, ptr %7, align 4
  %9 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %9)
  br label %10

10:                                               ; preds = %55, %2
  %11 = load ptr, ptr %3, align 8
  %12 = call i32 @peek(ptr noundef %11)
  %13 = icmp sge i32 %12, 0
  br i1 %13, label %14, label %22

14:                                               ; preds = %10
  %15 = load ptr, ptr %3, align 8
  %16 = call i32 @peek(ptr noundef %15)
  %17 = icmp ne i32 %16, 10
  br i1 %17, label %18, label %22

18:                                               ; preds = %14
  %19 = load ptr, ptr %3, align 8
  %20 = call i32 @peek(ptr noundef %19)
  %21 = icmp ne i32 %20, 13
  br label %22

22:                                               ; preds = %18, %14, %10
  %23 = phi i1 [ false, %14 ], [ false, %10 ], [ %21, %18 ]
  br i1 %23, label %24, label %56

24:                                               ; preds = %22
  %25 = load ptr, ptr %3, align 8
  %26 = call i32 @peek(ptr noundef %25)
  store i32 %26, ptr %8, align 4
  %27 = load i32, ptr %8, align 4
  %28 = load i32, ptr %4, align 4
  %29 = icmp eq i32 %27, %28
  br i1 %29, label %30, label %32

30:                                               ; preds = %24
  %31 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %31)
  store i8 1, ptr %6, align 1
  br label %56

32:                                               ; preds = %24
  %33 = load i32, ptr %8, align 4
  %34 = icmp eq i32 %33, 92
  br i1 %34, label %35, label %51

35:                                               ; preds = %32
  %36 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %36)
  %37 = load ptr, ptr %3, align 8
  %38 = call i32 @peek(ptr noundef %37)
  %39 = call zeroext i1 @escape(i32 noundef %38)
  br i1 %39, label %46, label %40

40:                                               ; preds = %35
  store i8 1, ptr %5, align 1
  %41 = load ptr, ptr %3, align 8
  %42 = call i32 @peek(ptr noundef %41)
  %43 = icmp slt i32 %42, 0
  br i1 %43, label %44, label %45

44:                                               ; preds = %40
  br label %56

45:                                               ; preds = %40
  br label %49

46:                                               ; preds = %35
  %47 = load i32, ptr %7, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, ptr %7, align 4
  br label %49

49:                                               ; preds = %46, %45
  %50 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %50)
  br label %55

51:                                               ; preds = %32
  %52 = load i32, ptr %7, align 4
  %53 = add nsw i32 %52, 1
  store i32 %53, ptr %7, align 4
  %54 = load ptr, ptr %3, align 8
  call void @step(ptr noundef %54)
  br label %55

55:                                               ; preds = %51, %49
  br label %10, !llvm.loop !21

56:                                               ; preds = %44, %30, %22
  %57 = load i8, ptr %6, align 1
  %58 = trunc i8 %57 to i1
  br i1 %58, label %59, label %65

59:                                               ; preds = %56
  %60 = load i32, ptr %4, align 4
  %61 = icmp eq i32 %60, 39
  br i1 %61, label %62, label %66

62:                                               ; preds = %59
  %63 = load i32, ptr %7, align 4
  %64 = icmp ne i32 %63, 1
  br i1 %64, label %65, label %66

65:                                               ; preds = %62, %56
  store i8 1, ptr %5, align 1
  br label %66

66:                                               ; preds = %65, %62, %59
  %67 = load ptr, ptr %3, align 8
  %68 = load i8, ptr %5, align 1
  %69 = trunc i8 %68 to i1
  br i1 %69, label %70, label %71

70:                                               ; preds = %66
  br label %76

71:                                               ; preds = %66
  %72 = load i32, ptr %4, align 4
  %73 = icmp eq i32 %72, 39
  %74 = zext i1 %73 to i64
  %75 = select i1 %73, i32 3, i32 4
  br label %76

76:                                               ; preds = %71, %70
  %77 = phi i32 [ 7, %70 ], [ %75, %71 ]
  %78 = load i8, ptr %5, align 1
  %79 = trunc i8 %78 to i1
  %80 = zext i1 %79 to i64
  %81 = select i1 %79, ptr @.str.33, ptr null
  %82 = call zeroext i1 @emit(ptr noundef %67, i32 noundef %77, ptr noundef %81)
  ret i1 %82
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @delimiter(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = icmp eq i32 %3, 59
  br i1 %4, label %29, label %5

5:                                                ; preds = %1
  %6 = load i32, ptr %2, align 4
  %7 = icmp eq i32 %6, 44
  br i1 %7, label %29, label %8

8:                                                ; preds = %5
  %9 = load i32, ptr %2, align 4
  %10 = icmp eq i32 %9, 46
  br i1 %10, label %29, label %11

11:                                               ; preds = %8
  %12 = load i32, ptr %2, align 4
  %13 = icmp eq i32 %12, 40
  br i1 %13, label %29, label %14

14:                                               ; preds = %11
  %15 = load i32, ptr %2, align 4
  %16 = icmp eq i32 %15, 41
  br i1 %16, label %29, label %17

17:                                               ; preds = %14
  %18 = load i32, ptr %2, align 4
  %19 = icmp eq i32 %18, 123
  br i1 %19, label %29, label %20

20:                                               ; preds = %17
  %21 = load i32, ptr %2, align 4
  %22 = icmp eq i32 %21, 125
  br i1 %22, label %29, label %23

23:                                               ; preds = %20
  %24 = load i32, ptr %2, align 4
  %25 = icmp eq i32 %24, 91
  br i1 %25, label %29, label %26

26:                                               ; preds = %23
  %27 = load i32, ptr %2, align 4
  %28 = icmp eq i32 %27, 93
  br label %29

29:                                               ; preds = %26, %23, %20, %17, %14, %11, %8, %5, %1
  %30 = phi i1 [ true, %23 ], [ true, %20 ], [ true, %17 ], [ true, %14 ], [ true, %11 ], [ true, %8 ], [ true, %5 ], [ true, %1 ], [ %28, %26 ]
  ret i1 %30
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @operator_prefix(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca i1, align 1
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  store i32 0, ptr %6, align 4
  br label %7

7:                                                ; preds = %32, %2
  %8 = load i32, ptr %6, align 4
  %9 = sext i32 %8 to i64
  %10 = getelementptr inbounds [34 x ptr], ptr @operators, i64 0, i64 %9
  %11 = load ptr, ptr %10, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %13, label %35

13:                                               ; preds = %7
  %14 = load i32, ptr %6, align 4
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds [34 x ptr], ptr @operators, i64 0, i64 %15
  %17 = load ptr, ptr %16, align 8
  %18 = call i64 @strlen(ptr noundef %17) #13
  %19 = load i64, ptr %5, align 8
  %20 = icmp uge i64 %18, %19
  br i1 %20, label %21, label %31

21:                                               ; preds = %13
  %22 = load ptr, ptr %4, align 8
  %23 = load i32, ptr %6, align 4
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds [34 x ptr], ptr @operators, i64 0, i64 %24
  %26 = load ptr, ptr %25, align 8
  %27 = load i64, ptr %5, align 8
  %28 = call i32 @strncmp(ptr noundef %22, ptr noundef %26, i64 noundef %27) #13
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %31, label %30

30:                                               ; preds = %21
  store i1 true, ptr %3, align 1
  br label %36

31:                                               ; preds = %21, %13
  br label %32

32:                                               ; preds = %31
  %33 = load i32, ptr %6, align 4
  %34 = add nsw i32 %33, 1
  store i32 %34, ptr %6, align 4
  br label %7, !llvm.loop !22

35:                                               ; preds = %7
  store i1 false, ptr %3, align 1
  br label %36

36:                                               ; preds = %35, %30
  %37 = load i1, ptr %3, align 1
  ret i1 %37
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @scan_operator(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca [5 x i8], align 1
  %4 = alloca i64, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.memset.p0.i64(ptr align 1 %3, i8 0, i64 5, i1 false)
  store i64 0, ptr %4, align 8
  br label %5

5:                                                ; preds = %25, %1
  %6 = load i64, ptr %4, align 8
  %7 = icmp ult i64 %6, 4
  br i1 %7, label %8, label %12

8:                                                ; preds = %5
  %9 = load ptr, ptr %2, align 8
  %10 = call i32 @peek(ptr noundef %9)
  %11 = icmp sge i32 %10, 0
  br label %12

12:                                               ; preds = %8, %5
  %13 = phi i1 [ false, %5 ], [ %11, %8 ]
  br i1 %13, label %14, label %29

14:                                               ; preds = %12
  %15 = load ptr, ptr %2, align 8
  %16 = call i32 @peek(ptr noundef %15)
  %17 = trunc i32 %16 to i8
  %18 = load i64, ptr %4, align 8
  %19 = getelementptr inbounds [5 x i8], ptr %3, i64 0, i64 %18
  store i8 %17, ptr %19, align 1
  %20 = getelementptr inbounds [5 x i8], ptr %3, i64 0, i64 0
  %21 = load i64, ptr %4, align 8
  %22 = add i64 %21, 1
  %23 = call zeroext i1 @operator_prefix(ptr noundef %20, i64 noundef %22)
  br i1 %23, label %25, label %24

24:                                               ; preds = %14
  br label %29

25:                                               ; preds = %14
  %26 = load ptr, ptr %2, align 8
  call void @step(ptr noundef %26)
  %27 = load i64, ptr %4, align 8
  %28 = add i64 %27, 1
  store i64 %28, ptr %4, align 8
  br label %5, !llvm.loop !23

29:                                               ; preds = %24, %12
  %30 = load i64, ptr %4, align 8
  %31 = getelementptr inbounds [5 x i8], ptr %3, i64 0, i64 %30
  store i8 0, ptr %31, align 1
  %32 = load ptr, ptr %2, align 8
  %33 = getelementptr inbounds [5 x i8], ptr %3, i64 0, i64 0
  %34 = call zeroext i1 @operator_exact(ptr noundef %33)
  %35 = zext i1 %34 to i64
  %36 = select i1 %34, i32 10, i32 7
  %37 = getelementptr inbounds [5 x i8], ptr %3, i64 0, i64 0
  %38 = call zeroext i1 @operator_exact(ptr noundef %37)
  %39 = zext i1 %38 to i64
  %40 = select i1 %38, ptr null, ptr @.str.67
  %41 = call zeroext i1 @emit(ptr noundef %32, i32 noundef %36, ptr noundef %40)
  ret i1 %41
}

declare i32 @reader_peek(ptr noundef) #2

declare void @reader_step(ptr noundef) #2

declare void @reader_begin(ptr noundef) #2

; Function Attrs: noinline nounwind optnone uwtable
define internal ptr @copy_lexeme(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %6 = load ptr, ptr %3, align 8
  %7 = getelementptr inbounds %struct.Lexeme, ptr %6, i32 0, i32 1
  %8 = load i64, ptr %7, align 8
  %9 = load ptr, ptr %3, align 8
  %10 = getelementptr inbounds %struct.Lexeme, ptr %9, i32 0, i32 3
  %11 = load i64, ptr %10, align 8
  %12 = add i64 %8, %11
  store i64 %12, ptr %4, align 8
  %13 = load i64, ptr %4, align 8
  %14 = add i64 %13, 1
  %15 = call noalias ptr @malloc(i64 noundef %14) #11
  store ptr %15, ptr %5, align 8
  %16 = load ptr, ptr %5, align 8
  %17 = icmp ne ptr %16, null
  br i1 %17, label %19, label %18

18:                                               ; preds = %1
  store ptr null, ptr %2, align 8
  br label %48

19:                                               ; preds = %1
  %20 = load ptr, ptr %5, align 8
  %21 = load ptr, ptr %3, align 8
  %22 = getelementptr inbounds %struct.Lexeme, ptr %21, i32 0, i32 0
  %23 = load ptr, ptr %22, align 8
  %24 = load ptr, ptr %3, align 8
  %25 = getelementptr inbounds %struct.Lexeme, ptr %24, i32 0, i32 1
  %26 = load i64, ptr %25, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %20, ptr align 1 %23, i64 %26, i1 false)
  %27 = load ptr, ptr %3, align 8
  %28 = getelementptr inbounds %struct.Lexeme, ptr %27, i32 0, i32 3
  %29 = load i64, ptr %28, align 8
  %30 = icmp ne i64 %29, 0
  br i1 %30, label %31, label %43

31:                                               ; preds = %19
  %32 = load ptr, ptr %5, align 8
  %33 = load ptr, ptr %3, align 8
  %34 = getelementptr inbounds %struct.Lexeme, ptr %33, i32 0, i32 1
  %35 = load i64, ptr %34, align 8
  %36 = getelementptr inbounds i8, ptr %32, i64 %35
  %37 = load ptr, ptr %3, align 8
  %38 = getelementptr inbounds %struct.Lexeme, ptr %37, i32 0, i32 2
  %39 = load ptr, ptr %38, align 8
  %40 = load ptr, ptr %3, align 8
  %41 = getelementptr inbounds %struct.Lexeme, ptr %40, i32 0, i32 3
  %42 = load i64, ptr %41, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %36, ptr align 1 %39, i64 %42, i1 false)
  br label %43

43:                                               ; preds = %31, %19
  %44 = load ptr, ptr %5, align 8
  %45 = load i64, ptr %4, align 8
  %46 = getelementptr inbounds i8, ptr %44, i64 %45
  store i8 0, ptr %46, align 1
  %47 = load ptr, ptr %5, align 8
  store ptr %47, ptr %2, align 8
  br label %48

48:                                               ; preds = %43, %18
  %49 = load ptr, ptr %2, align 8
  ret ptr %49
}

declare i64 @symbol_table_add(ptr noundef, ptr noundef) #2

; Function Attrs: nounwind
declare i64 @strtoll(ptr noundef, ptr noundef, i32 noundef) #3

; Function Attrs: nounwind
declare double @strtod(ptr noundef, ptr noundef) #3

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @alnum(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = call zeroext i1 @letter(i32 noundef %3)
  br i1 %4, label %8, label %5

5:                                                ; preds = %1
  %6 = load i32, ptr %2, align 4
  %7 = call zeroext i1 @digit(i32 noundef %6)
  br label %8

8:                                                ; preds = %5, %1
  %9 = phi i1 [ true, %1 ], [ %7, %5 ]
  ret i1 %9
}

; Function Attrs: nounwind willreturn memory(read)
declare i32 @strcmp(ptr noundef, ptr noundef) #8

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @keyword(ptr noundef %0) #0 {
  %2 = alloca i1, align 1
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 0, ptr %4, align 4
  br label %5

5:                                                ; preds = %21, %1
  %6 = load i32, ptr %4, align 4
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds [21 x ptr], ptr @keywords, i64 0, i64 %7
  %9 = load ptr, ptr %8, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %24

11:                                               ; preds = %5
  %12 = load ptr, ptr %3, align 8
  %13 = load i32, ptr %4, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [21 x ptr], ptr @keywords, i64 0, i64 %14
  %16 = load ptr, ptr %15, align 8
  %17 = call i32 @strcmp(ptr noundef %12, ptr noundef %16) #13
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %20, label %19

19:                                               ; preds = %11
  store i1 true, ptr %2, align 1
  br label %25

20:                                               ; preds = %11
  br label %21

21:                                               ; preds = %20
  %22 = load i32, ptr %4, align 4
  %23 = add nsw i32 %22, 1
  store i32 %23, ptr %4, align 4
  br label %5, !llvm.loop !24

24:                                               ; preds = %5
  store i1 false, ptr %2, align 1
  br label %25

25:                                               ; preds = %24, %19
  %26 = load i1, ptr %2, align 1
  ret i1 %26
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @escape(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = icmp eq i32 %3, 98
  br i1 %4, label %26, label %5

5:                                                ; preds = %1
  %6 = load i32, ptr %2, align 4
  %7 = icmp eq i32 %6, 116
  br i1 %7, label %26, label %8

8:                                                ; preds = %5
  %9 = load i32, ptr %2, align 4
  %10 = icmp eq i32 %9, 110
  br i1 %10, label %26, label %11

11:                                               ; preds = %8
  %12 = load i32, ptr %2, align 4
  %13 = icmp eq i32 %12, 102
  br i1 %13, label %26, label %14

14:                                               ; preds = %11
  %15 = load i32, ptr %2, align 4
  %16 = icmp eq i32 %15, 114
  br i1 %16, label %26, label %17

17:                                               ; preds = %14
  %18 = load i32, ptr %2, align 4
  %19 = icmp eq i32 %18, 34
  br i1 %19, label %26, label %20

20:                                               ; preds = %17
  %21 = load i32, ptr %2, align 4
  %22 = icmp eq i32 %21, 39
  br i1 %22, label %26, label %23

23:                                               ; preds = %20
  %24 = load i32, ptr %2, align 4
  %25 = icmp eq i32 %24, 92
  br label %26

26:                                               ; preds = %23, %20, %17, %14, %11, %8, %5, %1
  %27 = phi i1 [ true, %20 ], [ true, %17 ], [ true, %14 ], [ true, %11 ], [ true, %8 ], [ true, %5 ], [ true, %1 ], [ %25, %23 ]
  ret i1 %27
}

; Function Attrs: nounwind willreturn memory(read)
declare i64 @strlen(ptr noundef) #8

; Function Attrs: nounwind willreturn memory(read)
declare i32 @strncmp(ptr noundef, ptr noundef, i64 noundef) #8

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @operator_exact(ptr noundef %0) #0 {
  %2 = alloca i1, align 1
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 0, ptr %4, align 4
  br label %5

5:                                                ; preds = %21, %1
  %6 = load i32, ptr %4, align 4
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds [34 x ptr], ptr @operators, i64 0, i64 %7
  %9 = load ptr, ptr %8, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %24

11:                                               ; preds = %5
  %12 = load ptr, ptr %3, align 8
  %13 = load i32, ptr %4, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [34 x ptr], ptr @operators, i64 0, i64 %14
  %16 = load ptr, ptr %15, align 8
  %17 = call i32 @strcmp(ptr noundef %12, ptr noundef %16) #13
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %20, label %19

19:                                               ; preds = %11
  store i1 true, ptr %2, align 1
  br label %25

20:                                               ; preds = %11
  br label %21

21:                                               ; preds = %20
  %22 = load i32, ptr %4, align 4
  %23 = add nsw i32 %22, 1
  store i32 %23, ptr %4, align 4
  br label %5, !llvm.loop !25

24:                                               ; preds = %5
  store i1 false, ptr %2, align 1
  br label %25

25:                                               ; preds = %24, %19
  %26 = load i1, ptr %2, align 1
  ret i1 %26
}

declare i32 @puts(ptr noundef) #2

declare i32 @putchar(i32 noundef) #2

declare i32 @fputs(ptr noundef, ptr noundef) #2

declare i32 @printf(ptr noundef, ...) #2

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind allocsize(0,1) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind allocsize(1) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #8 = { nounwind willreturn memory(read) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nounwind allocsize(0,1) }
attributes #10 = { nounwind }
attributes #11 = { nounwind allocsize(0) }
attributes #12 = { nounwind allocsize(1) }
attributes #13 = { nounwind willreturn memory(read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Debian clang version 19.1.7 (3+b1)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
!16 = distinct !{!16, !7}
!17 = distinct !{!17, !7}
!18 = distinct !{!18, !7}
!19 = distinct !{!19, !7}
!20 = distinct !{!20, !7}
!21 = distinct !{!21, !7}
!22 = distinct !{!22, !7}
!23 = distinct !{!23, !7}
!24 = distinct !{!24, !7}
!25 = distinct !{!25, !7}
