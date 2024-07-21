package entities.primitives;

@:exposeId
@:table("_int_entity")
class EntityIntPrimitive implements IEntity {
    public var value:Int;
    public function new(value:Int = null) {
        this.value = value;
    }
}