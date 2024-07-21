package cases.basic;

import cases.basic.entities.BasicEntity;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.basic.entities.Initializer.*;

@:timeout(10000)
class TestFieldSets_Blacklist_Basic extends TestBase {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
        this.db = db;
    }
    
    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        setupEntities(db).then(_ -> {
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        teardownEntities(db).then(_ -> {
            async.done();
        });
    }

    function testFind_Blacklist_Primitive(async:Async) {
        var mainEntity = createEntity("mainEntity");
        mainEntity.add().then(mainEntity -> {
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            return BasicEntity.findById(entity.basicEntityId, BasicEntity.NoStringValue);
        }).then(entity -> {
            Assert.isNull(entity.stringValue);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testFind_Blacklist_Primitive_Nested(async:Async) {
        var mainEntity = createEntity("mainEntity");
        mainEntity.entity1 = createEntity("entity1");
        mainEntity.entity2 = createEntity("entity2");
        mainEntity.entity3 = createEntity("entity3");
        mainEntity.entity4 = createEntity("entity4");
        mainEntity.add().then(mainEntity -> {
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            return BasicEntity.findById(entity.basicEntityId, BasicEntity.NoStringValue);
        }).then(entity -> {
            Assert.isNull(entity.stringValue);
            Assert.isNull(entity.entity1.stringValue);
            Assert.isNull(entity.entity2.stringValue);
            Assert.isNull(entity.entity3.stringValue);
            Assert.isNull(entity.entity4.stringValue);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testFind_Blacklist_Primitive_Nested_Deep(async:Async) {
        var mainEntity = createEntity("mainEntity");
        mainEntity.entity1 = createEntity("entity1");
            mainEntity.entity1.entity1 = createEntity("entity1_1");
            mainEntity.entity1.entity2 = createEntity("entity1_2");
            mainEntity.entity1.entity3 = createEntity("entity1_3");
            mainEntity.entity1.entity4 = createEntity("entity1_4");
        mainEntity.entity2 = createEntity("entity2");
            mainEntity.entity2.entity1 = createEntity("entity2_1");
            mainEntity.entity2.entity2 = createEntity("entity2_2");
            mainEntity.entity2.entity3 = createEntity("entity2_3");
            mainEntity.entity2.entity4 = createEntity("entity2_4");
        mainEntity.entity3 = createEntity("entity3");
            mainEntity.entity3.entity1 = createEntity("entity3_1");
            mainEntity.entity3.entity2 = createEntity("entity3_2");
            mainEntity.entity3.entity3 = createEntity("entity3_3");
            mainEntity.entity3.entity4 = createEntity("entity3_4");
        mainEntity.entity4 = createEntity("entity4");
            mainEntity.entity4.entity1 = createEntity("entity4_1");
            mainEntity.entity4.entity2 = createEntity("entity4_2");
            mainEntity.entity4.entity3 = createEntity("entity4_3");
            mainEntity.entity4.entity4 = createEntity("entity4_4");
        mainEntity.add().then(mainEntity -> {
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals("entity1", entity.entity1.stringValue);
            Assert.equals("entity1_1", entity.entity1.entity1.stringValue);
            Assert.equals("entity1_2", entity.entity1.entity2.stringValue);
            Assert.equals("entity1_3", entity.entity1.entity3.stringValue);
            Assert.equals("entity1_4", entity.entity1.entity4.stringValue);
            Assert.equals("entity2", entity.entity2.stringValue);
            Assert.equals("entity2_1", entity.entity2.entity1.stringValue);
            Assert.equals("entity2_2", entity.entity2.entity2.stringValue);
            Assert.equals("entity2_3", entity.entity2.entity3.stringValue);
            Assert.equals("entity2_4", entity.entity2.entity4.stringValue);
            Assert.equals("entity3", entity.entity3.stringValue);
            Assert.equals("entity3_1", entity.entity3.entity1.stringValue);
            Assert.equals("entity3_2", entity.entity3.entity2.stringValue);
            Assert.equals("entity3_3", entity.entity3.entity3.stringValue);
            Assert.equals("entity3_4", entity.entity3.entity4.stringValue);
            Assert.equals("entity4", entity.entity4.stringValue);
            Assert.equals("entity4_1", entity.entity4.entity1.stringValue);
            Assert.equals("entity4_2", entity.entity4.entity2.stringValue);
            Assert.equals("entity4_3", entity.entity4.entity3.stringValue);
            Assert.equals("entity4_4", entity.entity4.entity4.stringValue);
            return BasicEntity.findById(entity.basicEntityId, BasicEntity.NoStringValue);
        }).then(entity -> {
            Assert.isNull(entity.stringValue);
            Assert.isNull(entity.entity1.stringValue);
            Assert.isNull(entity.entity1.entity1.stringValue);
            Assert.isNull(entity.entity1.entity2.stringValue);
            Assert.isNull(entity.entity1.entity3.stringValue);
            Assert.isNull(entity.entity1.entity4.stringValue);
            Assert.isNull(entity.entity2.stringValue);
            Assert.isNull(entity.entity2.entity1.stringValue);
            Assert.isNull(entity.entity2.entity2.stringValue);
            Assert.isNull(entity.entity2.entity3.stringValue);
            Assert.isNull(entity.entity2.entity4.stringValue);
            Assert.isNull(entity.entity3.stringValue);
            Assert.isNull(entity.entity3.entity1.stringValue);
            Assert.isNull(entity.entity3.entity2.stringValue);
            Assert.isNull(entity.entity3.entity3.stringValue);
            Assert.isNull(entity.entity3.entity4.stringValue);
            Assert.isNull(entity.entity4.stringValue);
            Assert.isNull(entity.entity4.entity1.stringValue);
            Assert.isNull(entity.entity4.entity2.stringValue);
            Assert.isNull(entity.entity4.entity3.stringValue);
            Assert.isNull(entity.entity4.entity4.stringValue);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testFind_Blacklist_Primitive_Nested_Deep_Arrays(async:Async) {
        var mainEntity = createEntity("mainEntity");
        mainEntity.entity1 = createEntity("entity1");
            mainEntity.entity1.entity1 = createEntity("entity1_1");
            mainEntity.entity1.entity2 = createEntity("entity1_2");
                mainEntity.entity1.entity2.entitiesArray1 = [createEntity("entity1_2_array1_1"), createEntity("entity1_2_array1_2"), createEntity("entity1_2_array1_3")];
            mainEntity.entity1.entity3 = createEntity("entity1_3");
            mainEntity.entity1.entity4 = createEntity("entity1_4");
        mainEntity.entity2 = createEntity("entity2");
            mainEntity.entity2.entity1 = createEntity("entity2_1");
            mainEntity.entity2.entity2 = createEntity("entity2_2");
            mainEntity.entity2.entity3 = createEntity("entity2_3");
                mainEntity.entity2.entity3.entitiesArray3 = [createEntity("entity2_3_array3_1"), createEntity("entity2_3_array3_2")];
            mainEntity.entity2.entity4 = createEntity("entity2_4");
                mainEntity.entity2.entity4.entitiesArray3 = [createEntity("entity2_4_array3_1")];
            mainEntity.entity3 = createEntity("entity3");
            mainEntity.entity3.entity1 = createEntity("entity3_1");
            mainEntity.entity3.entity2 = createEntity("entity3_2");
            mainEntity.entity3.entity3 = createEntity("entity3_3");
            mainEntity.entity3.entity4 = createEntity("entity3_4");
        mainEntity.entity4 = createEntity("entity4");
            mainEntity.entity4.entity1 = createEntity("entity4_1");
            mainEntity.entity4.entity2 = createEntity("entity4_2");
            mainEntity.entity4.entity3 = createEntity("entity4_3");
            mainEntity.entity4.entity4 = createEntity("entity4_4");
        mainEntity.add().then(mainEntity -> {
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals("entity1", entity.entity1.stringValue);
            Assert.equals("entity1_1", entity.entity1.entity1.stringValue);
            Assert.equals(3, entity.entity1.entity2.entitiesArray1.length);
            Assert.equals("entity1_2_array1_1", entity.entity1.entity2.entitiesArray1[0].stringValue);
            Assert.equals("entity1_2_array1_2", entity.entity1.entity2.entitiesArray1[1].stringValue);
            Assert.equals("entity1_2_array1_3", entity.entity1.entity2.entitiesArray1[2].stringValue);
            Assert.equals("entity1_2", entity.entity1.entity2.stringValue);
            Assert.equals("entity1_3", entity.entity1.entity3.stringValue);
            Assert.equals("entity1_4", entity.entity1.entity4.stringValue);
            Assert.equals("entity2", entity.entity2.stringValue);
            Assert.equals("entity2_1", entity.entity2.entity1.stringValue);
            Assert.equals("entity2_2", entity.entity2.entity2.stringValue);
            Assert.equals("entity2_3", entity.entity2.entity3.stringValue);
            Assert.equals(2, entity.entity2.entity3.entitiesArray3.length);
            Assert.equals("entity2_3_array3_1", entity.entity2.entity3.entitiesArray3[0].stringValue);
            Assert.equals("entity2_3_array3_2", entity.entity2.entity3.entitiesArray3[1].stringValue);
            Assert.equals(1, entity.entity2.entity4.entitiesArray3.length);
            Assert.equals("entity2_4_array3_1", entity.entity2.entity4.entitiesArray3[0].stringValue);
            Assert.equals("entity2_4", entity.entity2.entity4.stringValue);
            Assert.equals("entity3", entity.entity3.stringValue);
            Assert.equals("entity3_1", entity.entity3.entity1.stringValue);
            Assert.equals("entity3_2", entity.entity3.entity2.stringValue);
            Assert.equals("entity3_3", entity.entity3.entity3.stringValue);
            Assert.equals("entity3_4", entity.entity3.entity4.stringValue);
            Assert.equals("entity4", entity.entity4.stringValue);
            Assert.equals("entity4_1", entity.entity4.entity1.stringValue);
            Assert.equals("entity4_2", entity.entity4.entity2.stringValue);
            Assert.equals("entity4_3", entity.entity4.entity3.stringValue);
            Assert.equals("entity4_4", entity.entity4.entity4.stringValue);
            return BasicEntity.findById(entity.basicEntityId, BasicEntity.NoStringValue);
        }).then(entity -> {
            Assert.isNull(entity.stringValue);
            Assert.isNull(entity.entity1.stringValue);
            Assert.isNull(entity.entity1.entity1.stringValue);
            Assert.isNull(entity.entity1.entity2.stringValue);
            Assert.isNull(entity.entity1.entity3.stringValue);
            Assert.isNull(entity.entity1.entity4.stringValue);
            Assert.isNull(entity.entity2.stringValue);
            Assert.isNull(entity.entity2.entity1.stringValue);
            Assert.isNull(entity.entity2.entity2.stringValue);
            Assert.isNull(entity.entity2.entity3.stringValue);
            Assert.isNull(entity.entity2.entity4.stringValue);
            Assert.isNull(entity.entity3.stringValue);
            Assert.isNull(entity.entity3.entity1.stringValue);
            Assert.isNull(entity.entity3.entity2.stringValue);
            Assert.isNull(entity.entity3.entity3.stringValue);
            Assert.isNull(entity.entity3.entity4.stringValue);
            Assert.isNull(entity.entity4.stringValue);
            Assert.isNull(entity.entity4.entity1.stringValue);
            Assert.isNull(entity.entity4.entity2.stringValue);
            Assert.isNull(entity.entity4.entity3.stringValue);
            Assert.isNull(entity.entity4.entity4.stringValue);

            Assert.equals(3, entity.entity1.entity2.entitiesArray1.length);
            Assert.isNull(entity.entity1.entity2.entitiesArray1[0].stringValue);
            Assert.isNull(entity.entity1.entity2.entitiesArray1[1].stringValue);
            Assert.isNull(entity.entity1.entity2.entitiesArray1[2].stringValue);

            Assert.equals(2, entity.entity2.entity3.entitiesArray3.length);
            Assert.isNull(entity.entity2.entity3.entitiesArray3[0].stringValue);
            Assert.isNull(entity.entity2.entity3.entitiesArray3[1].stringValue);

            Assert.equals(1, entity.entity2.entity4.entitiesArray3.length);
            Assert.isNull(entity.entity2.entity4.entitiesArray3[0].stringValue);

            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testFind_Blacklist_OneToOne(async:Async) {
        var mainEntity = createEntity("mainEntity");
        mainEntity.entity1 = createEntity("entity1");
        mainEntity.entity2 = createEntity("entity2");
        mainEntity.entity3 = createEntity("entity3");
        mainEntity.entity4 = createEntity("entity4");
        mainEntity.add().then(mainEntity -> {
            return BasicEntity.findById(mainEntity.basicEntityId);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.equals("entity1", entity.entity1.stringValue);
            Assert.equals("entity2", entity.entity2.stringValue);
            Assert.equals("entity3", entity.entity3.stringValue);
            Assert.equals("entity4", entity.entity4.stringValue);
            return BasicEntity.findById(entity.basicEntityId, BasicEntity.NoEntities);
        }).then(entity -> {
            Assert.equals("mainEntity", entity.stringValue);
            Assert.isNull(entity.entity1);
            Assert.isNull(entity.entity2);
            Assert.isNull(entity.entity3);
            Assert.isNull(entity.entity4);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }
}