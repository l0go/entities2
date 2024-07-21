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
    @:cascade(deletions)
    public var entity3:BasicEntity = null;
    @:cascade(deletions)
    public var entity4:BasicEntity = null;

    public var entitiesArray1:Array<BasicEntity> = [];
    public var entitiesArray2:Array<BasicEntity> = [];
    @:cascade(deletions)
    public var entitiesArray3:Array<BasicEntity> = [];
    @:cascade(deletions)
    public var entitiesArray4:Array<BasicEntity> = [];

    public var stringArray1:Array<String> = [];
    public var stringArray2:Array<String> = [];

    public var boolArray1:Array<Bool> = [];
    public var boolArray2:Array<Bool> = [];

    public var intArray1:Array<Int> = [];
    public var intArray2:Array<Int> = [];

    public var floatArray1:Array<Float> = [];
    public var floatArray2:Array<Float> = [];

    public var dateArray1:Array<Date> = [];
    public var dateArray2:Array<Date> = [];

    @:size(20, truncate)
    public var limitedStringValue:String;
    @:size(20)
    public var limitedStringValueNoTruncate:String;
}