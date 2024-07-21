package entities.primitives;

@:exposeId
@:table("_date_entity")
class EntityDatePrimitive implements IEntity {
    public var value:Date;
    public function new(value:Date = null) {
        this.value = value;
    }
}