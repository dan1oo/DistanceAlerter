; ModuleID = 'probe6.266e0db9336425f8-cgu.0'
source_filename = "probe6.266e0db9336425f8-cgu.0"
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7m-none-unknown-eabi"

@alloc_266adf3fc7d5a472b29a287658d10ee8 = private unnamed_addr constant <{ [75 x i8] }> <{ [75 x i8] c"/rustc/065a1f5df9c2f1d93269e4d25a2acabbddb0db8d/library/core/src/num/mod.rs" }>, align 1
@alloc_6daabd09330a876e441b3d48434160c4 = private unnamed_addr constant <{ ptr, [12 x i8] }> <{ ptr @alloc_266adf3fc7d5a472b29a287658d10ee8, [12 x i8] c"K\00\00\00w\04\00\00\05\00\00\00" }>, align 4
@str.0 = internal constant [25 x i8] c"attempt to divide by zero"

; probe6::probe
; Function Attrs: nounwind
define dso_local void @_ZN6probe65probe17hfbcb43355ab1c1bfE() unnamed_addr #0 {
start:
  %0 = call i1 @llvm.expect.i1(i1 false, i1 false)
  br i1 %0, label %panic.i, label %"_ZN4core3num21_$LT$impl$u20$u32$GT$10div_euclid17h51cacf8726911283E.exit"

panic.i:                                          ; preds = %start
; call core::panicking::panic
  call void @_ZN4core9panicking5panic17h59efb9fe4d3979abE(ptr align 1 @str.0, i32 25, ptr align 4 @alloc_6daabd09330a876e441b3d48434160c4) #3
  unreachable

"_ZN4core3num21_$LT$impl$u20$u32$GT$10div_euclid17h51cacf8726911283E.exit": ; preds = %start
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i1 @llvm.expect.i1(i1, i1) #1

; core::panicking::panic
; Function Attrs: cold noinline noreturn nounwind
declare dso_local void @_ZN4core9panicking5panic17h59efb9fe4d3979abE(ptr align 1, i32, ptr align 4) unnamed_addr #2

attributes #0 = { nounwind "frame-pointer"="all" "target-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #2 = { cold noinline noreturn nounwind "frame-pointer"="all" "target-cpu"="generic" }
attributes #3 = { noreturn nounwind }
