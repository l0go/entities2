package entities.macros.helpers;

#if macro

import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type;

class ClassFunction extends entities.macros.helpers.ClassField {
    public var expr(get, set):Expr;
    private function get_expr():Expr {
        if (field == null) {
            throw "must have field var";
        }

        return switch (field.kind) {
            case FFun(f):
                f.expr;
            case _:    
                throw "not class variable";
    
        }
    }
    private function set_expr(value:Expr):Expr {
        if (field == null) {
            throw "must have field var";
        }

        switch (field.kind) {
            case FFun(f):
                field.kind = FFun({
                    args: f.args,
                    ret: f.ret,
                    expr: value,
                    params: f.params
                });
            case _:    
                throw "not class variable";
        }

        return value;
    }

    public var args(get, never):Array<FunctionArg>;
    private function get_args():Array<FunctionArg> {
        if (field == null) {
            throw "must have field var";
        }

        return switch (field.kind) {
            case FFun(f):
                f.args;
            case _:    
                throw "not class variable";
    
        }
    }

    public var code(get, set):CodeBuilderWrapper;
    private function get_code():CodeBuilderWrapper {
        if (this.expr == null) {
            this.expr = macro {}
        }
        var codeBuilder = new CodeBuilderWrapper(this.expr);
        return codeBuilder;
    }
    private function set_code(value:CodeBuilderWrapper):CodeBuilderWrapper {
        this.expr = value.expr;
        return value;
    }
    
}

#end