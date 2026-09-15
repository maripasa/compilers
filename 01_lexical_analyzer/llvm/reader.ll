%Reader = type {
    ptr,      ; 0 FILE*
    ptr,      ; 1 buffer 0
    ptr,      ; 2 buffer 1
    i1,       ; 3 active buffer: false = 0, true = 1
    i64,      ; 4 forward position
    i1,       ; 5 begin buffer: false = 0, true = 1
    i64,      ; 6 begin position
    i64,      ; 7 valid unread chunk in buffer 0 (0 when consumed)
    i64,      ; 8 valid unread chunk in buffer 1 (0 when consumed)
    i1,       ; 9 file exhausted; buffered bytes may remain
    ptr,      ; 10 current lexeme buffer
    i64,      ; 11 current lexeme length
    i64,      ; 12 current lexeme capacity
    i1        ; 13 currently collecting a lexeme
}

;;;;; C FUNCTIONS

declare ptr @fopen(ptr, ptr) ;; *filename *mode
declare i64 @fread(ptr, i64, i64, ptr) ;; *buffer size count *file
declare ptr @malloc(i64) ;; size
declare ptr @realloc(ptr, i64) ;; pointer, new size
declare i32 @fclose(ptr)
declare void @free(ptr)
declare i32 @ferror(ptr)

@read_mode = private constant [2 x i8] c"r\00"

;;;;; MAIN INTERFACE

;; Initialize caller-owned Reader storage. Return reader on success or null on failure.
define ptr @reader_init(ptr %reader, ptr %filename) {
;; create buffers 0 and 1
entry:
  %file = call ptr @fopen(ptr %filename, ptr @read_mode)
  %buffer0 = call ptr @malloc(i64 16)
  %buffer1 = call ptr @malloc(i64 16)
  %lexeme = call ptr @malloc(i64 32)

  %file_err = icmp eq ptr %file, null
  %buffer0_err = icmp eq ptr %buffer0, null
  %buffer1_err = icmp eq ptr %buffer1, null
  %lexeme_err = icmp eq ptr %lexeme, null

  %buffer_error = or i1 %buffer0_err, %buffer1_err
  %allocation_error = or i1 %buffer_error, %lexeme_err
  %init_error = or i1 %file_err, %allocation_error
  br i1 %init_error, label %clean_error, label %init_success

clean_error:
  call void @free(ptr %buffer0)
  call void @free(ptr %buffer1)
  call void @free(ptr %lexeme)
  br i1 %file_err, label %return_null, label %close_file

close_file:
  call i32 @fclose(ptr %file)
  br label %return_null

return_null:
  ret ptr null

init_success:
;; read file to the buffers
  %bytes0 = call i64 @fread(ptr %buffer0, i64 1, i64 16, ptr %file)
  %b0_error = call i32 @ferror(ptr %file)

  %bytes1 = call i64 @fread(ptr %buffer1, i64 1, i64 16, ptr %file)
  %b1_error = call i32 @ferror(ptr %file)

  %b0_failed = icmp ne i32 %b0_error, 0
  %b1_failed = icmp ne i32 %b1_error, 0
  %read_error = or i1 %b0_failed, %b1_failed
  br i1 %read_error, label %clean_error, label %read_success

read_success:
  %r.reader = insertvalue %Reader zeroinitializer, ptr %file, 0
  %r.buffer0 = insertvalue %Reader %r.reader, ptr %buffer0, 1
  %r.buffer1 = insertvalue %Reader %r.buffer0, ptr %buffer1, 2
  %r.bytes0 = insertvalue %Reader %r.buffer1, i64 %bytes0, 7
  %r.bytes1 = insertvalue %Reader %r.bytes0, i64 %bytes1, 8

  %eof.buffer0 = icmp ult i64 %bytes0, 16
  %eof.buffer1 = icmp ult i64 %bytes1, 16
  %eof = or i1 %eof.buffer0, %eof.buffer1

  %r.eof = insertvalue %Reader %r.bytes1, i1 %eof, 9
  %r.lexeme = insertvalue %Reader %r.eof, ptr %lexeme, 10
  %r.capacity = insertvalue %Reader %r.lexeme, i64 32, 12

  store %Reader %r.capacity, ptr %reader
  
  ret ptr %reader
}

