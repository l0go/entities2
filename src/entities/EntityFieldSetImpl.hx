package entities;

using StringTools;

#if (!macro && (entities_as_externs || (modular && !modular_host)))

extern class EntityFieldSetImpl {
    public function new(list:Array<String> = null);
    public function allow(field:String):Bool;
    public function mergeWith(other:EntityFieldSetImpl):Void;
}

#else

@:keep @:expose
class EntityFieldSetImpl {
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

    public function mergeWith(other:EntityFieldSetImpl) {
        if (other == null) {
            return;
        }
        if (other.whitelist != null) {
            for (entry in other.whitelist) {
                if (this.whitelist == null) {
                    this.whitelist = [];
                }
                if (!this.whitelist.contains(entry)) {
                    this.whitelist.push(entry);
                }
            }
        }
        if (other.blacklist != null) {
            for (entry in other.blacklist) {
                if (this.blacklist == null) {
                    this.blacklist = [];
                }
                if (!this.blacklist.contains(entry)) {
                    this.blacklist.push(entry);
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

#end