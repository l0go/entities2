package entities;

import db.ColumnType;
import db.ColumnOptions;
import db.ColumnDefinition;
import db.TableSchema;

using StringTools;

class EntityDefinitionTools {
    public static function findField(entityDefinition:EntityDefinition, name:String):EntityFieldDefinition {
        for (f in entityDefinition.fields) {
            if (f.name == name) {
                return f;
            }
        }
        return null;
    }

    public static function safeClassName(entityDefinition:EntityDefinition):String {
        return entityDefinition.className.replace(".", "_");
    }

    public static function classParts(entityDefinition:EntityDefinition):Array<String> {
        return entityDefinition.className.split(".");
    }

    public static function forEachField(entityDefinition:EntityDefinition, type:EntityFieldType, callback:EntityFieldDefinition->Void) {

    }

    public static function primitiveFields(entityDefinition:EntityDefinition):Array<EntityFieldDefinition> {
        var fields = [];
        for (f in entityDefinition.fields) {
            switch (f.type) {
                case Unknown:
                case Boolean | Number | Decimal | Text | Date | Binary:
                    fields.push(f);
                case Entity(_, _, _):
                case Array(_):    
            }
        }
        return fields;
    }

    public static function entityFields_OneToOne(entityDefinition:EntityDefinition):Array<EntityFieldDefinition> {
        var fields = [];
        for (f in entityDefinition.fields) {
            switch (f.type) {
                case Entity(className, relationship, type):
                    switch (relationship) {
                        case OneToOne(table1, field1, table2, field2):
                            fields.push(f);
                        case _:
                    }
                case _:    
            }
        }
        return fields;
    }

    public static function entityFields_OneToMany(entityDefinition:EntityDefinition):Array<EntityFieldDefinition> {
        var fields = [];
        for (f in entityDefinition.fields) {
            switch (f.type) {
                case Entity(className, relationship, type):
                    switch (relationship) {
                        case OneToMany(table1, field1, table2, field2):
                            fields.push(f);
                        case _:
                    }
                case _:    
            }
        }
        return fields;
    }

    public static function forEachPrimitiveField(entityDefinition:EntityDefinition, callback:EntityFieldDefinition->Void) {
        for (f in entityDefinition.fields) {
            switch (f.type) {
                case Unknown:
                case Boolean | Number | Decimal | Text | Date | Binary:
                    callback(f);
                case Entity(_, _, _):
                case Array(_):    
            }
        }
    }

    public static function forEachEntity_OneToOne(entityDefinition:EntityDefinition, callback:EntityFieldDefinition->String->String->String->String->String->Void) {
        for (f in entityDefinition.fields) {
            switch (f.type) {
                case Entity(className, relationship, type):
                    switch (relationship) {
                        case OneToOne(table1, field1, table2, field2):
                            callback(f, className, table1, field1, table2, field2);
                        case _:
                    }
                case _:    
            }
        }
    }

    public static function forEachEntity_OneToMany(entityDefinition:EntityDefinition, callback:EntityFieldDefinition->String->String->String->String->String->Void) {
        for (f in entityDefinition.fields) {
            switch (f.type) {
                case Entity(className, relationship, type):
                    switch (relationship) {
                        case OneToMany(table1, field1, table2, field2):
                            callback(f, className, table1, field1, table2, field2);
                        case _:
                    }
                case _:    
            }
        }
    }

    public static function toTableSchema(entityDefinition:EntityDefinition):TableSchema {
        var tableSchema:TableSchema = {
            name: entityDefinition.tableName,
            columns: []
        }

        for (entityField in entityDefinition.fields) {
            switch (entityField.type) {
                case Boolean | Number | Decimal | Text | Date | Binary:
                    tableSchema.columns.push({
                        name: entityField.name,
                        type: toColumnType(entityField.type),
                        options: toColumnOptions(entityField, entityDefinition)
                    });
                case Entity(className, relationship, type):
                    switch (relationship) {
                        case OneToOne(table1, field1, table2, field2):
                            tableSchema.columns.push({
                                name: entityField.name,
                                type: toColumnType(type),
                                options: []
                            });
                        case OneToMany(table1, field1, table2, field2):    
                    }
                case _:
                    trace(entityField.name, "unknown", entityField.type);
            }
        }

        return tableSchema;
    }

    public static function primitiveEntityFieldName(field:EntityFieldDefinition):String {
        return "_" + field.name + "Entities";
    }

    public static function foreignKey(field:EntityFieldDefinition):String {
        var key = null;
        switch (field.type) {
            case Entity(className, relationship, type):
                switch (relationship) {
                    case OneToOne(table1, field1, table2, field2):
                        key = field2;
                    case OneToMany(table1, field1, table2, field2):
                        key = field2;
                    case _:    
                }
            case _:    
        }
        return key;
    }

    public static function joinForeignKey(field:EntityFieldDefinition):String {
        var key = null;
        switch (field.type) {
            case Entity(className, relationship, type):
                switch (relationship) {
                    case OneToMany(table1, field1, table2, field2):
                        key = field.name + "_" + field2;
                    case _:    
                }
            case _:    
        }
        return key;
    }

    public static function joinTableName(field:EntityFieldDefinition):String {
        var key = null;
        switch (field.type) {
            case Entity(className, relationship, type):
                switch (relationship) {
                    case OneToMany(table1, field1, table2, field2):
                        key = table1 + "_" + field.name;
                    case _:    
                }
            case _:    
        }
        return key;
    }

    public static function cascadeDeletions(field:EntityFieldDefinition):Bool {
        return field.options.contains(CascadeDeletions);
    }

    public static function toColumnType(type:EntityFieldType):ColumnType {
        return switch (type) {
            case EntityFieldType.Boolean:       ColumnType.Boolean;
            case EntityFieldType.Number:        ColumnType.Number;
            case EntityFieldType.Decimal:       ColumnType.Decimal;
            case EntityFieldType.Text:          ColumnType.Memo; // TODO: too big?
            case EntityFieldType.Date:          ColumnType.Text(255); // TODO: too big?
            case EntityFieldType.Binary:        ColumnType.Binary;
            case _:    
                trace("unknown", type);
                ColumnType.Unknown;
        }
    }

    private static function toColumnOptions(entityField:EntityFieldDefinition, entityDefinition:EntityDefinition):Array<ColumnOptions> {
        var options = [];
        if (entityField.name == entityDefinition.primaryKeyFieldName) {
            options.push(ColumnOptions.PrimaryKey);
            options.push(ColumnOptions.NotNull);
            if (entityDefinition.primaryKeyFieldAutoIncrement) {
                options.push(ColumnOptions.AutoIncrement);
            }
        }
        return options;
    }
}