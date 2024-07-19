package entities.macros;

#if macro

import entities.macros.helpers.ClassVariable;

class ClassVariableTools {
    public static function isEntity(classVariable:ClassVariable):Bool {
        return classVariable.hasInterface("entities.IEntity");
    }

    public static function toEntityFieldType(classVariable:ClassVariable, defaultValue = EntityFieldType.Number):EntityFieldType {
        switch (classVariable.complexType) {
            case TPath(p):
                if (p.name == "StdTypes" && p.params.length == 1) {
                    switch (p.params[0]) {
                        case TPType(t):
                            switch (t) {
                                case TPath(p):
                                    return haxeTypeStringToEntityFieldType(p.sub, defaultValue);
                                case _:    
                            }
                        case _:    
                    }
                    return defaultValue;
                }
                return haxeTypeStringToEntityFieldType(p.name, defaultValue);
            case _:
        }
        return defaultValue;
    }

    public static function entityFieldOptions(classVariable:ClassVariable):Array<EntityFieldOption> {
        var fieldOptions:Array<EntityFieldOption> = [];
        if (classVariable.metadata.contains(EntityMetadata.PrimaryKey)) {
            fieldOptions.push(EntityFieldOption.PrimaryKey);
        }
        if (classVariable.metadata.contains(EntityMetadata.AutoIncrement)) {
            fieldOptions.push(EntityFieldOption.AutoIncrement);
        }
        if (classVariable.metadata.contains(EntityMetadata.Cascade)) {
            fieldOptions.push(EntityFieldOption.CascadeDeletions);
        }
        return fieldOptions;
    }

    static function haxeTypeStringToEntityFieldType(s:String, defaultValue = EntityFieldType.Number) {
        switch (s) {
            case "Bool":
                return EntityFieldType.Number;
            case "Int":
                return EntityFieldType.Number;
            case "Float":
                return EntityFieldType.Decimal;
            case "String":
                return EntityFieldType.Text;
            case "Date":
                return EntityFieldType.Date;
            case "haxe.io.Bytes":
                return EntityFieldType.Binary;
        }
        return defaultValue;
    }
}

#end