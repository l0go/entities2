package entities;

@:forward
@:forward.new
@:forward.variance
@:forwardStatics
abstract EntityFieldSet(EntityFieldSetImpl) from EntityFieldSetImpl to EntityFieldSetImpl {
    @:op(a | b)
    public function bitwiseOr(other:EntityFieldSet):EntityFieldSet {
        this.mergeWith(other);
        return this;
    }

    @:op(a & b)
    public function bitwiseAnd(other:EntityFieldSet):EntityFieldSet {
        this.mergeWith(other);
        return this;
    }

    @:op(a + b)
    public function add(other:EntityFieldSet):EntityFieldSet {
        this.mergeWith(other);
        return this;
    }
}