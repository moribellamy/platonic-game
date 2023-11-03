class_name HurtBox
extends Area2D

signal hurt(hitbox: HitBox)


func _init() -> void:
	collision_layer = 0
	collision_mask = Layers.from_name("hitbox")


func _ready() -> void:
	connect("area_entered", self._on_area_entered)


func _on_area_entered(hitbox) -> void:
	if hitbox.matches(self):
		if hitbox.once_per:
			if self in hitbox.already_hurt:
				return
			hitbox.already_hurt.append(self)
		hurt.emit(hitbox)

