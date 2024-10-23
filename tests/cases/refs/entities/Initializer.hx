package cases.refs.entities;

import utest.Assert;
import promises.PromiseUtils;
import entities.primitives.EntityStringPrimitive;
import entities.primitives.EntityBoolPrimitive;
import entities.primitives.EntityIntPrimitive;
import entities.primitives.EntityFloatPrimitive;
import entities.primitives.EntityDatePrimitive;
import sys.FileSystem;
import db.IDatabase;
import promises.Promise;
import db.sqlite.SqliteDatabase;
import entities.EntityManager;
import sys.io.File;
import haxe.Json;

class Initializer {
    public static var sqliteFilename:String = "refs.db";

    public function new() {
    }

    public static function setupEntities(db:IDatabase):Promise<Bool> {
        return new Promise((resolve, reject) -> @:privateAccess {
            if ((db is SqliteDatabase) && sqliteFilename != null) {
                File.saveContent(sqliteFilename, "");
            }

            var promises = [];
            // pre-init'ing just makes the timings more like what they would be in the real world
            promises.push(MainObject.init.bind());
            promises.push(SubObjectA.init.bind());
            promises.push(SubSubObjectX.init.bind());
            promises.push(EntityBoolPrimitive.init.bind());
            promises.push(EntityIntPrimitive.init.bind());
            promises.push(EntityFloatPrimitive.init.bind());
            promises.push(EntityStringPrimitive.init.bind());
            promises.push(EntityDatePrimitive.init.bind());

            EntityManager.instance._queryCacheHitCount = 0;
            EntityManager.instance.database = db;
            @:privateAccess EntityManager.instance.connect().then(_ -> {
                return db.delete();
            }).then(_ -> {
                return db.create();
            }).then(_ -> {
                PromiseUtils.runSequentially(promises);
            }).then(_ -> {
                resolve(true);
            }, error -> {
                trace(error);
                trace(Json.stringify(error));
            });
        });
    }

    public static function teardownEntities(db:IDatabase):Promise<Bool> {
        return new Promise((resolve, reject) -> @:privateAccess {
            EntityManager.instance.reset().then(_ -> {
                MainObject._init = false;
                SubObjectA._init = false;
                SubSubObjectX._init = false;
                EntityBoolPrimitive._init = false;
                EntityIntPrimitive._init = false;
                EntityFloatPrimitive._init = false;
                EntityStringPrimitive._init = false;
                EntityDatePrimitive._init = false;
                try {
                    if (sqliteFilename != null && FileSystem.exists(sqliteFilename)) {
                        //FileSystem.deleteFile(sqliteFilename);
                    }
                } catch (e:Dynamic) {
                    trace(e);
                }
        
                resolve(true);
            }, error -> {
                trace("ERROR", error);
            });
        });
    }

    public static function createMainObject(name:String):MainObject {
        var mainObject = new MainObject();
        mainObject.name = name;
        return mainObject;
    }

    public static function createSubObject(name:String, arrayOfXs:Array<SubSubObjectX> = null):SubObjectA {
        var subObjectA = new SubObjectA();
        subObjectA.subObjectName = name;
        subObjectA.arrayOfXs = arrayOfXs;
        return subObjectA;
    }

    public static function createSubSubObjectX(name:String):SubSubObjectX {
        var o = new SubSubObjectX();
        o.xName = name;
        return o;
    }

}