package cases.basic;

import cases.basic.entities.BasicEntity;
import utest.Assert;
import cases.basic.entities.Initializer;
import utest.Async;
import db.IDatabase;

class TestAdd extends TestBase {
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

    // if update is called and entities are found that arent in the db (no primary key), then it behaves as an add
    function testAdd_WhenUpdating(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        Assert.equals(null, mainEntity.basicEntityId);
        mainEntity.update().then(entity -> {
            Assert.equals(1, mainEntity.basicEntityId);
            Assert.equals("mainEntity", mainEntity.stringValue);
            return BasicEntity.findById(1);
        }).then(entity -> {
            Assert.equals(1, mainEntity.basicEntityId);
            Assert.equals("mainEntity", mainEntity.stringValue);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    // if update is called and entities are found that arent in the db (no primary key), then it behaves as an add
    function testAdd_WhenUpdating_OneToOne(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entity1 = createEntity("entity1", 222);
        mainEntity.add().then(entity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals("entity1", entity.entity1.stringValue);

            entity.stringValue += " - edited 1";
            entity.entity1.stringValue += " - edited 2";
            entity.entity2 = createEntity("entity2", 333);
            // here we are calling update, but entity2 is brand new (no pk), so we would expect an update for existing items and an add for new ones
            return entity.update();
        }).then(entity -> {
            Assert.equals("mainEntity - edited 1", entity.stringValue);
            Assert.equals("entity1 - edited 2", entity.entity1.stringValue);
            Assert.equals("entity2", entity.entity2.stringValue);

            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    // if update is called and entities are found that arent in the db (no primary key), then it behaves as an add
    function testAdd_WhenUpdating_OneToMany(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entitiesArray1 = [createEntity("entity1A")];
        mainEntity.add().then(entity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals(1, entity.entitiesArray1.length);
            Assert.equals("entity1A", entity.entitiesArray1[0].stringValue);
            Assert.equals(0, entity.entitiesArray2.length);

            entity.stringValue += " - edited 1";
            entity.entitiesArray1[0].stringValue += " - edited 2";
            entity.entitiesArray1.push(createEntity("entity1B"));
            entity.entitiesArray2 = [createEntity("entity2A"), createEntity("entity2B"), createEntity("entity2C")];
            // here we are calling update, but entitiesArray1 as a new item (no pk), and a previous empty entitiesArray2 has items now, these should be added and other items updated
            return entity.update();
        }).then(entity -> {
            Assert.equals("mainEntity - edited 1", entity.stringValue);
            Assert.equals(2, entity.entitiesArray1.length);
            Assert.equals("entity1A - edited 2", entity.entitiesArray1[0].stringValue);
            Assert.equals("entity1B", entity.entitiesArray1[1].stringValue);
            Assert.equals(3, entity.entitiesArray2.length);
            Assert.equals("entity2A", entity.entitiesArray2[0].stringValue);
            Assert.equals("entity2B", entity.entitiesArray2[1].stringValue);
            Assert.equals("entity2C", entity.entitiesArray2[2].stringValue);

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