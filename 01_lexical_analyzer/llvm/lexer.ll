%Reader = type {
    ptr,      ; 0 FILE*
    ptr,      ; 1 buffer 0
    ptr,      ; 2 buffer 1
    i1,       ; 3 active buffer: false = 0, true = 1
    i64,      ; 4 forward position
    i1,       ; 5 begin buffer: false = 0, true = 1
    i64,      ; 6 begin position
    i64,      ; 7 valid bytes in buffer 0
    i64,      ; 8 valid bytes in buffer 1
    i1,       ; 9 file exhausted; buffered bytes may remain
    i1,       ; 10 currently collecting a lexeme
    i32       ; 11 reader status: 0 = ok, -2 = lexeme too long, -3 = read error
}

%Lexeme = type { ptr, i64, ptr, i64 }

%Symbol = type { ptr, i64 }
%SymbolTable = type { ptr, i64, i64 }
%Token = type { i32, ptr, i64 }
%TokenStream = type { ptr, i64, i64 }

;;;;; READER INTERFACE

;; Initialize caller-owned Reader storage. Return reader on success or null on failure.
declare ptr @reader_init(ptr, ptr)

;; Close the file and release the buffers owned by a Reader.
declare void @reader_destroy(ptr)

;; Return the next character without consuming it.
declare i32 @reader_peek(ptr)

;; Move to the next character.
declare void @reader_step(ptr)

;; Mark the current position as the beginning of a new lexeme.
declare void @reader_begin(ptr)

;; Return a %Lexeme
declare i1 @reader_lexeme(ptr, ptr)

;;;;; TABLE INTERFACE

;; Initialize a caller-owned symbol table.
declare i1 @symbol_table_init(ptr)

;; Add an identifier or increment its count. Return its index or -1 on failure.
declare i64 @symbol_table_add(ptr, ptr)

;; Release the symbol table and its identifier strings.
declare void @symbol_table_destroy(ptr)

;; Initialize a caller-owned token stream.
declare i1 @token_stream_init(ptr)

;; Release the token stream.
declare void @token_stream_destroy(ptr)

define i32 @lexer(ptr %filename, ptr %symbol_table, ptr %token_stream) {
entry:
  %reader_storage = alloca %Reader
  %symbol_table_ok = call i1 @symbol_table_init(ptr %symbol_table)
  %token_stream_ok = call i1 @token_stream_init(ptr %token_stream)
  %tables_ok = and i1 %symbol_table_ok, %token_stream_ok
  br i1 %tables_ok, label %init_reader, label %return_error

init_reader:
  %reader = call ptr @reader_init(ptr %reader_storage, ptr %filename)
  %reader_ok = icmp ne ptr %reader, null
  br i1 %reader_ok, label %scan, label %return_error

scan:
  call void @reader_destroy(ptr %reader_storage)
  ret i32 0

return_error:
  call void @token_stream_destroy(ptr %token_stream)
  call void @symbol_table_destroy(ptr %symbol_table)
  ret i32 1
}
