package cases.refs.entities;

import entities.IEntity;

@:exposeId
class SubObjectA implements IEntity {
    public var subObjectName:String;
    public var arrayOfXs:Array<SubSubObjectX>;
}