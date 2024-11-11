package entities.macros.helpers;

#if macro

import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type;
import entities.macros.helpers.CodePosition;

class CodeBuilder {
    public var expr:Expr;
    public function new(expr:Expr = null) {
        this.expr = expr;
    }

    private function findSuper(exprs:Array<Expr>):Null<Int> {
        var result:Null<Int> = null;
        for (pos in 0...exprs.length) {
            var expr = exprs[pos];
            trace(expr);
            switch (expr.expr) {
                case ECall({expr: EConst(CIdent("super")), pos:_}, params):
                    result = pos;
                    break;
                case ECall({pos: _, expr: EField({pos: _, expr: EConst(CIdent("super"))},_,_)},[]):    
                    result = pos;
                    break;
                case EVars([{isStatic: _, name: _, isFinal: _, meta: _, type: _, expr: {pos: _, expr: ECall({pos: _, expr: EField({pos: _, expr: EConst(CIdent("super"))},_,_)},[])}}]):    
                    result = pos;
                    break;
                default:
            }
        }
        return result;
    }

    public function addToStart(e:Expr = null, cb:CodeBuilder = null) {
        add(e, cb, Start);
    }

    public function addAfterSuper(e:Expr = null, cb:CodeBuilder = null) {
        add(e, cb, AfterSuper);
    }

    public function add(e:Expr = null, cb:CodeBuilder = null, where:CodePosition = null) {
        if (expr == null) {
            expr = macro {
            }
        }

        if (where == null) {
            where = End;
        }
        if (e == null && cb == null) {
            throw "Nothing specified";
        }
        if (e == null) {
            e = cb.expr;
        }

        switch (expr.expr) {
            case EBlock(el):
                switch (where) {
                    case Start:
                        el.insert(0, e);
                    case End:
                        if (isLastLineReturn() == true) {
                            el.insert(el.length - 1, e);
                        } else {
                            el.push(e);
                        }
                    case AfterSuper:
                        var superPos = findSuper(el);
                        if (superPos == null) {
                            throw 'super call not found in method at ${e.pos}';
                        } else {
                            el.insert(superPos + 1, e);
                        }
                    case Pos(pos):
                        el.insert(pos, e);
                }
            case _:
                throw "NOT IMPL! - " + expr;
                return;
        }
    }

    private function isLastLineReturn():Bool {
        var r = false;

        switch (expr.expr) {
            case EBlock(el):
                var l = el[el.length - 1];
                if (l != null) {
                    switch (l.expr) {
                        case EReturn(_):
                            r = true;
                        case _:
                    }
                }
            case _:
                trace("NOT IMPL!");
        }

        return r;
    }

    public function toString() {
        if (expr == null) {
            return null;
        }
        return ExprTools.toString(expr);
    }
}

#end