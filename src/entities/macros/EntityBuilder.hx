package entities.macros;

import haxe.macro.ComplexTypeTools;
#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import entities.macros.helpers.ClassBuilder;
import entities.macros.helpers.ClassField;
import db.TableSchema;

using haxe.macro.Tools;
using entities.macros.EntityComplexTypeTools;
using entities.macros.ClassBuilderTools;
using entities.macros.EntityBuilderTools;
using entities.macros.ClassVariableTools;
using entities.macros.TableSchemaTools;
using entities.EntityDefinitionTools;

class EntityBuilder {
    macro static function build():Array<Field> {
        Sys.println("entities    > building entity '" + Context.getLocalClass().toString() + "'");
        var firstInterface = Context.getLocalClass().get().interfaces[0];
        if (firstInterface != null && firstInterface.t.toString() != "entities.IEntity") {
            Context.warning('IEntity interface should be the last on the interface list to ensure it gets processed first by haxe', Context.currentPos());
        }

        var entityClass = new ClassBuilder(Context.getBuildFields(), Context.getLocalType());
        var constructor = entityClass.createDefaultConstructor();

        var entityDefinition:EntityDefinition = {
            className: entityClass.qualifiedName,
            tableName: entityClass.tableName(),
            fields: [],
            primaryKeyFieldName: null,
            primaryKeyFieldType: null
        }
        entityClass.checkForPrimaryKeys(entityDefinition);
        //var entityComplexType = entityClass.toComplexType();

        for (v in entityClass.vars) {
            if (v.isStatic) {
                continue;
            }

            var fieldName = v.name;
            var fieldOptions:Array<EntityFieldOption> = v.entityFieldOptions();

            switch (v.complexType) {
                case (macro: Bool)  | (macro: Null<Bool>):
                    entityDefinition.fields.push({ name: fieldName, options: fieldOptions, type: EntityFieldType.Boolean });
                case (macro: Int)   | (macro: Null<Int>):
                    entityDefinition.fields.push({ name: fieldName, options: fieldOptions, type: EntityFieldType.Number });
                case (macro: Float) | (macro: Null<Float>):
                    entityDefinition.fields.push({ name: fieldName, options: fieldOptions, type: EntityFieldType.Decimal });
                case (macro: String):
                    entityDefinition.fields.push({ name: fieldName, options: fieldOptions, type: EntityFieldType.Text });
                case (macro: Date):
                    entityDefinition.fields.push({ name: fieldName, options: fieldOptions, type: EntityFieldType.Date });
                case (macro: Array<$valueComplexType>):
                    if (valueComplexType.isEntity()) {
                        var entityValueClass = new ClassBuilder(valueComplexType.toType());
                        if (entityValueClass.qualifiedName == entityClass.qualifiedName) {
                            entityValueClass = entityClass;
                        }
                        var entityValueFullClassName = valueComplexType.toType().toString();
                        entityDefinition.fields.push({
                            name: fieldName,
                            options: fieldOptions,
                            type: EntityFieldType.Entity(
                                entityValueClass.qualifiedName,
                                EntityFieldRelationship.OneToMany(
                                    entityClass.tableName(), entityClass.primaryKeyFieldName(),
                                    entityValueClass.tableName(), entityValueClass.primaryKeyFieldName()
                                ),
                                EntityFieldType.Number
                            )
                        });
                    } else {
                        var primitiveType = null;
                        switch (valueComplexType) {
                            case (macro: Bool)  | (macro: Null<Bool>):
                                primitiveType = "Bool";
                            case (macro: Int)   | (macro: Null<Int>):    
                                primitiveType = "Int";
                            case (macro: Float) | (macro: Null<Float>):
                                primitiveType = "Float";
                            case (macro: String):
                                primitiveType = "String";
                            case (macro: Date):
                                primitiveType = "Date";
                            case _:
                                trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", valueComplexType);
                        }
                        var valueComplexType = TPath(primitiveType.primitiveEntityTypePathFromType());
                        var entityValueClass = new ClassBuilder(valueComplexType.toType());
                        if (entityValueClass.qualifiedName == entityClass.qualifiedName) {
                            entityValueClass = entityClass;
                        }
                        var entityValueFullClassName = valueComplexType.toType().toString();
                        entityDefinition.fields.push({
                            name: fieldName,
                            options: fieldOptions,
                            type: EntityFieldType.Entity(
                                entityValueClass.qualifiedName,
                                EntityFieldRelationship.OneToMany(
                                    entityClass.tableName(), entityClass.primaryKeyFieldName(),
                                    entityValueClass.tableName(), entityValueClass.primaryKeyFieldName()
                                ),
                                EntityFieldType.Number
                            ),
                            primitive: true,
                            primitiveType: primitiveType
                        });
                        entityClass.addVar("_" + fieldName + "Entities", macro: Array<$valueComplexType>, macro null, [APrivate]);
                    }
                case (macro: Map<$keyComplexType, $valueComplexType>):
                case (macro: $valueComplexType):
                    if (valueComplexType.isEntity()) {
                        var entityValueClass = new ClassBuilder(valueComplexType.toType());
                        if (entityValueClass.qualifiedName == entityClass.qualifiedName) {
                            entityValueClass = entityClass;
                        }
                        entityDefinition.fields.push({
                            name: fieldName,
                            options: fieldOptions,
                            type: EntityFieldType.Entity(
                                entityValueClass.qualifiedName,
                                EntityFieldRelationship.OneToOne(
                                    entityClass.tableName(), entityClass.primaryKeyFieldName(),
                                    entityValueClass.tableName(), entityValueClass.primaryKeyFieldName()
                                ),
                                EntityFieldType.Number
                            )
                        });
                    } else {
                        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>> its NOT an entity", valueComplexType);
                    }
            }
            //Sys.println("entities    >    " + v.name);
        }

        buildEntityDefinitionFields(entityClass, entityDefinition);
        buildTableSchemaFields(entityClass, entityDefinition);
        buildInit(entityClass, entityDefinition);
        buildCheckTables(entityClass, entityDefinition);

        buildToRecord(entityClass, entityDefinition);
        buildFromRecord(entityClass, entityDefinition);
        
        buildAdd(entityClass, entityDefinition);
        buildAddData(entityClass, entityDefinition);
        buildAddJoinData(entityClass, entityDefinition);

        buildDelete(entityClass, entityDefinition);
        buildDeleteData(entityClass, entityDefinition);
        buildDeleteJoinData(entityClass, entityDefinition);
        buildDeleteById(entityClass, entityDefinition);

        buildUpdate(entityClass, entityDefinition);
        buildUpdateData(entityClass, entityDefinition);
        buildUpdateJoinData(entityClass, entityDefinition);

        buildFindInternal(entityClass, entityDefinition);
        buildFindById(entityClass, entityDefinition);

        return entityClass.fields;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Misc
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static function buildEntityDefinitionFields(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        entityClass.addStaticVar("EntityDefinition", macro: entities.EntityDefinition, macro $v{entityDefinition}, [APrivate]);

        var primaryKeyQueryFn = entityClass.addStaticFunction("primaryKeyQuery", [
            {name: "primaryKey", type: macro: Null<Int>}
        ], macro: Query.QueryExpr, [APrivate]);
        primaryKeyQueryFn.code += macro {
            var q = Query.query(Query.field($v{primaryKeyName}) = primaryKey);
            return q;
        }

        var primaryKeysQueryFn = entityClass.addStaticFunction("primaryKeysQuery", [
            {name: "primaryKeys", type: macro: Array<Int>}
        ], macro: Query.QueryExpr, [APrivate]);
        primaryKeysQueryFn.code += macro {
            var q = Query.query(Query.field($v{primaryKeyName}) in primaryKeys);
            return q;
        }

    }

    static function buildTableSchemaFields(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        entityClass.addStaticVar("TableSchema", macro: db.TableSchema, macro entities.EntityDefinitionTools.toTableSchema(EntityDefinition), [APrivate]);

        var associationTableSchemas = [];
        for (field in entityDefinition.fields) {
            switch (field.type) {
                case Unknown | Boolean | Number | Decimal | Text | Date | Binary:
                    // do nothing, dont want to use "case _:" so future enum additions will be flagged and handled explicitly
                case Array(type):
                    // TODO: will need association table
                case Entity(className, relationship, type):
                    switch (relationship) {
                        case OneToOne(table1, field1, table2, field2):
                            // do nothing, dont want to use "case _:" so future enum additions will be flagged and handled explicitly
                        case OneToMany(table1, field1, table2, field2):
                            var associationTableSchema:TableSchema = {
                                name: table1 + "_" + field.name,
                                columns: [
                                    {name: field1, type: type.toColumnType()},
                                    {name: field.name + "_" + field2, type: type.toColumnType()}
                                ]
                            };
                            associationTableSchemas.push(associationTableSchema.toTableSchemaExpr());
                    }
            }
        }
        entityClass.addStaticVar("JoinTableSchemas", macro: Array<db.TableSchema>, macro $a{associationTableSchemas}, [APrivate]);
    }

    static function buildInit(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        entityClass.addStaticVar("_init", macro: Bool, macro false, [APrivate]);
        var initFn = entityClass.addStaticFunction("init", macro: promises.Promise<Bool>, [APrivate]);

        initFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                if (_init) {
                    resolve(true);
                } else {
                    _init = true;
                    entities.EntityManager.instance.connect().then(success -> {
                        return checkTables();
                    }).then(result -> {
                        resolve(true);
                    }, error -> {
                        reject(error);
                    });
                }
            });
        }
    }

    public static function buildCheckTables(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var checkTablesFn = entityClass.addStaticFunction("checkTables", macro: promises.Promise<Bool>, [APrivate]);
        checkTablesFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                var promiseList = [];
                promiseList.push(entities.EntityManager.instance.checkTableSchema.bind(TableSchema));
                for (joinTableSchema in JoinTableSchemas) {
                    promiseList.push(entities.EntityManager.instance.checkTableSchema.bind(joinTableSchema));
                }
                promises.PromiseUtils.runSequentially(promiseList).then(_ -> {
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Record
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static function buildToRecord(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var toRecordFn = entityClass.addFunction("toRecord", [
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: db.Record, [APrivate]);

        toRecordFn.code += macro @:privateAccess {
            var record = new db.Record();
            $b{[for (entityField in entityDefinition.primitiveFields()) {
                macro {
                    record.field($v{entityField.name}, entities.EntityManager.instance.convertPrimitiveToDB($i{entityField.name}, $v{entityField.type}));
                }
            }]}
            $b{[for (entityField in entityDefinition.entityFields_OneToOne()) {
                var foreignKey = entityField.foreignKey();
                macro {
                    if ($i{entityField.name} != null) {
                        record.field($v{entityField.name}, $i{entityField.name}.$foreignKey);
                    }
                }
            }]}
            return record;
        }
    }

    static function buildFromRecord(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var fromRecordFn = entityClass.addFunction("fromRecord", [
            {name: "record", type: macro: db.Record},
            {name: "queryCacheId", type: macro: String},
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<$entityComplexType>, [APrivate]);

        fromRecordFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                init().then(_ -> {
                    // primary key
                    this.$primaryKeyName = record.field($v{primaryKeyName});
                    // primitives
                    $b{[for (entityField in entityDefinition.primitiveFields()) {
                        if (entityField.name == primaryKeyName) {
                            continue;
                        }
                        macro {
                            if (fieldSet.allow($v{entityField.name})) {
                                $i{entityField.name} = entities.EntityManager.instance.convertPrimitiveFromDB(record.field($v{entityField.name}), $v{entityField.type});
                            }
                        }
                    }]}

                    var promiseList:Array<() -> promises.Promise<Any>> = [];

                    // one to one
                    $b{[for (entityField in entityDefinition.entityFields_OneToOne()) {
                        var classDef = entityField.toClassDefExpr();
                        macro {
                            if (fieldSet.allow($v{entityField.name})) {
                                var id = record.field($v{entityField.name});
                                if (id != null) {
                                    promiseList.push(() -> {
                                        return new promises.Promise((resolve, reject) -> {
                                            $p{classDef}.findInternal($p{classDef}.primaryKeyQuery(id), queryCacheId, fieldSet).then(entities -> {
                                                $i{entityField.name} = entities[0];
                                                resolve(true);
                                            }, error -> {
                                                reject(error);
                                            });
                                        }); 
                                    });
                                }
                            }
                        }
                    }]}
                    // one to many
                    $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                        var fieldName = entityField.name;
                        if (entityField.primitive) {
                            fieldName = entityField.primitiveEntityFieldName();
                        }
                        var joinTableName = entityField.joinTableName();
                        var joinForeignKey = entityField.joinForeignKey();
                        var classDef = entityField.toClassDefExpr();
                        macro {
                            if (fieldSet.allow($v{entityField.name}) && $i{primaryKeyName} != null) {
                                promiseList.push(() -> {
                                    return new promises.Promise((resolve, reject) -> {
                                        entities.EntityManager.instance.find($v{joinTableName}, primaryKeyQuery($i{primaryKeyName}), queryCacheId).then(result -> {
                                            var ids = result.extractFieldValues($v{joinForeignKey});
                                            if (ids.length == 0) {
                                                return null;
                                            }
                                            return $p{classDef}.findInternal($p{classDef}.primaryKeysQuery(ids), queryCacheId, fieldSet);
                                        }).then(entities -> {
                                            if (entities != null) {
                                                $i{fieldName} = entities;
                                                ${if (entityField.primitive) {
                                                    macro {
                                                        $i{entityField.name} = [];
                                                        for (item in entities) {
                                                            $i{entityField.name}.push(item.value);
                                                        }
                                                    };
                                                } else {
                                                    macro null;
                                                }}
                                            } else {
                                                $i{fieldName} = [];
                                                ${if (entityField.primitive) {
                                                    macro {
                                                        $i{entityField.name} = [];
                                                    };
                                                } else {
                                                    macro null;
                                                }}
                                            }
                                            resolve(true);
                                        }, error -> {
                                            reject(error);
                                        });
                                    });
                                });
                            }
                        }
                    }]}

                    return promises.PromiseUtils.runSequentially(promiseList);
                }).then(result -> {
                    resolve(this);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Add
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static function buildAdd(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var addFn = entityClass.addFunction("add", [
            {name: "fieldSet", type: macro: entities.EntityFieldSet, value: macro null}
        ], macro: promises.Promise<$entityComplexType>, [APublic]);

        addFn.code += macro @:privateAccess {
            if (fieldSet == null) fieldSet = new entities.EntityFieldSet();
            if ($i{primaryKeyName} != null) {
                return update(fieldSet);
            } else {
                return new promises.Promise((resolve, reject) -> {
                    init().then(_ -> {
                        var promiseList:Array<() -> promises.Promise<Any>> = [];
                        // one to one
                        $b{[for (entityField in entityDefinition.entityFields_OneToOne()) {
                            var foreignKey = entityField.foreignKey();
                            macro {
                                if ($i{entityField.name} != null) {
                                    if ($i{entityField.name}.$foreignKey == null) {
                                        promiseList.push($i{entityField.name}.add.bind(fieldSet));
                                    } else {
                                        promiseList.push($i{entityField.name}.update.bind(fieldSet));
                                    }
                                }
                            }
                        }]}
                        // one to many
                        $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                            var fieldName = entityField.name;
                            if (entityField.primitive) {
                                fieldName = entityField.primitiveEntityFieldName();
                            }
                            var foreignKey = entityField.foreignKey();
                            macro {
                                ${if (entityField.primitive) {
                                    var primitiveEntityClassComplexType = entityField.primitiveEntityTypePath();
                                    macro {
                                        if ($i{entityField.name} != null) {
                                            $i{fieldName} = [];
                                            for (item in $i{entityField.name}) {
                                                $i{fieldName}.push(new $primitiveEntityClassComplexType(item));
                                            }
                                        }
                                    };
                                } else {
                                    macro null;
                                }}

                                if ($i{fieldName} != null) {
                                    for (item in $i{fieldName}) {
                                        if (item.$foreignKey == null) {
                                            promiseList.push(item.add.bind(fieldSet));
                                        } else {
                                            promiseList.push(item.update.bind(fieldSet));
                                        }
                                    }
                                }
                            }
                        }]}
                        return promises.PromiseUtils.runSequentially(promiseList);
                    }).then(result -> {
                        return addData(fieldSet);
                    }).then(result -> {
                        resolve(this);
                    }, error -> {
                        reject(error);
                    });
                });            
            }
        }
    }

    static function buildAddData(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var entityTableName = entityDefinition.tableName;
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var addDataFn = entityClass.addFunction("addData", [
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<$entityComplexType>, [APrivate]);

        addDataFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                var record = this.toRecord(fieldSet);
                init().then(_ -> {
                    return entities.EntityManager.instance.addRecord($v{entityTableName}, record);
                }).then(result -> {
                    this.$primaryKeyName = result.field("_insertedId");
                    return addJoinData(fieldSet);
                }).then(result -> {
                    resolve(this);
                }, error -> {
                    reject(error);
                });
            });
        }

    }

    static function buildAddJoinData(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var primaryKeyField = entityDefinition.primaryKeyFieldName;

        var addJoinDataFn = entityClass.addFunction("addJoinData", [
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<Bool>, [APrivate]);

        addJoinDataFn.code += macro {
            return new promises.Promise((resolve, reject) -> @:privateAccess {
                init().then(_ -> {
                    var promiseList = [];

                    $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                        var fieldName = entityField.name;
                        if (entityField.primitive) {
                            fieldName = entityField.primitiveEntityFieldName();
                        }
                        var joinForeignKey = entityField.joinForeignKey();
                        var foreignKey = entityField.foreignKey();
                        macro {
                            promiseList.push(() -> {
                                return new promises.Promise((resolve, reject) -> {
                                    var joinRecords = new Array<db.Record>();
                                    if ($i{fieldName} != null) {
                                        for (item in $i{fieldName}) {
                                            var joinRecord = new db.Record();
                                            joinRecord.field($v{primaryKeyField}, $i{primaryKeyField});
                                            joinRecord.field($v{joinForeignKey}, item.$foreignKey);
                                            joinRecords.push(joinRecord);
                                        }
                                    }
                                    entities.EntityManager.instance.addRecords($v{entityField.joinTableName()}, joinRecords).then(_ -> {
                                        resolve(true);
                                    }, error -> {
                                        reject(error);
                                    });
                                });
                            });
                        }
                    }]}
                    
                    return promises.PromiseUtils.runSequentially(promiseList);
                }).then(result -> {
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Delete
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static function buildDelete(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var addFn = entityClass.addFunction("delete", [
            {name: "fieldSet", type: macro: entities.EntityFieldSet, value: macro null}
        ], macro: promises.Promise<$entityComplexType>, [APublic]);

        addFn.code += macro {
            if (fieldSet == null) fieldSet = new entities.EntityFieldSet();
            return new promises.Promise((resolve, reject) -> {
                var entityInDB:$entityComplexType = null;
                init().then(_ -> {
                    return findById(this.$primaryKeyName);
                }).then(result -> {
                    entityInDB = result;
                    var promiseList:Array<() -> promises.Promise<Any>> = [];
                    // one to one
                    $b{[for (entityField in entityDefinition.entityFields_OneToOne()) {
                        macro { // TODO: only if cascade deletions
                            if ($i{entityField.name} != null) {
                                promiseList.push($i{entityField.name}.delete.bind(fieldSet));
                            }
                        }
                    }]}
                    // one to many
                    $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                        var fieldName = entityField.name;
                        if (entityField.primitive) {
                            fieldName = entityField.primitiveEntityFieldName();
                        }
                        macro { // TODO: only if cascade deletions
                            if ($i{fieldName} != null) {
                                for (item in $i{fieldName}) {
                                    promiseList.push(item.delete.bind(fieldSet));
                                }
                            }
                        }
                    }]}
                    return promises.PromiseUtils.runSequentially(promiseList);
                }).then(result -> {
                    return deleteData(entityInDB, fieldSet);
                }).then(result -> {
                    resolve(this);
                }, error -> {
                    reject(error);
                });
            });            
        }
    }

    static function buildDeleteData(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var entityTableName = entityDefinition.tableName;
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var addDataFn = entityClass.addFunction("deleteData", [
            {name: "entityInDB", type: macro: $entityComplexType},
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<$entityComplexType>, [APrivate]);

        addDataFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                init().then(_ -> {
                    return entities.EntityManager.instance.deleteAll($v{entityTableName}, primaryKeyQuery($i{primaryKeyName}));
                }).then(result -> {
                    return deleteJoinData(entityInDB, fieldSet);
                }).then(result -> {
                    resolve(this);
                }, error -> {
                    reject(error);
                });
            });
        }

    }

    static function buildDeleteJoinData(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyField = entityDefinition.primaryKeyFieldName;

        var addJoinDataFn = entityClass.addFunction("deleteJoinData", [
            {name: "entityInDB", type: macro: $entityComplexType},
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<Bool>, [APrivate]);

        addJoinDataFn.code += macro {
            return new promises.Promise((resolve, reject) -> @:privateAccess {
                init().then(_ -> {
                    var promiseList:Array<() -> promises.Promise<Any>> = [];
                    // one to many
                    $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                        var fieldName = entityField.name;
                        if (entityField.primitive) {
                            fieldName = entityField.primitiveEntityFieldName();
                        }
                        var foreignKey = entityField.foreignKey();
                        var joinForeignKey = entityField.joinForeignKey();
                        var joinTableName = entityField.joinTableName();
                        macro {
                            if ($i{fieldName} != null) {
                                var idsInDB = entityInDB.$fieldName.map(item -> item.$foreignKey);
                                if (idsInDB.length > 0) {
                                    var query = Query.query(Query.field($v{joinForeignKey}) in idsInDB);
                                    promiseList.push(entities.EntityManager.instance.deleteAll.bind($v{joinTableName}, query));
                                }
                            }
                        }
                    }]}
                    return promises.PromiseUtils.runSequentially(promiseList);
                }).then(result -> {
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    static function buildDeleteById(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyField = entityDefinition.primaryKeyFieldName;

        var deleteJoinDataFn = entityClass.addStaticFunction("deleteById", [
            {name: "id", type: macro: Null<Int>},
            {name: "fieldSet", type: macro: entities.EntityFieldSet, value: macro null}
        ], macro: promises.Promise<Bool>, [APrivate]);

        deleteJoinDataFn.code += macro {
            if (fieldSet == null) fieldSet = new entities.EntityFieldSet();
            return new promises.Promise((resolve, reject) -> @:privateAccess {
                init().then(_ -> {
                    return findById(id);
                }).then(result -> {
                    return result.delete(fieldSet);
                }).then(result -> {
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Update
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static function buildUpdate(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var updateFn = entityClass.addFunction("update", [
            {name: "fieldSet", type: macro: entities.EntityFieldSet, value: macro null}
        ], macro: promises.Promise<$entityComplexType>, [APublic]);

        updateFn.code += macro @:privateAccess {
            if (fieldSet == null) fieldSet = new entities.EntityFieldSet();
            if ($i{primaryKeyName} == null) {
                return add(fieldSet);
            } else {
                return new promises.Promise((resolve, reject) -> {
                    var entityInDB:$entityComplexType = null;
                    init().then(_ -> {
                        return findById(this.$primaryKeyName);
                    }).then(result -> {
                        entityInDB = result;
                        var promiseList:Array<() -> promises.Promise<Any>> = [];
                        // one to one
                        $b{[for (entityField in entityDefinition.entityFields_OneToOne()) {
                            var foreignKey = entityField.foreignKey();
                            macro {
                                if ($i{entityField.name} != null) {
                                    if ($i{entityField.name}.$foreignKey == null) {
                                        promiseList.push($i{entityField.name}.add.bind(fieldSet));
                                    } else {
                                        promiseList.push($i{entityField.name}.update.bind(fieldSet));
                                    }
                                }
                            }
                        }]}
                        // one to many
                        $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                            var fieldName = entityField.name;
                            if (entityField.primitive) {
                                fieldName = entityField.primitiveEntityFieldName();
                            }
                            var foreignKey = entityField.foreignKey();
                            macro {
                                ${if (entityField.primitive) {
                                    var primitiveEntityClassComplexType = entityField.primitiveEntityTypePath();
                                    macro {
                                        if ($i{entityField.name} != null) {
                                            if ($i{fieldName} == null) {
                                                $i{fieldName} = [];
                                            }
                                            while ($i{fieldName}.length > $i{entityField.name}.length) {
                                                $i{fieldName}.pop();
                                            }
                                            while ($i{fieldName}.length != $i{entityField.name}.length) {
                                                $i{fieldName}.push(new $primitiveEntityClassComplexType());
                                            }
                                            //var diff1 
                                            for (i in 0...$i{entityField.name}.length) {
                                                $i{fieldName}[i].value = $i{entityField.name}[i];
                                            }
                                        }
                                    };
                                } else {
                                    macro null;
                                }}

                                if ($i{fieldName} != null) {
                                    for (item in $i{fieldName}) {
                                        if (item.$foreignKey == null) {
                                            promiseList.push(item.add.bind(fieldSet));
                                        } else {
                                            promiseList.push(item.update.bind(fieldSet));
                                        }
                                    }
                                }
                            }
                        }]}
                        return promises.PromiseUtils.runSequentially(promiseList);
                    }).then(result -> {
                        return updateData(entityInDB, fieldSet);
                    }).then(result -> {
                        resolve(this);
                    }, error -> {
                        reject(error);
                    });
                });            
            }
        }
    }

    static function buildUpdateData(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var entityTableName = entityDefinition.tableName;
        var primaryKeyName = entityDefinition.primaryKeyFieldName;

        var updateDataFn = entityClass.addFunction("updateData", [
            {name: "entityInDB", type: macro: $entityComplexType},
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<$entityComplexType>, [APrivate]);

        updateDataFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                var record = toRecord(fieldSet);
                init().then(_ -> {
                    entities.EntityManager.instance.updateRecord($v{entityTableName}, primaryKeyQuery($i{primaryKeyName}), record);
                }).then(result -> {
                    return updateJoinData(entityInDB, fieldSet);
                }).then(result -> {
                    resolve(this);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    static function buildUpdateJoinData(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var primaryKeyField = entityDefinition.primaryKeyFieldName;

        var updateJoinDataFn = entityClass.addFunction("updateJoinData", [
            {name: "entityInDB", type: macro: $entityComplexType},
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<Bool>, [APrivate]);

        updateJoinDataFn.code += macro {
            return new promises.Promise((resolve, reject) -> @:privateAccess {
                init().then(_ -> {
                    var promiseList:Array<() -> promises.Promise<Any>> = [];
                    // one to many
                    $b{[for (entityField in entityDefinition.entityFields_OneToMany()) {
                        var fieldName = entityField.name;
                        if (entityField.primitive) {
                            fieldName = entityField.primitiveEntityFieldName();
                        }
                        var foreignKey = entityField.foreignKey();
                        var classDef = entityField.toClassDefExpr();
                        var joinTableName = entityField.joinTableName();
                        var joinForeignKey = entityField.joinForeignKey();
                        macro {
                            if ($i{fieldName} != null) {
                                var diff = entities.EntityManager.instance.diffIds(
                                    entityInDB.$fieldName.map(item -> item.$foreignKey),
                                    this.$fieldName.map(item -> item.$foreignKey)
                                );

                                if (diff.idsToRemove.length > 0) {
                                    for (id in diff.idsToRemove) {
                                        promiseList.push($p{classDef}.deleteById.bind(id));  // TODO: if cascade deletions
                                        // we always want to delete the joins
                                        var query = Query.query(Query.field($v{joinForeignKey}) in diff.idsToRemove);
                                        promiseList.push(entities.EntityManager.instance.deleteAll.bind($v{joinTableName}, query));
                                    }
                                }

                                if (diff.idsToAdd.length > 0) {
                                    var joinRecords:Array<db.Record> = [];
                                    for (id in diff.idsToAdd) {
                                        var joinRecord = new db.Record();
                                        joinRecord.field($v{primaryKeyField}, this.$primaryKeyField);
                                        joinRecord.field($v{joinForeignKey}, id);
                                        joinRecords.push(joinRecord);
                                    }
                                    promiseList.push(entities.EntityManager.instance.addRecords.bind($v{joinTableName}, joinRecords));
                                }
                            }
                        }
                    }]}
                    return promises.PromiseUtils.runSequentially(promiseList);
                }).then(result -> {
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Queries
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static function buildFindInternal(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();
        var entityTypePath = entityClass.toTypePath();
        var tableName = entityDefinition.tableName;

        var findInternalFn = entityClass.addStaticFunction("findInternal", [
            {name: "query", type: macro: Query.QueryExpr},
            {name: "queryCacheId", type: macro: String},
            {name: "fieldSet", type: macro: entities.EntityFieldSet}
        ], macro: promises.Promise<Array<$entityComplexType>>, [APrivate]);

        findInternalFn.code += macro @:privateAccess {
            return new promises.Promise((resolve, reject) -> {
                init().then(_ -> {
                    return entities.EntityManager.instance.find($v{tableName}, query, queryCacheId);
                }).then(result -> {
                    var promisesList:Array<() -> promises.Promise<$entityComplexType>> = [];
                    for (record in result) {
                        var entity = new $entityTypePath();
                        promisesList.push(entity.fromRecord.bind(record, queryCacheId, fieldSet));
                    }
                    return promises.PromiseUtils.runSequentially(promisesList);
                }).then(entities -> {
                    resolve(entities);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    static function buildFindById(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();

        var findByIdFn = entityClass.addStaticFunction("findById", [
            {name: "id", type: macro: Null<Int>},
            {name: "fieldSet", type: macro: entities.EntityFieldSet, value: macro null}
        ], macro: promises.Promise<$entityComplexType>, [APublic]);

        findByIdFn.code += macro @:privateAccess {
            var queryCacheId = entities.EntityManager.instance.generateQueryCachedId();
            if (fieldSet == null) fieldSet = new entities.EntityFieldSet();
            return new promises.Promise((resolve, reject) -> {
                init().then(_ -> {
                    return findInternal(primaryKeyQuery(id), queryCacheId, fieldSet);
                }).then(entities -> {
                    resolve(entities[0]);
                }, error -> {
                    reject(error);
                });
            });
        }
    }

    /*
    static function buildFindAll(entityClass:ClassBuilder, entityDefinition:EntityDefinition) {
        var entityComplexType = entityClass.toComplexType();

        var findAllFn = entityClass.addStaticFunction("findAll", [
            {name: "query", type: macro: Query.QueryExpr, value: macro null},
            {name: "fieldSet", type: macro: entities.EntityFieldSet, value: macro null}
        ], macro: promises.Promise<$entityComplexType>, [APublic]);

        findAllFn.code += macro @:privateAccess {
            var queryCacheId = entities.EntityManager.instance.generateQueryCachedId();
            if (fieldSet == null) fieldSet = new entities.EntityFieldSet();
            return new promises.Promise((resolve, reject) -> {
                init().then(_ -> {
                    resolve(null);
                }, error -> {
                    reject(error);
                });
            });
        }
    }
        */
}

#end