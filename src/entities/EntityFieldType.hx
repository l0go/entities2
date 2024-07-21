package entities;

enum EntityFieldType {
    Unknown;
    Boolean;
    Number;
    Decimal;
    Text(size:Int);
    Date;
    Binary;
    Entity(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}