;; Close the file and release the buffers owned by a Reader.
define void @reader_destroy(ptr %reader) {
entry:
  %reader_value = load %Reader, ptr %reader
  %file = extractvalue %Reader %reader_value, 0
  %buffer0 = extractvalue %Reader %reader_value, 1
  %buffer1 = extractvalue %Reader %reader_value, 2
  %lexeme = extractvalue %Reader %reader_value, 10

  call i32 @fclose(ptr %file)
  call void @free(ptr %buffer0)
  call void @free(ptr %buffer1)
  call void @free(ptr %lexeme)

  ret void
}
  
;; Return the next character without consuming it.
define i32 @reader_peek(ptr %reader) {
entry:
  %reader_value = load %Reader, ptr %reader
  %active = extractvalue %Reader %reader_value, 3
  %forward = extractvalue %Reader %reader_value, 4
  %buffer0 = extractvalue %Reader %reader_value, 1
  %buffer1 = extractvalue %Reader %reader_value, 2
  %valid0 = extractvalue %Reader %reader_value, 7
  %valid1 = extractvalue %Reader %reader_value, 8

  %buffer = select i1 %active, ptr %buffer1, ptr %buffer0
  %buffer_valid = select i1 %active, i64 %valid1, i64 %valid0
  %iseof = icmp uge i64 %forward, %buffer_valid
  br i1 %iseof, label %eof, label %success

eof:
  ret i32 -1

success:
  %char_ptr = getelementptr i8, ptr %buffer, i64 %forward
  %char_byte = load i8, ptr %char_ptr
  %peek = zext i8 %char_byte to i32
  ret i32 %peek
}

;; Append one consumed byte, growing the reusable lexeme buffer when necessary.
define internal void @reader_append_character(ptr %reader, i8 %character) {
entry:
  %lexeme_field = getelementptr %Reader, ptr %reader, i32 0, i32 10
  %length_field = getelementptr %Reader, ptr %reader, i32 0, i32 11
  %capacity_field = getelementptr %Reader, ptr %reader, i32 0, i32 12
  %lexeme = load ptr, ptr %lexeme_field
  %length = load i64, ptr %length_field
  %capacity = load i64, ptr %capacity_field
  %already_failed = icmp eq i64 %length, -1
  br i1 %already_failed, label %return, label %check_capacity

check_capacity:
  %needed = add i64 %length, 1
  %has_room = icmp ult i64 %needed, %capacity
  br i1 %has_room, label %append, label %grow

grow:
  %new_capacity = mul i64 %capacity, 2
  %new_lexeme = call ptr @realloc(ptr %lexeme, i64 %new_capacity)
  %growth_failed = icmp eq ptr %new_lexeme, null
  br i1 %growth_failed, label %mark_failure, label %store_growth

mark_failure:
  store i64 -1, ptr %length_field
  br label %return

store_growth:
  store ptr %new_lexeme, ptr %lexeme_field
  store i64 %new_capacity, ptr %capacity_field
  br label %append

append:
  %target = phi ptr [ %lexeme, %check_capacity ], [ %new_lexeme, %store_growth ]
  %character_ptr = getelementptr i8, ptr %target, i64 %length
  store i8 %character, ptr %character_ptr
  %new_length = add i64 %length, 1
  store i64 %new_length, ptr %length_field
  br label %return

return:
  ret void
}

