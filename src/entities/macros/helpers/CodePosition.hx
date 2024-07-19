package entities.macros.helpers;

enum CodePosition {
    Start;
    End;
    AfterSuper;
    Pos(pos:Int);
}