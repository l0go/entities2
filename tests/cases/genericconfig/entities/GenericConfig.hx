package cases.genericconfig.entities;

import entities.IEntity;

@:exposeId
class GenericConfig implements IEntity {
    public var name:String;
    public var stringValue:String;    
    public var type:String;
    @:cascade public var children:Array<GenericConfig>;

    public function get(path:String):Any {
        var pathParts = path.split(".");
        var ref = this;
        for (pathPart in pathParts) {
            var part = ref.findChildByName(pathPart);
            if (part == null) {
                return null;
            }
            ref = part;
        }

        if (ref == null) {
            return null;
        }

        var v:Any = switch (ref.type) {
            case "int": Std.parseInt(ref.stringValue);
            case "bool": ref.stringValue == "true";
            case "string": ref.stringValue;
            case _: ref.stringValue;
        }

        return v;
    }

    private function findChildByName(name:String):GenericConfig {
        for (child in children) {
            if (child.name == name) {
                return child;
            }
        }
        return null;
    }
}