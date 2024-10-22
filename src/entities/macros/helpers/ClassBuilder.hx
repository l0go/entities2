package entities.macros.helpers;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

using StringTools;
using entities.macros.helpers.MacroTypeTools;
using haxe.macro.TypeTools;

@:access(entities.macros.helpers.ClassField)
@:access(entities.macros.helpers.MetadataWrapper)
class ClassBuilder {
    public var fields:Array<Field> = null;
    public var type:Type = null;

    private var classType:ClassType = null;
    private var classFields:Array<ClassField> = null;
    private var staticClassFields:Array<ClassField> = null;

    public function new(fields:Array<Field> = null, type:Type = null) {
        this.fields = fields;
        this.type = type;
        if (type != null) {
            switch (type) {
                case TInst(t, params):
                    classType = t.get();
                    classFields = classType.fields.get();
                    staticClassFields = classType.statics.get();
                case _:   
            }
        }
    }

    public var isExtern(get, null):Bool;
    private function get_isExtern():Bool {
        if (type != null) {
            return switch (type) {
                case TInst(t, params):
                    t.get().isExtern;
                case _:
                    false;    
            }
        } else if (classType != null) {
            return classType.isExtern;
        }
        return false;
    }

    public var name(get, null):String;
    private function get_name():String {
        if (type != null) {
            return TypeTools.toString(type).split(".").pop();
        } else if (classType != null) {
            return classType.name;
        }

        return null;
    }

    public var qualifiedName(get, null):String;
    private function get_qualifiedName():String {
        if (type != null) {
            return TypeTools.toString(type);
        } else if (classType != null) {
            var qname = classType.name;
            if (classType.pack != null && classType.pack.length > 0) {
                qname = classType.pack.join(".") + "." + qname;
            }
            return qname;
        }

        return null;
    }

    public var qualifiedNameAsArray(get, null):Array<String>;
    private function get_qualifiedNameAsArray():Array<String> {
        return qualifiedName.split(".");
    }

    public var metadata(get, null):MetadataWrapper;
    private function get_metadata():MetadataWrapper {
        var wrapper = new MetadataWrapper();
        if (type != null) {
            switch (type) {
                case TInst(t, params):
                    wrapper.meta = t.get().meta;
                case _:    
            }
        }
        if (classType != null) {
            wrapper.meta = classType.meta;
        }
        return wrapper;
    }

    public function toComplexType():ComplexType {
        if (type == null) {
            return null;
        }

        return TypeTools.toComplexType(type);
    }

    public function toTypePath():TypePath {
        return switch (toComplexType()) {
			case TPath(p): p;
			case _: null;
		}
    }

    public var superClass(get, null):ClassBuilder;
    private function get_superClass():ClassBuilder {
        if (type != null) {
            switch (type) {
                case TInst(classTypeRef, params):
                    var classType = classTypeRef.get();
                    var superClassTypeRef = classType.superClass;
                    if (superClassTypeRef != null) {
                        return classTypeToClassBuilder(superClassTypeRef.t.get());
                    }
                case _:    
            }
        } else if (classType != null) {
            var superClassTypeRef = classType.superClass;
            if (superClassTypeRef != null) {
                return classTypeToClassBuilder(superClassTypeRef.t.get());
            }
        }
        return null;
    }

    public function hasInterface(requestedInterface:String, lookInSuperClasses:Bool = true):Bool {
        return type.hasInterface(requestedInterface, lookInSuperClasses);
    }

