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

@read_mode = private constant [3 x i8] c"rb\00"

;;;;; C FUNCTIONS

declare ptr @fopen(ptr, ptr) ;; *filename *mode
declare i64 @fread(ptr, i64, i64, ptr) ;; *buffer size count *file
declare ptr @malloc(i64) ;; size
declare i32 @fclose(ptr)
declare void @free(ptr)
declare i32 @ferror(ptr)

;;;;; MAIN INTERFACE

;; Initialize caller-owned Reader storage. Return reader on success or null on failure.
define ptr @reader_init(ptr %reader, ptr %filename) {
entry:
  %file = call ptr @fopen(ptr %filename, ptr @read_mode)
;; create buffers 0 and 1
  %buffer0 = call ptr @malloc(i64 128)
  %buffer1 = call ptr @malloc(i64 128)
  %file_err = icmp eq ptr %file, null
  %buffer0_err = icmp eq ptr %buffer0, null
  %buffer1_err = icmp eq ptr %buffer1, null
  %buffer_error = or i1 %buffer0_err, %buffer1_err
  %init_error = or i1 %file_err, %buffer_error
  br i1 %init_error, label %clean_error, label %read

read:
  %bytes = call i64 @fread(ptr %buffer0, i64 1, i64 128, ptr %file)
  %status = call i32 @ferror(ptr %file)
  %failed = icmp ne i32 %status, 0
  br i1 %failed, label %clean_error, label %success

success:
  %r0 = insertvalue %Reader zeroinitializer, ptr %file, 0
  %r1 = insertvalue %Reader %r0, ptr %buffer0, 1
  %r2 = insertvalue %Reader %r1, ptr %buffer1, 2
  %r3 = insertvalue %Reader %r2, i64 %bytes, 7
  %exhausted = icmp ult i64 %bytes, 128
  %r4 = insertvalue %Reader %r3, i1 %exhausted, 9
  store %Reader %r4, ptr %reader
  ret ptr %reader

clean_error:
  call void @free(ptr %buffer0)
  call void @free(ptr %buffer1)
  br i1 %file_err, label %return_null, label %close_file

close_file:
  call i32 @fclose(ptr %file)
  br label %return_null

return_null:
  ret ptr null
}

;; Close the file and release the buffers owned by a Reader.
define void @reader_destroy(ptr %reader) {
entry:
  %r = load %Reader, ptr %reader
  %file = extractvalue %Reader %r, 0
  %b0 = extractvalue %Reader %r, 1
  %b1 = extractvalue %Reader %r, 2
  call i32 @fclose(ptr %file)
  call void @free(ptr %b0)
  call void @free(ptr %b1)
  ret void
}

;; Return the next character without consuming it.
define i32 @reader_peek(ptr %reader) {
entry:
  %r = load %Reader, ptr %reader
  %error = extractvalue %Reader %r, 11
  %failed = icmp ne i32 %error, 0
  br i1 %failed, label %return_error, label %check

return_error:
  ret i32 %error

check:
  %active = extractvalue %Reader %r, 3
  %forward = extractvalue %Reader %r, 4
  %b0 = extractvalue %Reader %r, 1
  %b1 = extractvalue %Reader %r, 2
  %valid0 = extractvalue %Reader %r, 7
  %valid1 = extractvalue %Reader %r, 8
  %buffer = select i1 %active, ptr %b1, ptr %b0
  %valid = select i1 %active, i64 %valid1, i64 %valid0
  %available = icmp ult i64 %forward, %valid
  br i1 %available, label %character, label %eof

character:
  %p = getelementptr i8, ptr %buffer, i64 %forward
  %byte = load i8, ptr %p
  %value = zext i8 %byte to i32
  ret i32 %value

eof:
  ret i32 -1
}

