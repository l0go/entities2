package cases;

import utest.ITest;

class TestBase implements ITest {
    private var mainStart:Float = 0;
    private var mainName:String;

    private var timeStart:Float = 0;
    private var timeName:String;

    public function new() {
    }

    private function profileStart(name:String) {
        mainStart = Sys.time();
        mainName = name;
        Sys.println(" * " + mainName);
    }

    private function profileEnd() {
        var diff = Sys.time() - mainStart;
        Sys.println("    .." + StringTools.rpad("", ".", 30) + ". " + Math.round(diff * 1000) + "ms");
    }

    private function measureStart(name:String) {
        timeStart = Sys.time();
        timeName = name;
        //Sys.println(timeName);
    }

    private function measureEnd(message:String) {
        var diff = Sys.time() - timeStart;
        Sys.println("    - " + StringTools.rpad(message, " ", 30) + ": " + Math.round(diff * 1000) + "ms");
    }
}