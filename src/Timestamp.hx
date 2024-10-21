package;

abstract Timestamp(Float) from Float {
	public static function now():Timestamp {
		return Date.now().getTime();
	}
}