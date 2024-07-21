package cases.basic;

import entities.primitives.EntityStringPrimitive;
import cases.basic.entities.BasicEntity;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.basic.entities.Initializer.*;

@:timeout(10000)
class TestDelete extends TestBase {
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

    function testDelete_Normal(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);

        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testDelete_OneToOne_NoCascade(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entity1 = createEntity("entity1", 222);

        var entity1Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals("entity1", mainEntity.entity1.stringValue);
            Assert.equals(222, mainEntity.entity1.intValue);
            entity1Id = mainEntity.entity1.basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.notNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testDelete_OneToOne_NoCascade_Dual(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entity1 = createEntity("entity1", 222);
        mainEntity.entity2 = createEntity("entity2", 333);

        var entity1Id = -1;
        var entity2Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals("entity1", mainEntity.entity1.stringValue);
            Assert.equals(222, mainEntity.entity1.intValue);
            Assert.equals("entity2", mainEntity.entity2.stringValue);
            Assert.equals(333, mainEntity.entity2.intValue);
            entity1Id = mainEntity.entity1.basicEntityId;
            entity2Id = mainEntity.entity2.basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity2Id);
        }).then(entity -> {
            Assert.notNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testDelete_OneToOne_Cascade(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entity1 = createEntity("entity1", 222);
        mainEntity.entity3 = createEntity("entity3", 444);

        var entity1Id = -1;
        var entity3Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals("entity1", mainEntity.entity1.stringValue);
            Assert.equals(222, mainEntity.entity1.intValue);
            Assert.equals("entity3", mainEntity.entity3.stringValue);
            Assert.equals(444, mainEntity.entity3.intValue);
            entity1Id = mainEntity.entity1.basicEntityId;
            entity3Id = mainEntity.entity3.basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity3Id);
        }).then(entity -> {
            Assert.isNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testDelete_OneToOne_Cascade_Dual(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entity1 = createEntity("entity1", 222);
        mainEntity.entity2 = createEntity("entity2", 333);
        mainEntity.entity3 = createEntity("entity3", 444);
        mainEntity.entity4 = createEntity("entity4", 555);

        var entity1Id = -1;
        var entity2Id = -1;
        var entity3Id = -1;
        var entity4Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals("entity1", mainEntity.entity1.stringValue);
            Assert.equals(222, mainEntity.entity1.intValue);
            Assert.equals("entity2", mainEntity.entity2.stringValue);
            Assert.equals(333, mainEntity.entity2.intValue);
            Assert.equals("entity3", mainEntity.entity3.stringValue);
            Assert.equals(444, mainEntity.entity3.intValue);
            Assert.equals("entity4", mainEntity.entity4.stringValue);
            Assert.equals(555, mainEntity.entity4.intValue);
            entity1Id = mainEntity.entity1.basicEntityId;
            entity2Id = mainEntity.entity2.basicEntityId;
            entity3Id = mainEntity.entity3.basicEntityId;
            entity4Id = mainEntity.entity4.basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity2Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity3Id);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity4Id);
        }).then(entity -> {
            Assert.isNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testDelete_OneToMany_NoCascade(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entitiesArray1 = [createEntity("entity1", 222), createEntity("entity2", 333)];

        var entity1Id = -1;
        var entity2Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals(2, mainEntity.entitiesArray1.length);
            Assert.equals("entity1", mainEntity.entitiesArray1[0].stringValue);
            Assert.equals(222, mainEntity.entitiesArray1[0].intValue);
            Assert.equals("entity2", mainEntity.entitiesArray1[1].stringValue);
            Assert.equals(333, mainEntity.entitiesArray1[1].intValue);
            entity1Id = mainEntity.entitiesArray1[0].basicEntityId;
            entity2Id = mainEntity.entitiesArray1[1].basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity2Id);
        }).then(entity -> {
            Assert.notNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    function testDelete_OneToMany_NoCascade_Dual(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entitiesArray1 = [createEntity("entity1", 222), createEntity("entity2", 333)];
        mainEntity.entitiesArray2 = [createEntity("entity3", 444), createEntity("entity4", 555)];

        var entity1Id = -1;
        var entity2Id = -1;
        var entity3Id = -1;
        var entity4Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals(2, mainEntity.entitiesArray1.length);
            Assert.equals("entity1", mainEntity.entitiesArray1[0].stringValue);
            Assert.equals(222, mainEntity.entitiesArray1[0].intValue);
            Assert.equals("entity2", mainEntity.entitiesArray1[1].stringValue);
            Assert.equals(333, mainEntity.entitiesArray1[1].intValue);

            Assert.equals(2, mainEntity.entitiesArray2.length);
            Assert.equals("entity3", mainEntity.entitiesArray2[0].stringValue);
            Assert.equals(444, mainEntity.entitiesArray2[0].intValue);
            Assert.equals("entity4", mainEntity.entitiesArray2[1].stringValue);
            Assert.equals(555, mainEntity.entitiesArray2[1].intValue);
            entity1Id = mainEntity.entitiesArray1[0].basicEntityId;
            entity2Id = mainEntity.entitiesArray1[1].basicEntityId;
            entity3Id = mainEntity.entitiesArray2[0].basicEntityId;
            entity4Id = mainEntity.entitiesArray2[1].basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity2Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity3Id);
        }).then(entity -> {
            Assert.notNull(entity);
            return BasicEntity.findById(entity4Id);
        }).then(entity -> {
            Assert.notNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }
        
    function testDelete_OneToMany_Cascade(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entitiesArray3 = [createEntity("entity1", 222), createEntity("entity2", 333)];

        var entity1Id = -1;
        var entity2Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals(2, mainEntity.entitiesArray3.length);
            Assert.equals("entity1", mainEntity.entitiesArray3[0].stringValue);
            Assert.equals(222, mainEntity.entitiesArray3[0].intValue);
            Assert.equals("entity2", mainEntity.entitiesArray3[1].stringValue);
            Assert.equals(333, mainEntity.entitiesArray3[1].intValue);
            entity1Id = mainEntity.entitiesArray3[0].basicEntityId;
            entity2Id = mainEntity.entitiesArray3[1].basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity2Id);
        }).then(entity -> {
            Assert.isNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }
    
    function testDelete_OneToMany_Cascade_Dual(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.entitiesArray3 = [createEntity("entity1", 222), createEntity("entity2", 333)];
        mainEntity.entitiesArray4 = [createEntity("entity3", 444), createEntity("entity4", 555)];

        var entity1Id = -1;
        var entity2Id = -1;
        var entity3Id = -1;
        var entity4Id = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals(2, mainEntity.entitiesArray3.length);
            Assert.equals("entity1", mainEntity.entitiesArray3[0].stringValue);
            Assert.equals(222, mainEntity.entitiesArray3[0].intValue);
            Assert.equals("entity2", mainEntity.entitiesArray3[1].stringValue);
            Assert.equals(333, mainEntity.entitiesArray3[1].intValue);

            Assert.equals(2, mainEntity.entitiesArray4.length);
            Assert.equals("entity3", mainEntity.entitiesArray4[0].stringValue);
            Assert.equals(444, mainEntity.entitiesArray4[0].intValue);
            Assert.equals("entity4", mainEntity.entitiesArray4[1].stringValue);
            Assert.equals(555, mainEntity.entitiesArray4[1].intValue);
            entity1Id = mainEntity.entitiesArray3[0].basicEntityId;
            entity2Id = mainEntity.entitiesArray3[1].basicEntityId;
            entity3Id = mainEntity.entitiesArray4[0].basicEntityId;
            entity4Id = mainEntity.entitiesArray4[1].basicEntityId;
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity1Id);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity2Id);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity3Id);
        }).then(entity -> {
            Assert.isNull(entity);
            return BasicEntity.findById(entity4Id);
        }).then(entity -> {
            Assert.isNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        });
    }

    // primitive arrays are wrapped in internal entity classes (like EntityStringPrimitive), regardless of metadata, these
    // entities should cascade deletions since you wouldnt want orphaned entities in the database. In order to ensure this is
    // happening in a unit test, we'll have to delve a little into the internal structure of entities since these entities arent
    // exposed to the user and are handled (synced) internally
    function testDelete_PrimitiveArray_AutoCascade(async:Async) {
        var mainEntity = createEntity("mainEntity", 111);
        mainEntity.stringArray1 = ["item 1", "item 2", "item 3"];

        var internalId1 = -1;
        var internalId2 = -1;
        var internalId3 = -1;
        mainEntity.add().then(mainEntity -> {
            Assert.equals("mainEntity", mainEntity.stringValue);
            Assert.equals(111, mainEntity.intValue);
            Assert.equals(3, mainEntity.stringArray1.length);
            Assert.equals("item 1", mainEntity.stringArray1[0]);
            Assert.equals("item 2", mainEntity.stringArray1[1]);
            Assert.equals("item 3", mainEntity.stringArray1[2]);
            @:privateAccess { // we are going to grab the ids from the internal entity array that was macro built
                internalId1 = mainEntity._stringArray1Entities[0]._string_entityId;
                internalId2 = mainEntity._stringArray1Entities[1]._string_entityId;
                internalId3 = mainEntity._stringArray1Entities[2]._string_entityId;
            }
            return mainEntity.delete();
        }).then(entity -> {
            return BasicEntity.findById(entity.basicEntityId);
        }).then(entity -> {
            Assert.isNull(entity);
            return EntityStringPrimitive.findById(internalId1);
        }).then(entity -> {
            Assert.isNull(entity);
            return EntityStringPrimitive.findById(internalId2);
        }).then(entity -> {
            Assert.isNull(entity);
            return EntityStringPrimitive.findById(internalId3);
        }).then(entity -> {
            Assert.isNull(entity);
            async.done();
        }, error -> {
            trace("ERROR", error);
        }); 
    }
}