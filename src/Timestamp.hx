package;

abstract Timestamp(Float) to Float from Float {
	public static function now():Timestamp {
		return Date.now().getTime();
	}
}