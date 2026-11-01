target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

declare i32 @lexer_main(i32, ptr)

define i32 @main(i32 %argc, ptr %argv) {
entry:
  %status = call i32 @lexer_main(i32 %argc, ptr %argv)
  ret i32 %status
}