    public function removeField(name:String) {
        if (fields == null) {
            throw "can only add fields when class builder has field array";
        }

        for (f in fields) {
            if (f.name == name) {
                fields.remove(f);
                break;
            }
        }
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // VARS
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public var vars(get, null):Array<ClassVariable>;
    private function get_vars():Array<ClassVariable> {
        var list = [];
        if (fields != null) {
            for (f in fields) {
                switch (f.kind) {
                    case FVar(t, e):
                        var classVariable = new ClassVariable(this);
                        classVariable.field = f;
                        classVariable.staticField = f.access.contains(AStatic);
                        list.push(classVariable);
                    case _:    
                }
            }
        } else if (classFields != null) {
            for (f in classFields) {
                switch (f.kind) {
                    case FVar(read, write):
                        var classVariable = new ClassVariable(this);
                        classVariable.classField = f;
                        list.push(classVariable);
                    case _:    
                }
            }
        }
        return list;
    }

    public function removeVar(name:String) {
        // TODO: might want to check if the field exists and is the right type - feels unimportant though - so just an alias for now for consistency
        removeField(name);
    }

    public function hasVar(name:String, lookInSuperClasses:Bool = false):Bool {
        return findVar(name, lookInSuperClasses) != null;
    }

    public function findVar(name:String, lookInSuperClasses:Bool = false):ClassVariable {
        if (fields != null) {
            for (f in fields) {
                if (f.name == name) {
                    var classVar = new ClassVariable(this, f);
                    return classVar;
                }
            }
        } else if (classFields != null) {
            for (f in classFields) {
                if (f.name == name) {
                    var classVar = new ClassVariable(this);
                    classVar.classField = f;
                    return classVar;
                }
            }
        }

        if (lookInSuperClasses) {
            var superClass = this.superClass;
            if (superClass != null) {
                return superClass.findVar(name, lookInSuperClasses);
            }
        }

        return null;
    }

    public function addVar(name:String, type:Null<ComplexType> = null, expr:Expr = null, access:Array<Access> = null, index:Null<Int> = null):ClassVariable {
        if (fields == null) {
            throw "can only add fields when class builder has field array";
        }

        if (access == null) {
            access = [];
        }
        if (!access.contains(APublic) && !access.contains(APrivate)) {
            if (name.startsWith("_")) {
                access.push(APrivate);
            } else {
                access.push(APublic);
            }
        }

        if (type == null) {
            type = macro: Any;
        }

        var field:Field = {
            name: name,
            access: access,
            kind: FVar(type, expr),
            pos: Context.currentPos()
        }

        if (index == null) {
            fields.push(field);
        } else {
            fields.insert(index, field);
        }
        var classVariable = new ClassVariable(this, field);
        return classVariable;
    }

    public function addStaticVar(name:String, type:Null<ComplexType> = null, expr:Expr = null, access:Array<Access> = null, index:Null<Int> = null):ClassVariable {
        if (access == null) {
            access = [];
        }
        if (!access.contains(AStatic)) {
            access.push(AStatic);
        }
        return addVar(name, type, expr, access, index);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // PROPS
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public function findProp(name:String, lookInSuperClasses:Bool = true):ClassProperty {
        if (fields != null) {
            for (f in fields) {
                if (f.name == name) {
                    var classProp = new ClassProperty(this, f);
                    return classProp;
                }
            }
        } else if (classFields != null) {
            for (f in classFields) {
                if (f.name == name) {
                    var classProp = new ClassProperty(this);
                    classProp.classField = f;
                    return classProp;
                }
            }
        }

        if (lookInSuperClasses) {
            var superClass = this.superClass;
            if (superClass != null) {
                return superClass.findProp(name, lookInSuperClasses);
            }
        }

        return null;
    }

    public function addProp(name:String, type:Null<ComplexType> = null, access:Array<Access> = null, index:Null<Int> = null, get:String = null, set:String = null):ClassProperty {
        if (fields == null) {
            throw "can only add properties when class builder has field array";
        }

        if (access == null) {
            access = [];
        }

        if (access == null) {
            access = [];
        }
        if (!access.contains(APublic) && !access.contains(APrivate)) {
            if (name.startsWith("_")) {
                access.push(APrivate);
            } else {
                access.push(APublic);
            }
        }

        if (type == null) {
            type = macro: Any;
        }

        if (get == null) {
            get = "null";
        }
        if (set == null) {
            set = "null";
        }

        var field:Field = {
            name: name,
            access: access,
            kind: FProp(get, set, type),
            pos: Context.currentPos()
        }

        if (index == null) {
            fields.push(field);
        } else {
            fields.insert(index, field);
        }

        var classProp = new ClassProperty(this, field);
        return classProp;

    }

    public function hasPropGetter(name:String, lookInSuperClasses:Bool = false):Bool {
        return hasFunction("get_" + name, lookInSuperClasses);
    }

    public function hasPropSetter(name:String, lookInSuperClasses:Bool = false):Bool {
        return hasFunction("set_" + name, lookInSuperClasses);
    }

    public function findPropGetter(name:String, lookInSuperClasses:Bool = false):ClassFunction {
        return findFunction("get_" + name, lookInSuperClasses);
    }

    public function findPropSetter(name:String, lookInSuperClasses:Bool = false):ClassFunction {
        return findFunction("set_" + name, lookInSuperClasses);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // FUNCTIONS
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public function removeFunction(name:String) {
        // TODO: might want to check if the field exists and is the right type - feels unimportant though - so just an alias for now for consistency
        removeField(name);
    }

    public function hasFunction(name:String, lookInSuperClasses:Bool = false):Bool {
        return findFunction(name, lookInSuperClasses) != null;
    }

    public function findFunction(name:String, lookInSuperClasses:Bool = false):ClassFunction {
        if (fields != null) {
            for (f in fields) {
                if (f.name == name) {
                    var classFunction = new ClassFunction(this, f);
                    return classFunction;
                }
            }
        } else if (name == "new" && classType != null) {
            if (classType.constructor != null) {
                var classFunction = new ClassFunction(this);
                classFunction.classField = classType.constructor.get();
                return classFunction;
            }
        } else if (classFields != null) {
            for (f in classFields) {
                if (f.name == name) {
                    var classFunction = new ClassFunction(this);
                    classFunction.classField = f;
                    return classFunction;
                }
            }
        }

        if (lookInSuperClasses) {
            var superClass = this.superClass;
            if (superClass != null) {
                return superClass.findFunction(name, lookInSuperClasses);
            }
        }

        return null;
    }

    public function addFunction(name:String, args:Array<FunctionArg> = null, expr:Expr = null, returnType:ComplexType = null, access:Array<Access> = null, params:Null<Array<TypeParamDecl>> = null):ClassFunction {
        if (fields == null) {
            throw "can only add fields when class builder has field array";
        }

        if (access == null) {
            access = [];
        }
        if (!access.contains(APublic) && !access.contains(APrivate)) {
            if (name.startsWith("_")) {
                access.push(APrivate);
            } else {
                access.push(APublic);
            }
        }

        if (args == null) {
            args = [];
        }

        var field:Field = {
            name: name,
            access: access,
            kind: FFun({
                args: args,
                ret: returnType,
                expr: expr,
                params: params
            }),
            pos: Context.currentPos()
        }

        fields.push(field);
        var classFunction = new ClassFunction(this, field);
        return classFunction;
    }

    public function addStaticFunction(name:String, args:Array<FunctionArg> = null, expr:Expr = null, returnType:ComplexType = null, access:Array<Access> = null, params:Null<Array<TypeParamDecl>> = null):ClassFunction {
        if (access == null) {
            access = [];
        }
        if (!access.contains(AStatic)) {
            access.push(AStatic);
        }
        return addFunction(name, args, expr, returnType, access, params);
    }

    public function createDefaultConstructor():ClassFunction {
        var constructor = findFunction("new");
        if (constructor == null) {
            constructor = this.addFunction("new");
            if (!this.isExtern) {
                if (this.superClass == null) {
                    constructor.expr = macro {
                    }
                } else {
                    constructor.expr = macro {
                        super();
                    }
                }
            }
        }
        return constructor;
    }

    private static function classTypeToClassBuilder(classType:ClassType) {
        var classBuilder = new ClassBuilder();
        classBuilder.classType = classType;
        classBuilder.classFields = classType.fields.get();
        classBuilder.staticClassFields = classType.statics.get();
        return classBuilder;
    }

}

#end