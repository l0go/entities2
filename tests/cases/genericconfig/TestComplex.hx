package cases.genericconfig;

import entities.EntityManager;
import cases.genericconfig.entities.GenericConfig;
import utest.Assert;
import utest.Async;
import db.IDatabase;
import cases.genericconfig.entities.Initializer.*;

@:timeout(10000)
class TestComplex extends TestBase {
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

            config.children[0].children[0].stringValue = "some update value 1";
            config.children[0].children[2].stringValue = "some update value 2";
            config.children[0].children.push(createConfig("new1_1", "new value 1"));

            config.children[1].children[0].stringValue = "some update value 3";
            config.children[1].children.remove(config.children[1].children[1]);
            config.children[1].children.push(createConfig("new2_1", [
                createConfig("new2_1_1", "new value 2_1_1"),
                createConfig("new2_1_2", "new value 2_1_2"),
                createConfig("new2_1_3", "new value 2_1_3"),
            ]));

            config.children[2].children.remove(config.children[2].children[1]);
            config.children[2].children.remove(config.children[2].children[2]);

            config.children.push(createConfig("new", [
                createConfig("new_new1", "new value 5"),
                createConfig("new_new2", "new value 6"),
                createConfig("new_new3", "new value 7")
            ]));

            measureStart("update()");
            return config.update();
        }).then(config -> {
            return GenericConfig.findById(config.genericConfigId);
        }).then(config -> {
            measureEnd("update()");

            Assert.equals("root", config.name);
            Assert.equals(null, config.stringValue);
            Assert.equals(null, config.type);
            Assert.notNull(config.children);
            Assert.equals(4, config.children.length);
    
            Assert.equals("child1", config.children[0].name);
            Assert.equals("101", config.children[0].stringValue);
            Assert.equals("int", config.children[0].type);
            Assert.equals(4, config.children[0].children.length);
            Assert.equals("child1_1", config.children[0].children[0].name);
            Assert.equals("child1_2", config.children[0].children[1].name);
            Assert.equals("child1_3", config.children[0].children[2].name);
            Assert.equals("new1_1", config.children[0].children[3].name);
            Assert.equals("some update value 1", config.children[0].children[0].stringValue);
            Assert.equals("1012", config.children[0].children[1].stringValue);
            Assert.equals("some update value 2", config.children[0].children[2].stringValue);
            Assert.equals("new value 1", config.children[0].children[3].stringValue);
    
            Assert.equals("child2", config.children[1].name);
            Assert.equals("value2", config.children[1].stringValue);
            Assert.equals("bool", config.children[1].type);
            Assert.equals(2, config.children[1].children.length);
            Assert.equals("child2_1", config.children[1].children[0].name);
            Assert.equals("new2_1", config.children[1].children[1].name);
            Assert.equals("some update value 3", config.children[1].children[0].stringValue);
            Assert.equals(null, config.children[1].children[1].stringValue);

            Assert.equals(3, config.children[1].children[1].children.length);
            
            Assert.equals("child3", config.children[2].name);
            Assert.equals("value3", config.children[2].stringValue);
            Assert.equals("string", config.children[2].type);
            Assert.equals(2, config.children[2].children.length);
            Assert.equals("child3_1", config.children[2].children[0].name);
            Assert.equals("child3_3", config.children[2].children[1].name);
            Assert.equals("value3_1", config.children[2].children[0].stringValue);
            Assert.equals("value3_3", config.children[2].children[1].stringValue);
    
            Assert.equals("new", config.children[3].name);
            Assert.equals(null, config.children[3].stringValue);
            Assert.equals(null, config.children[3].type);
            Assert.equals(3, config.children[3].children.length);
            Assert.equals("new_new1", config.children[3].children[0].name);
            Assert.equals("new_new2", config.children[3].children[1].name);
            Assert.equals("new_new3", config.children[3].children[2].name);
            Assert.equals("new value 5", config.children[3].children[0].stringValue);
            Assert.equals("new value 6", config.children[3].children[1].stringValue);
            Assert.equals("new value 7", config.children[3].children[2].stringValue);

            profileEnd();
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}