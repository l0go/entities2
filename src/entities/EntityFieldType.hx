package entities;

enum EntityFieldType {
    Unknown;
    Boolean;
    Number;
    Decimal;
    Text;
    Date;
    Binary;
    Entity(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}