;; Switch to the other buffer and refill it if its previous chunk was consumed.
define internal void @reader_switch_buffer(ptr %reader) {
entry:
  %reader_value = load %Reader, ptr %reader
  %file = extractvalue %Reader %reader_value, 0
  %buffer0 = extractvalue %Reader %reader_value, 1
  %buffer1 = extractvalue %Reader %reader_value, 2
  %active = extractvalue %Reader %reader_value, 3
  %valid0 = extractvalue %Reader %reader_value, 7
  %valid1 = extractvalue %Reader %reader_value, 8
  %file_exhausted = extractvalue %Reader %reader_value, 9

  %valid0_field = getelementptr %Reader, ptr %reader, i32 0, i32 7
  %valid1_field = getelementptr %Reader, ptr %reader, i32 0, i32 8
  %current_valid_field = select i1 %active, ptr %valid1_field, ptr %valid0_field
  %other_valid_field = select i1 %active, ptr %valid0_field, ptr %valid1_field
  %other_valid = select i1 %active, i64 %valid0, i64 %valid1
  %other_buffer = select i1 %active, ptr %buffer0, ptr %buffer1
  store i64 0, ptr %current_valid_field

  %other_active = xor i1 %active, true
  %active_field = getelementptr %Reader, ptr %reader, i32 0, i32 3
  %forward_field_after_switch = getelementptr %Reader, ptr %reader, i32 0, i32 4
  store i1 %other_active, ptr %active_field
  store i64 0, ptr %forward_field_after_switch

  %other_empty = icmp eq i64 %other_valid, 0
  %can_refill = xor i1 %file_exhausted, true
  %needs_refill = and i1 %other_empty, %can_refill
  br i1 %needs_refill, label %refill_buffer, label %return

refill_buffer:
  %bytes = call i64 @fread(ptr %other_buffer, i64 1, i64 16, ptr %file)
  %read_status = call i32 @ferror(ptr %file)
  %read_failed = icmp ne i32 %read_status, 0
  %valid_bytes = select i1 %read_failed, i64 0, i64 %bytes
  store i64 %valid_bytes, ptr %other_valid_field

  %now_exhausted = icmp ult i64 %valid_bytes, 16
  %eof_field = getelementptr %Reader, ptr %reader, i32 0, i32 9
  store i1 %now_exhausted, ptr %eof_field
  br label %return

return:
  ret void
}

;; Advance after a successful peek. The character must be the value peek returned.
define void @reader_step(ptr %reader, i32 %character) {
entry:
  %at_eof = icmp eq i32 %character, -1
  br i1 %at_eof, label %return, label %advance

advance:
  %reader_value = load %Reader, ptr %reader
  %collecting = extractvalue %Reader %reader_value, 13
  %active = extractvalue %Reader %reader_value, 3
  %forward = extractvalue %Reader %reader_value, 4
  %valid0 = extractvalue %Reader %reader_value, 7
  %valid1 = extractvalue %Reader %reader_value, 8
  br i1 %collecting, label %append_character, label %advance_position

append_character:
  %character_byte = trunc i32 %character to i8
  call void @reader_append_character(ptr %reader, i8 %character_byte)
  br label %advance_position

advance_position:
  %valid = select i1 %active, i64 %valid1, i64 %valid0
  %next_forward = add i64 %forward, 1
  %finished_buffer = icmp uge i64 %next_forward, %valid
  br i1 %finished_buffer, label %switch_buffer, label %store_position

store_position:
  %forward_field = getelementptr %Reader, ptr %reader, i32 0, i32 4
  store i64 %next_forward, ptr %forward_field
  br label %return

switch_buffer:
  call void @reader_switch_buffer(ptr %reader)
  br label %return

return:
  ret void
}

;; Mark the current position as the beginning of a new lexeme.
define void @reader_begin(ptr %reader) {
entry:
  %reader_value = load %Reader, ptr %reader
  %active = extractvalue %Reader %reader_value, 3
  %forward = extractvalue %Reader %reader_value, 4
  %begin_buffer_field = getelementptr %Reader, ptr %reader, i32 0, i32 5
  %begin_position_field = getelementptr %Reader, ptr %reader, i32 0, i32 6
  %length_field = getelementptr %Reader, ptr %reader, i32 0, i32 11
  %collecting_field = getelementptr %Reader, ptr %reader, i32 0, i32 13
  store i1 %active, ptr %begin_buffer_field
  store i64 %forward, ptr %begin_position_field
  store i64 0, ptr %length_field
  store i1 true, ptr %collecting_field
  ret void
}

;; End collection and return a null-terminated lexeme, or null after allocation failure.
define ptr @reader_lexeme(ptr %reader) {
entry:
  %lexeme_field = getelementptr %Reader, ptr %reader, i32 0, i32 10
  %length_field = getelementptr %Reader, ptr %reader, i32 0, i32 11
  %collecting_field = getelementptr %Reader, ptr %reader, i32 0, i32 13
  %lexeme = load ptr, ptr %lexeme_field
  %length = load i64, ptr %length_field
  store i1 false, ptr %collecting_field
  %failed = icmp eq i64 %length, -1
  br i1 %failed, label %return_null, label %terminate

terminate:
  %terminator = getelementptr i8, ptr %lexeme, i64 %length
  store i8 0, ptr %terminator
  ret ptr %lexeme

return_null:
  ret ptr null
}
