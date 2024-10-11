package entities.macros.helpers;

#if macro 

import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Type;

@:access(entities.macros.helpers.MetadataWrapper)
class ClassField {
    public var builder:ClassBuilder;
    public var field:Field;

    private var classField:haxe.macro.Type.ClassField;

    private var staticField:Bool = false;

    public function new(builder:ClassBuilder, field:Field = null) {
        this.builder = builder;
        this.field = field;
    }

    public function remove() {
        this.builder.removeField(this.name);
    }

    public var name(get, null):String;
    private function get_name():String {
        if (field != null) {
            return field.name;
        }
        if (classField != null) {
            return classField.name;
        }
        return null;
    }

    public var metadata(get, null):MetadataWrapper;
    private function get_metadata():MetadataWrapper {
        var wrapper = new MetadataWrapper();
        if (field != null) {
            if (field.meta == null) {
                field.meta = [];
            }
            wrapper.metadata = field.meta;
        } else if (classField != null) {
            wrapper.meta = classField.meta;
        }
        return wrapper;
    }

    public var access(get, set):Array<Access>;
    private function get_access():Array<Access> {
        if (field != null) {
            return field.access;
        }
        if (classField != null) {
            var a = [];
            if (classField.isAbstract) {
                a.push(AAbstract);
            }
            if (classField.isExtern) {
                a.push(AExtern);
            }
            if (classField.isFinal) {
                a.push(AExtern);
            }
            if (staticField) {
                a.push(AStatic);
            }
            if (classField.isPublic) {
                a.push(APublic);
            } else {
                a.push(APrivate);
            }
            return a;
        }
        return null;
    }
    private function set_access(value:Array<Access>):Array<Access> {
        if (field == null) {
            throw "must have field var";
        }

        field.access = value;

        return value;
    }

    public var isStatic(get, null):Bool;
    private function get_isStatic():Bool {
        return staticField;
    }

    public var isPrivate(get, set):Bool;
    private function get_isPrivate():Bool {
        return access.contains(APrivate);
    }
    private function set_isPrivate(value:Bool):Bool {
        var a = access;
        if (value) {
            a.remove(APublic);
            if (!a.contains(APrivate)) {
                a.push(APrivate);
            }
        } else {
            a.remove(APrivate);
            if (!a.contains(APublic)) {
                a.push(APublic);
            }
        }
        access = a;
        return value;
    }

    public var isPublic(get, set):Bool;
    private function get_isPublic():Bool {
        return access.contains(APublic);
    }
    private function set_isPublic(value:Bool):Bool {
        var a = access;
        if (value) {
            a.remove(APrivate);
            if (!a.contains(APublic)) {
                a.push(APublic);
            }
        } else {
            a.remove(APublic);
            if (!a.contains(APrivate)) {
                a.push(APrivate);
            }
        }
        access = a;
        return value;
    }

    public var typeName(get, null):String;
    private function get_typeName():String {
        if (field != null) {
            return TypeTools.toString(TypeTools.follow(this.type));
        } 
        if (classField != null) {
            return TypeTools.toString(TypeTools.follow(classField.type));
        }
        return null;
    }

    public var type(get, null):Type;
    private function get_type():Type {
        if (field != null) {
            switch (field.kind) {
                case FVar(t, e):
                    return ComplexTypeTools.toType(t);
                case FProp(get, set, t, e):    
                    return ComplexTypeTools.toType(t);
                case FFun(f):    
                    return ComplexTypeTools.toType(f.ret);
            }
        }
        if (classField != null) {
            return classField.type;
        }

        return null;
    }

    public var followedType(get, null):Type;
    private function get_followedType():Type {
        if (field != null) {
            switch (field.kind) {
                case FVar(t, e):
                    return TypeTools.follow(ComplexTypeTools.toType(t));
                case FProp(get, set, t, e):    
                    return TypeTools.follow(ComplexTypeTools.toType(t));
                case FFun(f):    
                    return TypeTools.follow(ComplexTypeTools.toType(f.ret));
            }
        }
        if (classField != null) {
            return TypeTools.follow(classField.type);
        }

        return null;
    }

    public var complexType(get, set):ComplexType;
    private function get_complexType():ComplexType {
        if (field != null) {
            switch (field.kind) {
                case FVar(t, e):
                    return t;
                case FProp(get, set, t, e):    
                    return t;
                case FFun(f):
                    return f.ret;    
            }
        }
        if (classField != null) {
            TypeTools.toComplexType(classField.type);
        }   
        return null;
    }

    private function set_complexType(value:ComplexType):ComplexType {
        throw "must override";
    }

    public var typePath(get, null):TypePath;
    private function get_typePath():TypePath {
        return switch (complexType) {
			case TPath(p): p;
			case _: null;
		}
    }
}

#end