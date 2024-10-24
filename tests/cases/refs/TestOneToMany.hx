package cases.refs;

import cases.refs.entities.SubSubObjectX;
import cases.refs.entities.SubObjectA;
import cases.refs.entities.MainObject;
import entities.EntityManager;
import cases.basic.entities.BasicEntity;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.refs.entities.Initializer.*;

@:timeout(10000)
class TestOneToMany extends TestBase {
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
        var main = createMainObject("main");
        var addedMain:MainObject = null;
        main.arrayObjectA1 = [createSubObject("arrayitem_A_1_1"), createSubObject("arrayitem_A_1_2"), createSubObject("arrayitem_A_1_3")];
        main.add().then(result -> {
            return MainObject.findById(result.mainObjectId);
        }).then(result -> {
            addedMain = result;
            return MainObject.count();
        }).then(objectCount -> {
            Assert.equals(1, objectCount);
            return SubObjectA.count();
        }).then(objectCount -> {
            Assert.equals(3, objectCount);
            var newArray = [addedMain.arrayObjectA1[0], addedMain.arrayObjectA1[1], addedMain.arrayObjectA1[2]];
            addedMain.arrayObjectA1 = newArray;
            return addedMain.update();
        }).then(updatedMain -> {
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_NestedSingleRef(async:Async) {
        var main = createMainObject("main");
        var addedMain:MainObject = null;
        main.objectA1 = createSubObject("sub1_1A", [
            createSubSubObjectX("X1"),
            createSubSubObjectX("X2"),
            createSubSubObjectX("X3"),
        ]);
        main.add().then(result -> {
            addedMain = result;
            return MainObject.count();
        }).then(objectCount -> {
            Assert.equals(1, objectCount);
            return SubObjectA.count();
        }).then(objectCount -> {
            Assert.equals(1, objectCount);
            return SubSubObjectX.count();
        }).then(objectCount -> {
            Assert.equals(3, objectCount);
            var newArray = [addedMain.objectA1.arrayOfXs[0], addedMain.objectA1.arrayOfXs[1], addedMain.objectA1.arrayOfXs[2]];
            addedMain.objectA1.arrayOfXs = newArray;
            return addedMain.update();
        }).then(updatedMain -> {
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_SharedRef(async:Async) {
        var main = createMainObject("main1");
        var sharedRef = createSubObject("sub1_A1");
        main.arrayObjectA1 = [sharedRef];
        main.arrayObjectA2 = [sharedRef];
        main.add().then(addedMain -> {
            Assert.equals(1, addedMain.mainObjectId);
            Assert.equals(1, addedMain.arrayObjectA1[0].subObjectAId);
            Assert.equals("sub1_A1", addedMain.arrayObjectA1[0].subObjectName);
            Assert.equals(1, addedMain.arrayObjectA2[0].subObjectAId);
            Assert.equals("sub1_A1", addedMain.arrayObjectA1[0].subObjectName);
            return SubObjectA.count();
        }).then(objectCount -> {
            Assert.equals(1, objectCount);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }    
    
}