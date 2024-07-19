package cases.basic.entities;

import entities.IEntity;

@:exposeId
class BasicEntity implements IEntity {
    public var stringValue:String;
    public var intValue:Null<Int>;
    public var floatValue:Null<Float>;
    public var boolValue:Null<Bool>;
    public var dateValue:Date;

    public var entity1:BasicEntity = null;
    public var entity2:BasicEntity = null;

    public var entitiesArray1:Array<BasicEntity> = [];
    public var entitiesArray2:Array<BasicEntity> = [];
}