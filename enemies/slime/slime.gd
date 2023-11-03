class_name Slime
extends CharacterBody2D

@export var bars_ui: Bars = null

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation: AnimationPlayer = $AnimationPlayer
@onready var _hit_sound: AudioStreamPlayer2D = $Sfx/Hit
@onready var _die_sound: AudioStreamPlayer2D = $Sfx/Die
@onready var _death_explosion: GPUParticles2D = $Sfx/DeathExplosion
@onready var _hurt_particles: GPUParticles2D = $Sfx/HurtParticles

const SPEED = 30
const KNOCKBACK_AMOUNT = 700
const REVERSE_S = .3
const INVULN_S = .3
const GRAVITY = 980

var _needs_knockback = 0
var _hp = 30
var _direction = -1


func quack_is_slime():
	pass


func _physics_process(delta):
	if _hp <= 0:
		queue_free()
		return
	
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	
	_sprite.flip_h = _direction == 1
	velocity.x = SPEED * _direction
	if _needs_knockback:
		velocity.x += _needs_knockback
		_needs_knockback = 0
	
	move_and_slide()
	if is_on_wall():
		_direction *= -1

# todo file bug :)
#		Utils.defer(
#			# Seconds to execution
#			.5,
#			# Main callback
#			func():
#				LifecycleHelpers.show(
#					_death_explosion,
#					_death_explosion.lifetime
#				),
#			# Number of occurrences
#			5,
#			func():
#				print('done')
#		)


func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	var source_is_to_right: bool = hitbox.global_position.x >= global_position.x
	_needs_knockback = KNOCKBACK_AMOUNT * (-1 if source_is_to_right else 1)
	LifecycleHelpers.play_audio(_hit_sound)
	_hp -= hitbox.damage
	
	var process_material = \
		_hurt_particles.process_material as ParticleProcessMaterial
	process_material.direction.x = -abs(process_material.direction.x) \
		if source_is_to_right \
		else abs(process_material.direction.x)
	LifecycleHelpers.show(_hurt_particles, _hurt_particles.lifetime)
	
	if _hp <= 0:
		LifecycleHelpers.play_audio(_die_sound)
		LifecycleHelpers.show(_death_explosion, _death_explosion.lifetime)
		var slimes = []
		Utils.find_by_duck_type(get_tree().get_root(), "quack_is_slime", slimes)
		if slimes.size() == 0 or (slimes.size() == 1 and slimes[0] == self):
			for i in range(10):
				LifecycleHelpers.show(
					_death_explosion, _death_explosion.lifetime, .1 * i)
				LifecycleHelpers.play_audio(_die_sound, .1 * i)
			if bars_ui != null:
				bars_ui.set_message("You did it!")
		return
	
	_animation.stop()
	_animation.play("hit")
	_animation.queue("idle")


func _on_friend_sentinel_area_entered(_area):
	_direction *= -1
