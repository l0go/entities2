package cases.genericconfig;

import entities.EntityManager;
import cases.genericconfig.entities.GenericConfig;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.genericconfig.entities.Initializer.*;

@:timeout(10000)
class TestBasic extends TestBase {
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

    function testBasic_Simple_Single(async:Async) {
        var root = createConfig("root");

        profileStart("testBasic_Simple_Single");
        measureStart("add()");
        root.add().then(addedConfig -> {
            measureEnd("add()");

            measureStart("findById()");
            return GenericConfig.findById(addedConfig.genericConfigId);
        }).then(config -> {
            measureEnd("findById()");

            Assert.equals("root", config.name);
            Assert.equals(null, config.stringValue);
            Assert.equals(null, config.type);
            Assert.notNull(config.children);
            Assert.equals(0, config.children.length);

            profileEnd();
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_Simple_1_Level(async:Async) {
        var root = createConfig("root");
        root.children = [createConfig("child1", "value1", "int"), createConfig("child2", "value2", "bool"), createConfig("child3", "value3", "string")];

        profileStart("testBasic_Simple_1_Level");
        measureStart("add()");
        root.add().then(addedConfig -> {
            measureEnd("add()");

            measureStart("findById()");
            return GenericConfig.findById(addedConfig.genericConfigId);
        }).then(config -> {
            measureEnd("findById()");
            Assert.equals("root", config.name);
            Assert.equals(null, config.stringValue);
            Assert.equals(null, config.type);
            Assert.notNull(config.children);
            Assert.equals(3, config.children.length);

            Assert.equals("child1", config.children[0].name);
            Assert.equals("value1", config.children[0].stringValue);
            Assert.equals("int", config.children[0].type);

            Assert.equals("child2", config.children[1].name);
            Assert.equals("value2", config.children[1].stringValue);
            Assert.equals("bool", config.children[1].type);

            Assert.equals("child3", config.children[2].name);
            Assert.equals("value3", config.children[2].stringValue);
            Assert.equals("string", config.children[2].type);

            profileEnd();
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_Simple_2_Levels(async:Async) {
        var root = createComplexConfig();

        profileStart("testBasic_Simple_2_Levels");
        measureStart("add()");
        root.add().then(addedConfig -> {
            measureEnd("add()");

            measureStart("findById()");
            return GenericConfig.findById(addedConfig.genericConfigId);
        }).then(config -> {
            measureEnd("findById()");

            assertComplexConfig(config);

            profileEnd();
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasic_Get_2_Levels(async:Async) {
        var root = createComplexConfig();
        
        profileStart("testBasic_Get_2_Levels");
        measureStart("add()");
        root.add().then(addedConfig -> {
            measureEnd("add()");

            measureStart("findById()");
            return GenericConfig.findById(addedConfig.genericConfigId);
        }).then(config -> {
            measureEnd("findById()");

            assertComplexConfig(config);

            Assert.equals(1011, config.get("child1.child1_1"));
            Assert.equals(1013, config.get("child1.child1_3"));
            Assert.equals(true, config.get("child2.child2_1"));
            Assert.equals("value3_2", config.get("child3.child3_2"));
            Assert.equals("value3_4", config.get("child3.child3_4"));

            profileEnd();
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}