package cases.basic;

import promises.PromiseUtils;
import cases.basic.entities.BasicEntity;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.basic.entities.Initializer.*;

@:timeout(10000)
class TestLimit extends TestBase {
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

    function testLimit(async:Async) {
        var someEntity1 = createEntity("someEntity1", 111);
        var someEntity2 = createEntity("someEntity2", 222);
        var someEntity3 = createEntity("someEntity3", 333);
        PromiseUtils.runSequentially([
            someEntity1.update.bind(),
            someEntity2.update.bind(),
            someEntity3.update.bind()
        ]).then(_ -> {
            return BasicEntity.findAll(); // no maxResults
        }).then(entities -> {
            Assert.equals(3, entities.length);
            return BasicEntity.findAll(2); // 2 maxResults
        }).then(entities -> {
            Assert.equals(2, entities.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}