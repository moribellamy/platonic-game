class_name Bars
extends CanvasLayer

const HEART_PADDING_PX = 3

@onready var _hearts: Node2D = %HeartStart
@onready var _four_heart: Sprite2D = %FourHeart
@onready var _three_heart: Sprite2D = %ThreeHeart
@onready var _two_heart: Sprite2D = %TwoHeart
@onready var _one_heart: Sprite2D = %OneHeart
@onready var _zero_heart: Sprite2D = %ZeroHeart
@onready var _message: Label = %Message

@onready var _dict = {
	0: _zero_heart,
	1: _one_heart,
	2: _two_heart,
	3: _three_heart,
	4: _four_heart
}

var _current_hp: int = 0
var _max_hp: int = 0


func set_message(text: String):
	_message.text = text
	_message.visible = true


func set_hp(current: int, full: int):
	if current != _current_hp or full != _max_hp:
		_current_hp = current
		_max_hp = full
		_set_hearts(current, full)
		print(current, "/", full)


func _append_heart(heart_idx: int):
	var heart = _dict[heart_idx].duplicate()
	heart.visible = true
	heart.position = Vector2.ZERO
	var num_hearts = _hearts.get_child_count()
	if num_hearts != 0:
		var last = _hearts.get_children()[num_hearts - 1]
		heart.position.x = last.position.x + \
			Utils.sprite_size(last).x + HEART_PADDING_PX
	_hearts.add_child(heart)


func _set_hearts(current: int, full: int):
	Utils.free_children(_hearts)
	var num_full = current / 4

	for i in range(num_full):
		_append_heart(4)
	
	var partial = current % 4
	if partial != 0:
		_append_heart(partial)
	
	var the_rest = (full - current) / 4
	for i in range(the_rest):
		_append_heart(0)

