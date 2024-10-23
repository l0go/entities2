package cases.refs.entities;

import entities.IEntity;

@:exposeId
class MainObject implements IEntity {
    public var name:String;
    public var objectA1:SubObjectA;
    public var objectA2:SubObjectA;

    public var arrayObjectA1:Array<SubObjectA>;
}