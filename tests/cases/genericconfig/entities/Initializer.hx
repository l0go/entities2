package cases.genericconfig.entities;

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
    public static var sqliteFilename:String = "genericconfig.db";

    public function new() {
    }

    public static function setupEntities(db:IDatabase):Promise<Bool> {
        return new Promise((resolve, reject) -> @:privateAccess {
            if ((db is SqliteDatabase) && sqliteFilename != null) {
                File.saveContent(sqliteFilename, "");
            }

            var promises = [];
            // pre-init'ing just makes the timings more like what they would be in the real world
            promises.push(GenericConfig.init.bind());
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
                GenericConfig._init = false;
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

    public static function createConfig(name:String, stringValue:String = null, type:String = null, children:Array<GenericConfig> = null):GenericConfig {
        var genericConfig = new GenericConfig();
        genericConfig.name = name;
        genericConfig.stringValue = stringValue;
        genericConfig.type = type;
        genericConfig.children = children;
        return genericConfig;
    }

    public static function createComplexConfig():GenericConfig {
        var root = createConfig("root");
        var child1 = createConfig("child1", "101", "int");
            var child1_1 = createConfig("child1_1", "1011", "int");
            var child1_2 = createConfig("child1_2", "1012", "int");
            var child1_3 = createConfig("child1_3", "1013", "int");
            child1.children = [child1_1, child1_2, child1_3];
        var child2 = createConfig("child2", "value2", "bool");
            var child2_1 = createConfig("child2_1", "true", "bool");
            var child2_2 = createConfig("child2_2", "false", "bool");
            child2.children = [child2_1, child2_2];
        var child3 = createConfig("child3", "value3", "string");
            var child3_1 = createConfig("child3_1", "value3_1", "string");
            var child3_2 = createConfig("child3_2", "value3_2", "string");
            var child3_3 = createConfig("child3_3", "value3_3", "string");
            var child3_4 = createConfig("child3_4", "value3_4", "string");
            child3.children = [child3_1, child3_2, child3_3, child3_4];
        root.children = [child1, child2, child3];
        return root;        
    }

    public static function assertComplexConfig(config:GenericConfig) {
        Assert.equals("root", config.name);
        Assert.equals(null, config.stringValue);
        Assert.equals(null, config.type);
        Assert.notNull(config.children);
        Assert.equals(3, config.children.length);

        Assert.equals("child1", config.children[0].name);
        Assert.equals("101", config.children[0].stringValue);
        Assert.equals("int", config.children[0].type);
        Assert.equals(3, config.children[0].children.length);
        Assert.equals("child1_1", config.children[0].children[0].name);
        Assert.equals("child1_2", config.children[0].children[1].name);
        Assert.equals("child1_3", config.children[0].children[2].name);
        Assert.equals("1011", config.children[0].children[0].stringValue);
        Assert.equals("1012", config.children[0].children[1].stringValue);
        Assert.equals("1013", config.children[0].children[2].stringValue);

        Assert.equals("child2", config.children[1].name);
        Assert.equals("value2", config.children[1].stringValue);
        Assert.equals("bool", config.children[1].type);
        Assert.equals(2, config.children[1].children.length);
        Assert.equals("child2_1", config.children[1].children[0].name);
        Assert.equals("child2_2", config.children[1].children[1].name);
        Assert.equals("true", config.children[1].children[0].stringValue);
        Assert.equals("false", config.children[1].children[1].stringValue);

        Assert.equals("child3", config.children[2].name);
        Assert.equals("value3", config.children[2].stringValue);
        Assert.equals("string", config.children[2].type);
        Assert.equals(4, config.children[2].children.length);
        Assert.equals("child3_1", config.children[2].children[0].name);
        Assert.equals("child3_2", config.children[2].children[1].name);
        Assert.equals("child3_3", config.children[2].children[2].name);
        Assert.equals("child3_4", config.children[2].children[3].name);
        Assert.equals("value3_1", config.children[2].children[0].stringValue);
        Assert.equals("value3_2", config.children[2].children[1].stringValue);
        Assert.equals("value3_3", config.children[2].children[2].stringValue);
        Assert.equals("value3_4", config.children[2].children[3].stringValue);
    }
}