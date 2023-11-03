class_name Player
extends CharacterBody2D

@export var bars_ui: Bars = null

enum PlayerState {
	IDLE,
	RUNNING,
	LIFTOFF,
	ASCENDING,
	WANTS_DESCENT,
	DESCENDING,
	NEEDS_KNOCKBACK,
	KNOCKBACK,
	SLASHING
}

const SPEED = 200.0
const AIR_SPEED = 180.0

const GRAVITY = 680
const JUMP_VELOCITY = -400
const MIN_JUMP_HEIGHT = 45
const HEAVY_LAND_DISTANCE = 200
const JUMP_CANCEL_FORCE = 1200
const TERMINAL_VELOCITY = 400

const KNOCKBACK_FORCE = 260
const KNOCKBACK_DAMPENING = 500

const MIN_INVULN_S = .5
const SLASH_HITBOX_DURATION_S = .2

@onready var _slash_hitbox: HitBox = %SlashHitbox
@onready var _hurtbox: HurtBox = %HurtBox
@onready var _initial_slash_hitbox_position = _slash_hitbox.position
@onready var _player_animation: PlayerAnimation = %PlayerAnimation
@onready var _whoosh = $Sfx/Whoosh
@onready var _jump: AudioStreamPlayer2D = $Sfx/Jump
@onready var _thud: AudioStreamPlayer2D = $Sfx/Thud
@onready var _tink: AudioStreamPlayer2D = $Sfx/Tink

var _state: PlayerState
var _jump_crest_y = -1
var _liftoff_y = -1
var _knockback_source: Vector2 = Vector2.ZERO
var _hp = 12
var _max_hp = 12
var _invuln = false
var _max_jumps = 2
var _current_jump = 0
var _staggering = false
var _allowed_to_exit_knockback = true


func _ready():
	Debug.enable_display()
	_slash_hitbox.set_active(false)
	if bars_ui:
		bars_ui.set_hp(_hp, _max_hp)
	_jump_crest_y = global_position.y
	_set_state(PlayerState.IDLE)


func _gravity_pull(delta):
	velocity.y = move_toward(
		velocity.y, TERMINAL_VELOCITY, GRAVITY * delta
	)


func _ps_name(state: PlayerState) -> String:
	return PlayerState.keys()[state]


func _set_state(new_state: PlayerState) -> PlayerState:
	var old_state = _state
	_state = new_state
	Debug.bottom_left.text = _ps_name(old_state) + " -> " + _ps_name(_state)
	return old_state


func _process_idle(_delta):
	_jump_crest_y = global_position.y
	_current_jump = 0
	velocity = Vector2.ZERO
	if not is_on_floor():
		_set_state(PlayerState.DESCENDING)
		_player_animation.fall()
	elif Input.is_action_just_pressed("attack"):
		_set_state(PlayerState.SLASHING)
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		_set_state(PlayerState.LIFTOFF)
		_player_animation.jump()
	elif Input.get_axis("left", "right"):
		_set_state(PlayerState.RUNNING)
		_player_animation.run()


func _process_running(_delta):
	_current_jump = 0
	var direction = Input.get_axis("left", "right")
	if not is_on_floor():
		_set_state(PlayerState.DESCENDING)
		_player_animation.fall()
	elif Input.is_action_just_pressed("attack"):
		_set_state(PlayerState.SLASHING)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_set_state(PlayerState.LIFTOFF)
	elif direction:
		velocity.x = direction * SPEED
		_flip(direction > 0)
	else:
		_set_state(PlayerState.IDLE)
		_player_animation.idle()


func _process_liftoff(_delta):
	_jump.play()
	_liftoff_y = global_position.y
	velocity.y = JUMP_VELOCITY
	_set_state(PlayerState.ASCENDING)
	_current_jump += 1
	_player_animation.jump()
	
	
func _fall_and_air_steer(delta) -> bool:
	_gravity_pull(delta)
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * AIR_SPEED
	if direction != 0:
		_flip(direction > 0)
		return true
	return false


func _process_ascending(delta):
	_fall_and_air_steer(delta)
	_jump_crest_y = global_position.y
	if Input.is_action_just_released("jump"):
		_set_state(PlayerState.WANTS_DESCENT)
	elif velocity.y > 0:
		_set_state(PlayerState.DESCENDING)
		_player_animation.fall()


