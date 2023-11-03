class_name PlayerAnimation
extends Node2D

var _state: PlayerAnimationState
var _locked = false

@onready var _animated_sprite: AnimatedSprite2D = %AnimatedSprite
@onready var _secondary: AnimationPlayer = %Secondary
@onready var _jump_swish_right: AnimatedSprite2D = %JumpSwishRight
@onready var _jump_swish_left: AnimatedSprite2D = %JumpSwishLeft

enum PlayerAnimationState {
	IDLE,
	RUNNING,
	ASCENDING,
	DESCENDING,
	STAGGER,
	SLASHING,
	HEAVY_LANDING
}

const UNSTICK_ANIMATIONS = [
	[
		"stagger",
		PlayerAnimationState.STAGGER,
		PlayerAnimationState.IDLE
	],
	[
		"slash",
		PlayerAnimationState.SLASHING,
		PlayerAnimationState.IDLE
	]
]

const NEEDS_LOCK = [
	PlayerAnimationState.SLASHING,
	PlayerAnimationState.STAGGER
]


func _pas_name(state: PlayerAnimationState) -> String:
	return PlayerAnimationState.keys()[state]


func _set_state(state: PlayerAnimationState) -> PlayerAnimationState:
	var old_state = _state
	_state = state
	Debug.bottom_right.text = _pas_name(old_state) + " -> " \
		+ _pas_name(_state) + (" (L)" if _locked else "")
	return old_state


func _on_animated_sprite_animation_finished():
	var anim_name = _animated_sprite.animation
	for tuple in UNSTICK_ANIMATIONS:
		if tuple[0] == anim_name and _state == tuple[1]:
			var old_state = _set_state(tuple[2])
			Debug.bottom_right.text = _pas_name(old_state) \
				+ " -> " + _pas_name(_state) + " (F)"
			break
	_locked = false


func _ready():
	_jump_swish_right.visible = false
	_jump_swish_left.visible = false
	_animated_sprite.play("idle")
	_secondary.play("RESET")


func _process(_delta):
	if _locked:
		return
	
	match _state:
		PlayerAnimationState.IDLE:
			_animated_sprite.play("idle")
		PlayerAnimationState.RUNNING:
			_animated_sprite.play("run")
		PlayerAnimationState.ASCENDING:
			_animated_sprite.play("jump")
		PlayerAnimationState.DESCENDING:
			_animated_sprite.play("descend")
		PlayerAnimationState.STAGGER:
			_animated_sprite.play("stagger")
		PlayerAnimationState.SLASHING:
			_animated_sprite.play("slash")
	
	if _state in NEEDS_LOCK:
		_locked = true


func flip_h(flip: bool):
	_animated_sprite.flip_h = flip


func flash():
	_secondary.stop()
	_secondary.play("flash")
	_secondary.queue("RESET")


# Each of these primary animator transition methods returns 0 if
# it cannot play immediately. Otherwise, it returns the length of the
# corresponding animation.
func idle():
	_set_state(PlayerAnimationState.IDLE)


func jump():
	_set_state(PlayerAnimationState.ASCENDING)


func jump_swish():
	var swish_anim = _jump_swish_left if _animated_sprite.flip_h \
		else _jump_swish_right
	swish_anim.visible = true
	swish_anim.play()
	swish_anim.animation_finished.connect(
		func():
			swish_anim.visible = false
	)


func fall():
	_set_state(PlayerAnimationState.DESCENDING)


func run():
	_set_state(PlayerAnimationState.RUNNING)


func stagger():
	_set_state(PlayerAnimationState.STAGGER)


func slash():
	_set_state(PlayerAnimationState.SLASHING)

