extends Node

# Don't change these.
var REFERENCE_RESOLUTION = Vector2i(640, 360)
var FULL_HD = REFERENCE_RESOLUTION * 4
var _denominator = _gcd(REFERENCE_RESOLUTION.x, REFERENCE_RESOLUTION.y)
var ASPECT_RATIO = REFERENCE_RESOLUTION / _denominator


func _gcd(a: int, b: int) -> int:
	return a if b == 0 else _gcd(b, a % b)
