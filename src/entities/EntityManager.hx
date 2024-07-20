package entities;

import Query.QueryExpr;
import db.RecordSet;
import db.DatabaseResult;
import db.Record;
import db.ITable;
import db.DatabaseError;
import promises.Promise;
import db.TableSchema;
import db.IDatabase;

class EntityManager {
    private static var _instance:EntityManager = null;
    public static var instance(get, null):EntityManager;
    private static function get_instance():EntityManager {
        if (_instance == null) {
            _instance = new EntityManager();
        }
        return _instance;
    }

    //////////////////////////////////////////////////////////////////////////////
    public var database:IDatabase;
    
    private function new() {
    }

    private var _connected:Bool = false;
    private function connect():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (_connected == true) {
                resolve(true);
                return;
            }

            database.connect().then(result -> {
                _tableCache = [];
                //_queryCache = [];
                return database.create();
            }).then(_ -> {
                //database.setProperty("alwaysAliasResultFields", true);
                //database.setProperty("complexRelationships", true);
                _connected = true;
                resolve(true);
            }, (error:DatabaseError) -> {
                reject(error);
            });
        });
    }

    private function disconnect():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (!_connected) {
                resolve(true);
            } else {
                database.disconnect().then(_ -> {
                    _tableCache = [];
                    //_queryCache = [];
                    _connected = false;
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            }
        });
    }

    private var _nextQueryCacheId:Float = 1;
    private function generateQueryCachedId():String {
        var id = _nextQueryCacheId;
        _nextQueryCacheId++;
        return Std.string(id);
    }

    private var _tableCache:Map<String, ITable> = [];
    private function lookupTable(tableName:String):Promise<ITable> {
        return new Promise((resolve, reject) -> {
            if (_tableCache.exists(tableName)) {
                resolve(_tableCache.get(tableName));
            } else {
                database.table(tableName).then(result -> {
                    _tableCache.set(tableName, result.table);
                    resolve(result.table);
                }, error -> {
                    reject(error);
                });
            }
        });
    }

    private function updateRecord(tableName:String, query:QueryExpr, record:Record):Promise<Record> {
        return new Promise((resolve, reject) -> {
            lookupTable(tableName).then(table -> {
                return table.update(query, record);
            }).then(result -> {
                resolve(result.data);
            }, error -> {
                reject(error);
            });
        });
    }

    private function addRecord(tableName:String, record:Record):Promise<Record> {
        return new Promise((resolve, reject) -> {
            lookupTable(tableName).then(table -> {
                return table.add(record);
            }).then(result -> {
                resolve(result.data);
            }, error -> {
                reject(error);
            });
        });
    }

    private function addRecords(tableName:String, records:Array<Record>):Promise<RecordSet> {
        return new Promise((resolve, reject) -> {
            lookupTable(tableName).then(table -> {
                return table.addAll(records);
            }).then(result -> {
                resolve(result.data);
            }, error -> {
                reject(error);
            });
        });
    }

    private function find(tableName:String, query:QueryExpr, cacheId:String = null):Promise<RecordSet> {
        return new Promise((resolve, reject) -> {
            lookupTable(tableName).then(table -> {
                return table.find(query);
            }).then(result -> {
                resolve(result.data);
            }, error -> {
                reject(error);
            });
        });
    }

    private function deleteAll(tableName:String, query:QueryExpr):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            lookupTable(tableName).then(table -> {
                return table.deleteAll(query);
            }).then(result -> {
                resolve(result.data);
            }, error -> {
                reject(error);
            });
        });
    }

    private function checkTableSchema(schema:TableSchema):Promise<Bool> {
        return new promises.Promise((resolve, reject) -> {
            connect().then(_ -> {
                return lookupTable(schema.name);
            }).then(table -> {
                if (table.exists) {
                    table.applySchema(schema).then(result -> {
                        resolve(true);
                        return null;
                    }, error -> {
                        reject(error);
                    });
                    return null;
                }
                database.createTable(schema.name, schema.columns).then(result -> {
                    _tableCache.set(schema.name, result.table);
                    resolve(true);
                }, error -> {
                    reject(error);
                });                
            }, error -> {
                reject(error);
            });
        });
    }

    private function diffIds(idsInDB:Array<Null<Int>>, ids:Array<Null<Int>>):{idsToRemove:Array<Null<Int>>, idsToAdd:Array<Null<Int>>} {
        var idsToRemove = idsInDB.filter(id -> !ids.contains(id));
        var idsToAdd = ids.filter(id -> !idsInDB.contains(id));
        return {
            idsToRemove: idsToRemove,
            idsToAdd: idsToAdd
        }
    }

    private function convertPrimitiveToDB(value:Any, type:EntityFieldType):Any {
        if (value == null) {
            return value;
        }
        switch (type) {
            case Boolean:
                return value == true ? 1 : 0;
            case Date:
                return DateTools.format(value, "%Y-%m-%d %H:%M:%S"); 
            case _:    
        }
        return value;
    }

    private function convertPrimitiveFromDB(value:Any, type:EntityFieldType):Any {
        if (value == null) {
            return value;
        }
        switch (type) {
            case Boolean:
                return value == 1;
            case Date:
                return Date.fromString(value);
            case _:    
        }
        return value;
    }

    private function reset():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            disconnect().then(_ -> {
                database = null;
                _connected = false;
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

}