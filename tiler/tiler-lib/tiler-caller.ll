; ModuleID = 'tiler-caller.c'
source_filename = "tiler-caller.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.12.0"

%struct.TileGame = type { i8*, i32, i32, i32, i32, i32, %struct.SDL_Surface*, i32, i32 }
%struct.SDL_Surface = type opaque
%struct.GameGrid = type { i32, i32, %struct.SDL_Rect*, %struct.Object** }
%struct.SDL_Rect = type opaque
%struct.Object = type { i32, i32, i32, i32, %struct.SDL_Surface*, i8* }
%struct.Blocks = type { void (...)*, void (...)*, i32 (...)* }
%struct.ObjRefList = type { %struct.ObjNode* }
%struct.ObjNode = type { %struct.Object*, %struct.ObjNode* }
%struct.MouseInfo = type { %struct.Coord, i32 }
%struct.Coord = type { i32, i32 }

@.str = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@str = common global i8* null, align 8
@game = common global %struct.TileGame* null, align 8
@grid = common global %struct.GameGrid* null, align 8
@blocks = common global %struct.Blocks* null, align 8
@obj_refs = common global %struct.ObjRefList zeroinitializer, align 8
@mouseInfo = common global %struct.MouseInfo zeroinitializer, align 4

; Function Attrs: noinline nounwind optnone ssp uwtable
define void @init() #0 {
  call void @createGrid(i32 3, i32 3)
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i32 0, i32 0), i8** @str, align 8
  ret void
}

declare void @createGrid(i32, i32) #1

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main(i32, i8**) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8**, align 8
  store i32 %0, i32* %3, align 4
  store i8** %1, i8*** %4, align 8
  call void (...) @createGame()
  call void @setInit(void (...)* bitcast (void ()* @init to void (...)*))
  call void (...) @runGame()
  ret i32 0
}

declare void @createGame(...) #1

declare void @setInit(void (...)*) #1

declare void @runGame(...) #1

attributes #0 = { noinline nounwind optnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 5.0.0 (tags/RELEASE_500/final)"}
