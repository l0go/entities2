package entities;

using StringTools;

class EntityFieldSet {
    var whitelist:Array<String> = [];
    var blacklist:Array<String> = [];
    public function new(list:Array<String> = null) {
        if (list != null) {
            for (item in list) {
                item = item.trim();
                if (item.length == 0) {
                    continue;
                }

                if (item.startsWith("!")) {
                    blacklist.push(item.substring(1));
                } else {
                    whitelist.push(item);
                }
            }
        }
    }

    public function allow(field:String):Bool {
        if (whitelist.length == 0 && blacklist.length == 0) {
            return true;
        }

        if (blacklist.length != 0) {
            if (blacklist.contains(field)) {
                return false;
            }
        }

        if (whitelist.length != 0) {
            if (whitelist.contains(field)) {
                return true;
            } else {
                return false;
            }
        }

        return true;
    }
}