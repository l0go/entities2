package entities.macros.helpers;

#if macro

import haxe.macro.Expr;

@:forward.new
@:forward
@:access(CodeBuilder)
abstract CodeBuilderWrapper(CodeBuilder) {
	@:op(A + B)
	public static function add(lhs:CodeBuilderWrapper, rhs:CodeBuilderWrapper):CodeBuilderWrapper {
		lhs.add(rhs.expr);
		return lhs;
	}

	@:from
	public static function fromExpr(expr:Expr):CodeBuilderWrapper {
		var w = new CodeBuilderWrapper();
		w.expr = expr;
		return w;
	}
}

#end