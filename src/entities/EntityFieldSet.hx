package entities;

@:forward
@:forward.new
@:forward.variance
@:forwardStatics
abstract EntityFieldSet(EntityFieldSetImpl) from EntityFieldSetImpl to EntityFieldSetImpl {
    @:op(a | b)
    public function bitwiseOr(other:EntityFieldSet):EntityFieldSet {
        var newFieldSet = new EntityFieldSet();
        @:privateAccess newFieldSet.whitelist = this.whitelist.copy();
        @:privateAccess newFieldSet.blacklist = this.blacklist.copy();
        newFieldSet.mergeWith(other);
        return newFieldSet;
    }

    @:op(a & b)
    public function bitwiseAnd(other:EntityFieldSet):EntityFieldSet {
        var newFieldSet = new EntityFieldSet();
        @:privateAccess newFieldSet.whitelist = this.whitelist.copy();
        @:privateAccess newFieldSet.blacklist = this.blacklist.copy();
        newFieldSet.mergeWith(other);
        return newFieldSet;
    }

    @:op(a + b)
    public function add(other:EntityFieldSet):EntityFieldSet {
        var newFieldSet = new EntityFieldSet();
        @:privateAccess newFieldSet.whitelist = this.whitelist.copy();
        @:privateAccess newFieldSet.blacklist = this.blacklist.copy();
        newFieldSet.mergeWith(other);
        return newFieldSet;
    }
}