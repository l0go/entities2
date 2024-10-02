package cases.genericconfig;

import entities.EntityManager;
import cases.genericconfig.entities.GenericConfig;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.genericconfig.entities.Initializer.*;

@:timeout(10000)
class TestDelete extends TestBase {
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

    function testBasic_Additions_Removals_Updates(async:Async) {
        var root = createComplexConfig();

        profileStart("testBasic_Simple_Single");
        measureStart("add()");
        root.add().then(addedConfig -> {
            measureEnd("add()");

            measureStart("findById()");
            return GenericConfig.findById(addedConfig.genericConfigId);
        }).then(config -> {
            measureEnd("findById()");

            assertComplexConfig(config);

            while (config.children.length > 0) {
                config.children.remove(config.children[0]);
            }

            measureStart("update()");
            return config.update();
        }).then(config -> {
            return GenericConfig.findById(config.genericConfigId);
        }).then(config -> {
            measureEnd("update()");

            Assert.equals(0, config.children.length);

            profileEnd();
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}