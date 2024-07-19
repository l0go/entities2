package entities.macros.helpers;

import haxe.macro.Context;
#if macro

import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;

class MetadataWrapper {
    private var meta:MetaAccess;
    private var metadata:Metadata;

    public function new() {
    }

    public function add(name:String, params:Array<Expr> = null) {
        if (params == null) {
            params = [];
        }
        if (!name.startsWith(":")) {
            name = ":" + name;
        }
        if (meta != null) {
            meta.add(name, params, Context.currentPos());
        } else if (metadata != null) {
            metadata.push({
                name: name,
                params: params,
                pos: Context.currentPos()
            });
        }
    }

    public function contains(name:String):Bool {
        for (m in asArray()) {
            if (m.name == name || m.name == ":" + name) {
                return true;
            }
        }
        return false;
    }

    public function count(name:String):Int {
        var n = 0;
        for (m in asArray()) {
            if (m.name == name || m.name == ":" + name) {
                n++;
            }
        }
        return n;
    }

    public function param(name:String, paramIndex:Int = 0):Expr {
        var expr:Expr = null;
        for (m in asArray()) {
            if (m.name == name || m.name == ":" + name) {
                expr = m.params[paramIndex];
            }
        }
        return expr;
    }

    public function paramAsString(name:String, paramIndex:Int = 0, removeQuotes:Bool = true):String {
        var expr:Expr = param(name, paramIndex);
        if (expr == null) {
            return null;
        }
        var s = ExprTools.toString(expr); 
        if (removeQuotes) {
            s = s.replace("'", "");
            s = s.replace("\"", "");
        }
        return s;
    }

    public function paramAsInt(name:String, paramIndex:Int = 0):Null<Int> {
        var v = paramAsString(name, paramIndex, true);
        if (v == null) {
            return null;
        }
        return Std.parseInt(v);
    }

    public function paramAsBool(name:String, paramIndex:Int = 0):Null<Bool> {
        var v = paramAsString(name, paramIndex, true);
        if (v == null) {
            return null;
        }
        return v == "true";
    }

    private function asArray():Metadata {
        if (metadata != null) {
            return metadata;
        }
        if (meta != null) {
            return meta.get();
        }
        return [];
    }
}

#end