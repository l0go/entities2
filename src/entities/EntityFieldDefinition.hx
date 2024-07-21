package entities;

typedef EntityFieldDefinition = {
    var name:String;
    var type:EntityFieldType;
    var options:Array<EntityFieldOption>;
    @:optional var primitive:Bool;
    @:optional var primitiveType:String;
}