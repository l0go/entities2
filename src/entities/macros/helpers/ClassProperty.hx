package entities.macros.helpers;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

class ClassProperty extends entities.macros.helpers.ClassField {
    public var getter(get, null):ClassFunction;
    private function get_getter():ClassFunction {
        return builder.findPropGetter(this.name);
    }

    public var setter(get, null):ClassFunction;
    private function get_setter():ClassFunction {
        return builder.findPropSetter(this.name);
    }

    public function addGetter(expr:Expr = null, access:Array<Access> = null):ClassFunction {
        if (access == null) {
            access = [APrivate];
        }
        switch (field.kind) {
            case FProp(get, set, t, e):
                field.kind = FProp("get", set, t, e);
            case _:
                throw "wrong field kind";
        }
        return builder.addFunction("get_" + this.name, null, expr, this.complexType, access);
    }

    public function addSetter(expr:Expr = null, access:Array<Access> = null):ClassFunction {
        if (access == null) {
            access = [APrivate];
        }
        switch (field.kind) {
            case FProp(get, set, t, e):
                field.kind = FProp(get, "set", t, e);
            case _:
                throw "wrong field kind";
        }
        return builder.addFunction("set_" + this.name, [{name: "value", type: this.complexType}], expr, this.complexType, access);
    }
}

#end