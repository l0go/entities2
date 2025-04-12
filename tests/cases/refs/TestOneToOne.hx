package cases.refs;

import cases.refs.entities.SubObjectA;
import entities.EntityManager;
import cases.basic.entities.BasicEntity;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.refs.entities.Initializer.*;

@:timeout(10000)
class TestOneToOne extends TestBase {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
        this.db = db;
    }
    
    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info]
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

    function testBasic_SingleRef(async:Async) {
        var main = createMainObject("main1");
        main.objectA1 = createSubObject("sub1_A1");
        main.objectA2 = createSubObject("sub1_A2");
        main.add().then(addedMain -> {
            Assert.equals(1, addedMain.mainObjectId);
            Assert.equals(1, addedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A1", addedMain.objectA1.subObjectName);
            Assert.equals(2, addedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A2", addedMain.objectA2.subObjectName);

            var newObjectA1 = createSubObject("new1_A1");
            addedMain.objectA1 = newObjectA1;
            return addedMain.update();
        }).then(updatedMain -> {
            Assert.equals(1, updatedMain.mainObjectId);
            Assert.equals(1, updatedMain.objectA1.subObjectAId);
            Assert.equals("new1_A1", updatedMain.objectA1.subObjectName);
            Assert.equals(2, updatedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A2", updatedMain.objectA2.subObjectName);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_DoubleRef(async:Async) {
        var main = createMainObject("main1");
        main.objectA1 = createSubObject("sub1_A1");
        main.objectA2 = createSubObject("sub1_A2");
        main.add().then(addedMain -> {
            Assert.equals(1, addedMain.mainObjectId);
            Assert.equals(1, addedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A1", addedMain.objectA1.subObjectName);
            Assert.equals(2, addedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A2", addedMain.objectA2.subObjectName);

            var newObjectA1 = createSubObject("new1_A1");
            addedMain.objectA1 = newObjectA1;
            var newObjectA2 = createSubObject("new1_A2");
            addedMain.objectA2 = newObjectA2;
            return addedMain.update();
        }).then(updatedMain -> {
            Assert.equals(1, updatedMain.mainObjectId);
            Assert.equals(1, updatedMain.objectA1.subObjectAId);
            Assert.equals("new1_A1", updatedMain.objectA1.subObjectName);
            Assert.equals(2, updatedMain.objectA2.subObjectAId);
            Assert.equals("new1_A2", updatedMain.objectA2.subObjectName);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_SingleRef_Overwrite(async:Async) {
        var main = createMainObject("main1");
        main.objectA1 = createSubObject("sub1_A1");
        main.objectA2 = createSubObject("sub1_A2");
        main.add().then(addedMain -> {
            Assert.equals(1, addedMain.mainObjectId);
            Assert.equals(1, addedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A1", addedMain.objectA1.subObjectName);
            Assert.equals(2, addedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A2", addedMain.objectA2.subObjectName);

            addedMain.objectA1 = addedMain.objectA2;
            return addedMain.update();
        }).then(updatedMain -> {
            Assert.equals(1, updatedMain.mainObjectId);
            Assert.equals(2, updatedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A2", updatedMain.objectA1.subObjectName);
            Assert.equals(2, updatedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A2", updatedMain.objectA2.subObjectName);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_SingleRef_ReRef(async:Async) {
        var main = createMainObject("main1");
        main.objectA1 = createSubObject("sub1_A1");
        main.objectA2 = createSubObject("sub1_A2");
        main.objectA1 = createSubObject("sub1_A3");
        main.objectA2 = createSubObject("sub1_A4");
        main.add().then(addedMain -> {
            Assert.equals(1, addedMain.mainObjectId);
            Assert.equals(1, addedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A3", addedMain.objectA1.subObjectName);
            Assert.equals(2, addedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A4", addedMain.objectA2.subObjectName);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_SingleRef_RefAlreadyExists(async:Async) {
        var sub1_A2 = createSubObject("sub1_A2");
        sub1_A2.add().then(addedEntity -> {
            var main = createMainObject("main1");
            main.objectA1 = createSubObject("sub1_A1");
            main.objectA2 = createSubObject("sub1_A2-nope");
            main.objectA2 = addedEntity;
            return main.update();
        }).then(updatedMain -> {
            Assert.equals(1, updatedMain.mainObjectId);
            Assert.equals(2, updatedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A1", updatedMain.objectA1.subObjectName);
            Assert.equals(1, updatedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A2", updatedMain.objectA2.subObjectName);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }    


    function testBasic_SingleRef_RefAlreadyExists_UpdateRef(async:Async) {
        var sub1_A2 = createSubObject("sub1_A2");
        sub1_A2.add().then(addedEntity -> {
            var main = createMainObject("main1");
            main.objectA1 = createSubObject("sub1_A1");
            main.objectA2 = createSubObject("sub1_A2-nope");
            main.objectA2 = addedEntity;
            addedEntity.subObjectName = "new_name";
            return main.update();
        }).then(updatedMain -> {
            Assert.equals(1, updatedMain.mainObjectId);
            Assert.equals(2, updatedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A1", updatedMain.objectA1.subObjectName);
            Assert.equals(1, updatedMain.objectA2.subObjectAId);
            Assert.equals("new_name", updatedMain.objectA2.subObjectName);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }    

    function testBasic_SharedRef(async:Async) {
        var main = createMainObject("main1");
        var sharedRef = createSubObject("sub1_A1");
        main.objectA1 = sharedRef;
        main.objectA2 = sharedRef;
        main.add().then(addedMain -> {
            Assert.equals(1, addedMain.mainObjectId);
            Assert.equals(1, addedMain.objectA1.subObjectAId);
            Assert.equals("sub1_A1", addedMain.objectA1.subObjectName);
            Assert.equals(1, addedMain.objectA2.subObjectAId);
            Assert.equals("sub1_A1", addedMain.objectA2.subObjectName);
            return SubObjectA.count();
        }).then(objectCount -> {
            #if php
            Assert.equals(1, Std.parseInt(Std.string(objectCount)));
            #else
            Assert.equals(1, objectCount);
            #end
            async.done();
        }, error -> {
            trace("error", error);
        });
    }    
}