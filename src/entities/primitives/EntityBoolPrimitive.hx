package entities.primitives;

@:exposeId
@:table("_bool_entity")
class EntityBoolPrimitive implements IEntity {
    public var value:Bool;
    public function new(value:Bool = null) {
        this.value = value;
    }
}