## Returns whether a midair jump was successfully enqueued.
## Success can only happen if the player asks for a jump
## (via the controls) and also the avatar has enough jumps
## in the bank.
func _maybe_midair_jump() -> bool:
	if Input.is_action_just_pressed("jump") and _current_jump < _max_jumps:
		_player_animation.jump_swish()
		_set_state(PlayerState.LIFTOFF)
		return true
	return false


func _process_wants_descent(delta):
	_fall_and_air_steer(delta)
	_gravity_pull(delta)
	if _maybe_midair_jump():
		pass
	elif velocity.y >= 0:
		_set_state(PlayerState.DESCENDING)
		_player_animation.fall()
	elif _liftoff_y - global_position.y > MIN_JUMP_HEIGHT:
		velocity.y = move_toward(velocity.y, 0, JUMP_CANCEL_FORCE * delta)


func _process_descending(delta):
	if is_on_floor():
		_set_state(PlayerState.IDLE)
		_player_animation.idle()
		if global_position.y - _jump_crest_y > HEAVY_LAND_DISTANCE:
			_thud.play()
	else:
		if _maybe_midair_jump():
			pass
		else:
			var direction = Input.get_axis("left", "right")
			velocity.x = direction * SPEED
			if direction != 0:
				_flip(direction > 0)
			_gravity_pull(delta)


func _process_needs_knockback(_delta):
	velocity = Vector2(
		1 if global_position.x > _knockback_source.x else -1,
		-.5
	).normalized() * KNOCKBACK_FORCE
	_set_state(PlayerState.KNOCKBACK)


func _process_knockback(delta):
	if !_staggering:
		_staggering = true
		_allowed_to_exit_knockback = false
		_player_animation.stagger()
		Utils.defer(.1, func(): _allowed_to_exit_knockback = true)
	## Dampen the motion. Feels like air resistance maybe?
	velocity.x = move_toward(velocity.x, 0, KNOCKBACK_DAMPENING * delta)
	_gravity_pull(delta)
	if is_on_floor() and _allowed_to_exit_knockback:
		_staggering = false
		_set_state(PlayerState.IDLE)


func _flip(facing_right: bool):
	_player_animation.flip_h(!facing_right)
	var signum = 1 if facing_right else -1
	_slash_hitbox.position.x = _initial_slash_hitbox_position.x * signum


func _process_slashing(_delta):
	if !_slash_hitbox.is_active():
		# Since this state is short lived, we can trigger an animation here
		# without flooding the animation machine.
		_player_animation.slash()
		_slash_hitbox.set_active(true)
		_whoosh.play()
		Utils.defer(
			SLASH_HITBOX_DURATION_S,
			func():
				_slash_hitbox.set_active(false)
		)
	_set_state(PlayerState.IDLE)


func _physics_process(delta):
	match _state:
		PlayerState.IDLE:
			_process_idle(delta)
		PlayerState.RUNNING:
			_process_running(delta)
		PlayerState.LIFTOFF:
			_process_liftoff(delta)
		PlayerState.ASCENDING:
			_process_ascending(delta)
		PlayerState.WANTS_DESCENT:
			_process_wants_descent(delta)
		PlayerState.DESCENDING:
			_process_descending(delta)
		PlayerState.NEEDS_KNOCKBACK:
			_process_needs_knockback(delta)
		PlayerState.KNOCKBACK:
			_process_knockback(delta)
		PlayerState.SLASHING:
			_process_slashing(delta)
	move_and_slide()


func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	if _invuln:
		return
	
	_hp = move_toward(_hp, 0, hitbox.damage)
	bars_ui.set_hp(_hp, _max_hp)
	if _hp == 0:
		# TODO die
		return
	_invuln = true
	_player_animation.flash()
	Utils.defer(
		MIN_INVULN_S,
		func():
			_invuln = false
			for area in _hurtbox.get_overlapping_areas():
				if area is HitBox:
					# TODO: a better way?
					_hurtbox._on_area_entered(area)
	)
	
	_tink.play()
	_knockback_source = hitbox.global_position
	_set_state(PlayerState.NEEDS_KNOCKBACK)
