package entities;

enum EntityFieldType {
    Unknown;
    Boolean;
    Number;
    Decimal;
    Text;
    Date;
    Binary;
    Array(type:EntityFieldType);
    Entity(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}