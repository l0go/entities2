package entities.macros;

#if macro

import db.TableSchema;

class TableSchemaTools {
    public static function toTableSchemaExpr(tableSchema:TableSchema) {
        var cols = [];
        for (c in tableSchema.columns) {
            cols.push(macro {
                name: $v{c.name},
                type: $v{c.type}
            });
        }
        var expr = macro {
            name: $v{tableSchema.name},
            columns: $a{cols}
        };
        return expr;
    }
}

#end