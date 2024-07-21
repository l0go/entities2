package entities.primitives;

@:exposeId
@:table("_string_entity")
class EntityStringPrimitive implements IEntity {
    public var value:String;
    public function new(value:String = null) {
        this.value = value;
    }
}