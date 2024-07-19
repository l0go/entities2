package entities.macros;

#if macro

import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using entities.macros.helpers.MacroTypeTools;
using entities.macros.EntityTypeTools;

class EntityComplexTypeTools {
    public static function isEntity(complexType:ComplexType):Bool {
        return complexType.toType().isEntity();
    }

    public static function toComplexType(field:EntityFieldDefinition):ComplexType {
        return null;
    }

    public static function toClassDefExpr(field:EntityFieldDefinition):Array<String> {
        switch (field.type) {
            case Entity(className, relationship, type):
                switch (relationship) {
                    case OneToOne(table1, field1, table2, field2):
                        return className.split(".");
                    case OneToMany(table1, field1, table2, field2):
                        return className.split(".");
                }
            case _:    
        }
        return null;
    }
}

#end