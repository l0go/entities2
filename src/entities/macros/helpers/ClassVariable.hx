package entities.macros.helpers;

#if macro 

import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type;

using entities.macros.helpers.MacroTypeTools;

class ClassVariable extends entities.macros.helpers.ClassField {
    private override function set_complexType(value:ComplexType):ComplexType {
        if (field == null) {
            throw "must have field var";
        }

        switch (field.kind) {
            case FVar(t, e):
                field.kind = FVar(value, e);
            case _:    
                throw "not class variable";
        }

        return value;
    }

    public var expr(get, set):Expr;
    private function get_expr():Expr {
        if (field == null) {
            throw "must have field var";
        }

        return switch (field.kind) {
            case FVar(t, e):
                e;
            case _:    
                throw "not class variable";
    
        }
    }
    private function set_expr(value:Expr):Expr {
        if (field == null) {
            throw "must have field var";
        }

        switch (field.kind) {
            case FVar(t, e):
                field.kind = FVar(t, value);
            case _:    
                throw "not class variable";
        }

        return value;
    }

    public function hasInterface(requestedInterface:String, lookInSuperClasses:Bool = true):Bool {
        return type.hasInterface(requestedInterface, lookInSuperClasses);
    }
}

#end