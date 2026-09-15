define i32 @pow(i32 %x, i32 %p) {
start:
  br label %loop_start

loop_start:
  %i = phi i32 [0, %start], [%i.new, %loop]
  %r = phi i32 [1, %start], [%r.new, %loop]
  %check = icmp eq i32 %i, %p
  br i1 %check, label %exit, label %loop

loop:
  %r.new = mul i32 %r, %x
  %i.new = add i32 1, %i
  br label %loop_start

exit:
  ret i32 %r
}

define i32 @main() {
%res = call i32 @pow(i32 3, i32 2)
ret i32 %res
}

