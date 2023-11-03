class_name HitBox
extends Area2D

@export var damage = 2
@export var hurts_groups: Array[String] = []
# If once_per, then this hitbox may only hurt each hurtbox
# once during an active-cycle.
@export var once_per = false
var already_hurt: Array[HurtBox] = []

var _active_layer = Layers.from_name("hitbox")


func _init() -> void:
	collision_mask = 0
	set_active(true)


func set_active(active: bool) -> void:
	var was_active = collision_layer == _active_layer
	if was_active != active:
		already_hurt = []
	collision_layer = _active_layer if active else 0


func is_active() -> bool:
	return collision_layer == _active_layer


func matches(hurtbox: HurtBox) -> bool:
	return Utils.intersection(
		hurtbox.owner.get_groups(), hurts_groups
	).size() > 0
