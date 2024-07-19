package entities.macros;

#if macro

import haxe.macro.Type;

using entities.macros.helpers.MacroTypeTools;

class EntityTypeTools {
    public static function isEntity(type:Type):Bool {
        return type.hasInterface("entities.IEntity");
    }
}

#end