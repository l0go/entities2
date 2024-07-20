package cases.basic;

import cases.basic.entities.BasicEntity;
import utest.Assert;
import cases.basic.entities.Initializer;
import utest.Async;
import db.IDatabase;

class TestBasic extends TestBase {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
        this.db = db;
    }
    
    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        new Initializer().run(db).then(_ -> {
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        new Initializer().cleanUp(db).then(_ -> {
            async.done();
        });
    }

    function testBasic_Primitives(async:Async) {
        var entity1 = createEntity("this is a string value for entity #1", 123, 456.789, true, new Date(2000, 2, 3, 4, 5, 6));

        entity1.add().then(entity1 -> {
            Assert.equals(1, entity1.basicEntityId);
            Assert.equals("this is a string value for entity #1", entity1.stringValue);
            Assert.equals(123, entity1.intValue);
            Assert.equals(456.789, entity1.floatValue);
            Assert.equals(true, entity1.boolValue);
            //Assert.equals(new Date(1, 2, 3, 4, 5, 6).toString(), entity1.dateValue.toString());
            return BasicEntity.findById(1);
        }).then(entity -> {
            Assert.equals(1, entity.basicEntityId);
            Assert.equals("this is a string value for entity #1", entity.stringValue);
            Assert.equals(123, entity.intValue);
            Assert.equals(456.789, entity.floatValue);
            Assert.equals(true, entity.boolValue);
            //Assert.equals(new Date(1, 2, 3, 4, 5, 6).toString(), entity.dateValue.toString());

            entity.stringValue += " - addition";
            entity.intValue *= 2;
            entity.floatValue /= 2;
            entity.boolValue = !entity.boolValue;
            return entity.update();
        }).then(entity -> {
            Assert.equals(1, entity.basicEntityId);
            Assert.equals("this is a string value for entity #1 - addition", entity.stringValue);
            Assert.equals(246, entity.intValue);
            Assert.equals(228.3945, entity.floatValue);
            Assert.equals(false, entity.boolValue);
            //Assert.equals(new Date(1, 2, 3, 4, 5, 6).toString(), entity.dateValue.toString());

            return BasicEntity.findById(1);
        }).then(entity -> {
            Assert.equals(1, entity.basicEntityId);
            Assert.equals("this is a string value for entity #1 - addition", entity.stringValue);
            Assert.equals(246, entity.intValue);
            Assert.equals(228.3945, entity.floatValue);
            Assert.equals(false, entity.boolValue);
            //Assert.equals(new Date(1, 2, 3, 4, 5, 6).toString(), entity.dateValue.toString());
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testBasic_OneToOne(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entity1 = createEntity("entity1", 123);
        mainEntity.entity2 = createEntity("entity2", 456);

        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);

            Assert.equals("entity1", mainEntity.entity1.stringValue);
            Assert.equals(123, mainEntity.entity1.intValue);

            Assert.equals("entity2", mainEntity.entity2.stringValue);
            Assert.equals(456, mainEntity.entity2.intValue);
            
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals(111, entity.intValue);

            Assert.equals("entity1", entity.entity1.stringValue);
            Assert.equals(123, entity.entity1.intValue);

            Assert.equals("entity2", entity.entity2.stringValue);
            Assert.equals(456, entity.entity2.intValue);

            entity.stringValue += " - edited 1";
            entity.entity1.stringValue += " - edited 2";
            entity.entity2.stringValue += " - edited 3";

            return entity.update();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity - edited 1", entity.stringValue);
            Assert.equals(111, entity.intValue);

            Assert.equals("entity1 - edited 2", entity.entity1.stringValue);
            Assert.equals(123, entity.entity1.intValue);

            Assert.equals("entity2 - edited 3", entity.entity2.stringValue);
            Assert.equals(456, entity.entity2.intValue);

            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testBasic_OneToMany(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entitiesArray1 = [createEntity("entity 1A"), createEntity("entity 1B"), createEntity("entity 1C")];
        mainEntity.entitiesArray2 = [createEntity("entity 2A"), createEntity("entity 2B")];

        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);

            Assert.equals(3, mainEntity.entitiesArray1.length);
            Assert.equals("entity 1A", mainEntity.entitiesArray1[0].stringValue);
            Assert.equals("entity 1B", mainEntity.entitiesArray1[1].stringValue);
            Assert.equals("entity 1C", mainEntity.entitiesArray1[2].stringValue);

            Assert.equals(2, mainEntity.entitiesArray2.length);
            Assert.equals("entity 2A", mainEntity.entitiesArray2[0].stringValue);
            Assert.equals("entity 2B", mainEntity.entitiesArray2[1].stringValue);
            
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals(111, entity.intValue);

            Assert.equals(3, entity.entitiesArray1.length);
            Assert.equals("entity 1A", entity.entitiesArray1[0].stringValue);
            Assert.equals("entity 1B", entity.entitiesArray1[1].stringValue);
            Assert.equals("entity 1C", entity.entitiesArray1[2].stringValue);

            Assert.equals(2, entity.entitiesArray2.length);
            Assert.equals("entity 2A", entity.entitiesArray2[0].stringValue);
            Assert.equals("entity 2B", entity.entitiesArray2[1].stringValue);

            entity.stringValue += " - edited 1";
            entity.entitiesArray1[0].stringValue += " - edited 2";
            entity.entitiesArray1[2].stringValue += " - edited 3";
            entity.entitiesArray2[1].stringValue += " - edited 4";

            return entity.update();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity - edited 1", entity.stringValue);
            Assert.equals(111, entity.intValue);

            Assert.equals(3, entity.entitiesArray1.length);
            Assert.equals("entity 1A - edited 2", entity.entitiesArray1[0].stringValue);
            Assert.equals("entity 1B", entity.entitiesArray1[1].stringValue);
            Assert.equals("entity 1C - edited 3", entity.entitiesArray1[2].stringValue);

            Assert.equals(2, entity.entitiesArray2.length);
            Assert.equals("entity 2A", entity.entitiesArray2[0].stringValue);
            Assert.equals("entity 2B - edited 4", entity.entitiesArray2[1].stringValue);

            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    public static function createEntity(stringValue:String, intValue:Null<Int> = null, floatValue:Null<Float> = null, boolValue:Null<Bool> = null, dateValue:Date = null, entity1:BasicEntity = null, entity2:BasicEntity = null, entitiesArray1:Array<BasicEntity> = null, entitiesArray2:Array<BasicEntity> = null) {
        var entity = new BasicEntity();
        entity.stringValue = stringValue;
        entity.intValue = intValue;
        entity.floatValue = floatValue;
        entity.boolValue = boolValue;
        entity.dateValue = dateValue;
        entity.entity1 = entity1;
        entity.entity2 = entity2;
        entity.entitiesArray1 = entitiesArray1;
        entity.entitiesArray2 = entitiesArray2;
        return entity;
    }
}