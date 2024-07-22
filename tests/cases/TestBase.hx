package cases;

import utest.ITest;

class TestBase implements ITest {
    private var mainStart:Float = 0;
    private var mainName:String;

    private var timeStart:Float = 0;
    private var timeName:String;

    private static var counts:Map<String, Int> = [];
    private static var times:Map<String, Array<Float>> = [];

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

    private function measureEnd(name:String) {
        var diff = Sys.time() - timeStart;
        Sys.println("    - " + StringTools.rpad(name, " ", 30) + ": " + Math.round(diff * 1000) + "ms");
        var count = 0;
        if (counts.exists(name)) {
            count = counts.get(name);
        }
        count++;
        counts.set(name, count);

        var timeArray = [];
        if (times.exists(name)) {
            timeArray = times.get(name);
        }
        timeArray.push(diff);
        times.set(name, timeArray);
    }

    public static function displayCounts() {
        for (name in counts.keys()) {
            var count = counts.get(name);
            var timeArray = times.get(name);
            var min:Float = 0xffffff;
            var max:Float = 0;
            var sum:Float = 0;
            for (t in timeArray) {
                t *= 1000;
                if (t < min) {
                    min = t;
                }
                if (t > max) {
                    max = t;
                }
                sum += t;
            }
            var avg:Float = sum / count;
            Sys.println(StringTools.rpad(name, " ", 30) + ": count = " + count + ", min = " + Math.round(min) + ", max = " + Math.round(max) + ", avg = " + Math.round(avg));
        }
        Sys.println("");
    }
}