; ModuleID = 'probe5.357837089612abd9-cgu.0'
source_filename = "probe5.357837089612abd9-cgu.0"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7m-none-unknown-eabi"

@alloc_aaab9a7d4847e7c571a75229c231e4a7 = private unnamed_addr constant <{ [77 x i8] }> <{ [77 x i8] c"/rustc/065a1f5df9c2f1d93269e4d25a2acabbddb0db8d/library/core/src/ops/arith.rs" }>, align 1
@alloc_c55af62477213346878d49d8552abbe7 = private unnamed_addr constant <{ ptr, [12 x i8] }> <{ ptr @alloc_aaab9a7d4847e7c571a75229c231e4a7, [12 x i8] c"M\00\00\00\F8\02\00\00\01\00\00\00" }>, align 4
@str.0 = internal constant [28 x i8] c"attempt to add with overflow"
@alloc_2e38410fced2c310c68bdf2d45d0c3bd = private unnamed_addr constant <{ [4 x i8] }> <{ [4 x i8] c"\02\00\00\00" }>, align 4

; <i32 as core::ops::arith::AddAssign<&i32>>::add_assign
; Function Attrs: inlinehint nounwind
define internal void @"_ZN66_$LT$i32$u20$as$u20$core..ops..arith..AddAssign$LT$$RF$i32$GT$$GT$10add_assign17h7eda3f68a1eba01fE"(ptr align 4 %self, ptr align 4 %other) unnamed_addr #0 {
start:
  %other1 = load i32, ptr %other, align 4, !noundef !0
  %0 = load i32, ptr %self, align 4, !noundef !0
  %1 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %other1)
  %_4.0 = extractvalue { i32, i1 } %1, 0
  %_4.1 = extractvalue { i32, i1 } %1, 1
  %2 = call i1 @llvm.expect.i1(i1 %_4.1, i1 false)
  br i1 %2, label %panic, label %bb1

bb1:                                              ; preds = %start
  store i32 %_4.0, ptr %self, align 4
  ret void

panic:                                            ; preds = %start
; call core::panicking::panic
  call void @_ZN4core9panicking5panic17h59efb9fe4d3979abE(ptr align 1 @str.0, i32 28, ptr align 4 @alloc_c55af62477213346878d49d8552abbe7) #5
  unreachable
}

; probe5::probe
; Function Attrs: nounwind
define dso_local void @_ZN6probe55probe17h90d298d14a21bdc2E() unnamed_addr #1 {
start:
  %x = alloca i32, align 4
  store i32 1, ptr %x, align 4
; call <i32 as core::ops::arith::AddAssign<&i32>>::add_assign
  call void @"_ZN66_$LT$i32$u20$as$u20$core..ops..arith..AddAssign$LT$$RF$i32$GT$$GT$10add_assign17h7eda3f68a1eba01fE"(ptr align 4 %x, ptr align 4 @alloc_2e38410fced2c310c68bdf2d45d0c3bd) #6
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i1 @llvm.expect.i1(i1, i1) #3

; core::panicking::panic
; Function Attrs: cold noinline noreturn nounwind
declare dso_local void @_ZN4core9panicking5panic17h59efb9fe4d3979abE(ptr align 1, i32, ptr align 4) unnamed_addr #4

attributes #0 = { inlinehint nounwind "frame-pointer"="all" "target-cpu"="generic" }
attributes #1 = { nounwind "frame-pointer"="all" "target-cpu"="generic" }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #4 = { cold noinline noreturn nounwind "frame-pointer"="all" "target-cpu"="generic" }
attributes #5 = { noreturn nounwind }
attributes #6 = { nounwind }

!0 = !{}