;; Move to the next character.
define void @reader_step(ptr %reader) {
entry:
  %r = load %Reader, ptr %reader
  %error = extractvalue %Reader %r, 11
  %active = extractvalue %Reader %r, 3
  %forward = extractvalue %Reader %r, 4
  %valid0 = extractvalue %Reader %r, 7
  %valid1 = extractvalue %Reader %r, 8
  %valid = select i1 %active, i64 %valid1, i64 %valid0
  %ok = icmp eq i32 %error, 0
  %available = icmp ult i64 %forward, %valid
  %can_step = and i1 %ok, %available
  br i1 %can_step, label %advance, label %return

advance:
  %next = add i64 %forward, 1
  %finished = icmp uge i64 %next, %valid
  br i1 %finished, label %boundary, label %store_position

store_position:
  %forward_field = getelementptr %Reader, ptr %reader, i32 0, i32 4
  store i64 %next, ptr %forward_field
  br label %return

boundary:
  %exhausted = extractvalue %Reader %r, 9
  br i1 %exhausted, label %store_position, label %guard

guard:
  %collecting = extractvalue %Reader %r, 10
  %begin_buffer = extractvalue %Reader %r, 5
  %other = xor i1 %active, true
  %overwrites_begin = icmp eq i1 %other, %begin_buffer
  %blocked = and i1 %collecting, %overwrites_begin
  br i1 %blocked, label %too_long, label %refill

too_long:
  %error_field = getelementptr %Reader, ptr %reader, i32 0, i32 11
  store i32 -2, ptr %error_field
  br label %return

refill:
  %file = extractvalue %Reader %r, 0
  %b0 = extractvalue %Reader %r, 1
  %b1 = extractvalue %Reader %r, 2
  %target = select i1 %other, ptr %b1, ptr %b0
  %bytes = call i64 @fread(ptr %target, i64 1, i64 128, ptr %file)
  %status = call i32 @ferror(ptr %file)
  %read_failed = icmp ne i32 %status, 0
  br i1 %read_failed, label %io_error, label %switch

io_error:
  %io_error_field = getelementptr %Reader, ptr %reader, i32 0, i32 11
  store i32 -3, ptr %io_error_field
  br label %return

switch:
  %valid0_field = getelementptr %Reader, ptr %reader, i32 0, i32 7
  %valid1_field = getelementptr %Reader, ptr %reader, i32 0, i32 8
  %target_valid = select i1 %other, ptr %valid1_field, ptr %valid0_field
  %active_field = getelementptr %Reader, ptr %reader, i32 0, i32 3
  %switch_forward_field = getelementptr %Reader, ptr %reader, i32 0, i32 4
  %eof_field = getelementptr %Reader, ptr %reader, i32 0, i32 9
  store i64 %bytes, ptr %target_valid
  store i1 %other, ptr %active_field
  store i64 0, ptr %switch_forward_field
  %now_exhausted = icmp ult i64 %bytes, 128
  store i1 %now_exhausted, ptr %eof_field
  br label %return

return:
  ret void
}

;; Mark the current position as the beginning of a new lexeme.
define void @reader_begin(ptr %reader) {
entry:
  %r = load %Reader, ptr %reader
  %active = extractvalue %Reader %r, 3
  %forward = extractvalue %Reader %r, 4
  %begin_buffer_field = getelementptr %Reader, ptr %reader, i32 0, i32 5
  %begin_position_field = getelementptr %Reader, ptr %reader, i32 0, i32 6
  %collecting_field = getelementptr %Reader, ptr %reader, i32 0, i32 10
  store i1 %active, ptr %begin_buffer_field
  store i64 %forward, ptr %begin_position_field
  store i1 true, ptr %collecting_field
  ret void
}

define i1 @reader_lexeme(ptr %reader, ptr %output) {
entry:
  store %Lexeme zeroinitializer, ptr %output
  %r = load %Reader, ptr %reader
  %collecting = extractvalue %Reader %r, 10
  %error = extractvalue %Reader %r, 11
  %ok = icmp eq i32 %error, 0
  %ready = and i1 %collecting, %ok
  %collecting_field = getelementptr %Reader, ptr %reader, i32 0, i32 10
  store i1 false, ptr %collecting_field
  br i1 %ready, label %extract, label %failure

extract:
  %b0 = extractvalue %Reader %r, 1
  %b1 = extractvalue %Reader %r, 2
  %active = extractvalue %Reader %r, 3
  %forward = extractvalue %Reader %r, 4
  %begin_buffer = extractvalue %Reader %r, 5
  %begin = extractvalue %Reader %r, 6
  %valid0 = extractvalue %Reader %r, 7
  %valid1 = extractvalue %Reader %r, 8
  %start_buffer = select i1 %begin_buffer, ptr %b1, ptr %b0
  %start_valid = select i1 %begin_buffer, i64 %valid1, i64 %valid0
  %end_buffer = select i1 %active, ptr %b1, ptr %b0
  %same = icmp eq i1 %active, %begin_buffer
  %first_end = select i1 %same, i64 %forward, i64 %start_valid
  %first_length = sub i64 %first_end, %begin
  %first_ptr = getelementptr i8, ptr %start_buffer, i64 %begin
  %second_ptr = select i1 %same, ptr null, ptr %end_buffer
  %second_length = select i1 %same, i64 0, i64 %forward
  %l0 = insertvalue %Lexeme zeroinitializer, ptr %first_ptr, 0
  %l1 = insertvalue %Lexeme %l0, i64 %first_length, 1
  %l2 = insertvalue %Lexeme %l1, ptr %second_ptr, 2
  %l3 = insertvalue %Lexeme %l2, i64 %second_length, 3
  store %Lexeme %l3, ptr %output
  ret i1 true

failure:
  ret i1 false
}
