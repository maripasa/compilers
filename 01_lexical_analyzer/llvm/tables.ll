%Symbol = type {
    ptr,      ; 0 identifier
    i64       ; 1 occurrence count
}

%SymbolTable = type {
    ptr,      ; 0 symbols
    i64,      ; 1 length
    i64       ; 2 capacity
}

%Token = type {
    i32,      ; 0 token type
    ptr,      ; 1 lexeme
    i64       ; 2 attribute
}

%TokenStream = type {
    ptr,      ; 0 tokens
    i64,      ; 1 length
    i64       ; 2 capacity
}

declare ptr @malloc(i64)
declare ptr @realloc(ptr, i64)
declare void @free(ptr)
declare i64 @strlen(ptr)
declare ptr @memcpy(ptr, ptr, i64)
declare i32 @strcmp(ptr, ptr)

define i1 @symbol_table_init(ptr %table) {
entry:
  store %SymbolTable zeroinitializer, ptr %table
  %symbols = call ptr @malloc(i64 256)
  %failed = icmp eq ptr %symbols, null
  br i1 %failed, label %return_false, label %success

success:
  %symbols_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 0
  %capacity_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 2
  store ptr %symbols, ptr %symbols_field
  store i64 16, ptr %capacity_field
  ret i1 true

return_false:
  ret i1 false
}

define i64 @symbol_table_add(ptr %table, ptr %identifier) {
entry:
  %symbols_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 0
  %length_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 1
  %capacity_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 2
  %symbols = load ptr, ptr %symbols_field
  %length = load i64, ptr %length_field
  %capacity = load i64, ptr %capacity_field
  br label %search

search:
  %index = phi i64 [ 0, %entry ], [ %next_index, %next ]
  %has_symbol = icmp ult i64 %index, %length
  br i1 %has_symbol, label %compare, label %not_found

compare:
  %symbol = getelementptr %Symbol, ptr %symbols, i64 %index
  %name_field = getelementptr %Symbol, ptr %symbol, i32 0, i32 0
  %name = load ptr, ptr %name_field
  %comparison = call i32 @strcmp(ptr %name, ptr %identifier)
  %equal = icmp eq i32 %comparison, 0
  br i1 %equal, label %found, label %next

next:
  %next_index = add i64 %index, 1
  br label %search

found:
  %count_field = getelementptr %Symbol, ptr %symbol, i32 0, i32 1
  %count = load i64, ptr %count_field
  %new_count = add i64 %count, 1
  store i64 %new_count, ptr %count_field
  ret i64 %index

not_found:
  %full = icmp eq i64 %length, %capacity
  br i1 %full, label %grow, label %copy

grow:
  %new_capacity = mul i64 %capacity, 2
  %new_size = mul i64 %new_capacity, 16
  %new_symbols = call ptr @realloc(ptr %symbols, i64 %new_size)
  %growth_failed = icmp eq ptr %new_symbols, null
  br i1 %growth_failed, label %return_error, label %grown

grown:
  store ptr %new_symbols, ptr %symbols_field
  store i64 %new_capacity, ptr %capacity_field
  br label %copy

copy:
  %current_symbols = phi ptr [ %symbols, %not_found ], [ %new_symbols, %grown ]
  %name_length = call i64 @strlen(ptr %identifier)
  %copy_size = add i64 %name_length, 1
  %name_copy = call ptr @malloc(i64 %copy_size)
  %copy_failed = icmp eq ptr %name_copy, null
  br i1 %copy_failed, label %return_error, label %insert

insert:
  call ptr @memcpy(ptr %name_copy, ptr %identifier, i64 %copy_size)
  %new_symbol = getelementptr %Symbol, ptr %current_symbols, i64 %length
  %new_name_field = getelementptr %Symbol, ptr %new_symbol, i32 0, i32 0
  %new_count_field = getelementptr %Symbol, ptr %new_symbol, i32 0, i32 1
  store ptr %name_copy, ptr %new_name_field
  store i64 1, ptr %new_count_field
  %new_length = add i64 %length, 1
  store i64 %new_length, ptr %length_field
  ret i64 %length

return_error:
  ret i64 -1
}

define void @symbol_table_destroy(ptr %table) {
entry:
  %symbols_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 0
  %length_field = getelementptr %SymbolTable, ptr %table, i32 0, i32 1
  %symbols = load ptr, ptr %symbols_field
  %length = load i64, ptr %length_field
  br label %loop

loop:
  %index = phi i64 [ 0, %entry ], [ %next_index, %free_name ]
  %has_symbol = icmp ult i64 %index, %length
  br i1 %has_symbol, label %free_name, label %finish

free_name:
  %symbol = getelementptr %Symbol, ptr %symbols, i64 %index
  %name_field = getelementptr %Symbol, ptr %symbol, i32 0, i32 0
  %name = load ptr, ptr %name_field
  call void @free(ptr %name)
  %next_index = add i64 %index, 1
  br label %loop

finish:
  call void @free(ptr %symbols)
  store %SymbolTable zeroinitializer, ptr %table
  ret void
}

define i1 @token_stream_init(ptr %stream) {
entry:
  store %TokenStream zeroinitializer, ptr %stream
  %tokens = call ptr @malloc(i64 384)
  %failed = icmp eq ptr %tokens, null
  br i1 %failed, label %return_false, label %success

success:
  %tokens_field = getelementptr %TokenStream, ptr %stream, i32 0, i32 0
  %capacity_field = getelementptr %TokenStream, ptr %stream, i32 0, i32 2
  store ptr %tokens, ptr %tokens_field
  store i64 16, ptr %capacity_field
  ret i1 true

return_false:
  ret i1 false
}

define void @token_stream_destroy(ptr %stream) {
entry:
  %tokens_field = getelementptr %TokenStream, ptr %stream, i32 0, i32 0
  %tokens = load ptr, ptr %tokens_field
  call void @free(ptr %tokens)
  store %TokenStream zeroinitializer, ptr %stream
  ret void
}
