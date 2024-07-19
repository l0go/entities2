package;

import db.DatabaseFactory;
import db.IDatabase;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;
import cases.basic.*;

class TestAll {
    public static var databaseBackend:String = null;

    public static function main() {
        var runner = new Runner();

        databaseBackend = Sys.getEnv("DB_CORE_BACKEND");
        if (databaseBackend == null) {
            databaseBackend = "sqlite";
        }

        trace("DB_CORE_BACKEND: " + databaseBackend);
        if (databaseBackend == "sqlite") {
            addBasicCases(runner, sqlite("basic"));
        } else if (databaseBackend == "mysql") {
            trace("MYSQL_HOST: " + Sys.getEnv("MYSQL_HOST"));
            trace("MYSQL_USER: " + Sys.getEnv("MYSQL_USER"));
            trace("MYSQL_PASS: " + Sys.getEnv("MYSQL_PASS"));
            
            addBasicCases(runner, mysql("basic"));
        }

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }

    private static function addBasicCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestBasic(db));
        runner.addCase(new TestAdd(db));
    }

    private static function sqlite(name:String):IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.SQLITE, {
            filename: name + ".db"
        });
    }

    private static function mysql(name):IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.MYSQL, {
            database: name,
            host: Sys.getEnv("MYSQL_HOST"),
            user: Sys.getEnv("MYSQL_USER"),
            pass: Sys.getEnv("MYSQL_PASS")
        });
    }
}