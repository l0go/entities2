package entities.primitives;

@:exposeId
@:table("_float_entity")
class EntityFloatPrimitive implements IEntity {
    public var value:Float;
    public function new(value:Float = null) {
        this.value = value;
    }
}