class_name GamepadSignage
extends Node2D
## Used to teach the player which button does which action.
##
## This game object seeks two Sprite2D children. The first is an icon
## to show in the case of keyboard/mouse controls. The second is an icon
## to show in the case of a controller (hopefully XBox).


@export var message: String
@export var trigger_distance = 300

@export var pause_until_press = false

@onready var label: Label = $NinePatchRect/Label
@onready var rect: NinePatchRect = $NinePatchRect
@onready var sign_sprite: Sprite2D = $SignSprite

var target: Node2D
var keyboard_mouse_glyph: Sprite2D
var controller_glyph: Sprite2D


func _ready():
	# HACK
	process_mode = Node.PROCESS_MODE_ALWAYS
	if pause_until_press:
		sign_sprite.visible = false
	
	var players = get_tree().get_nodes_in_group("player")
	if players:
		target = players[0]
	rect.visible = false
	label.text = message
	rect.z_index = 9
	
	var given_sprites = []
	for child in get_children():
		if child is Sprite2D and child != $SignSprite:
			given_sprites.append(child)
	
	if given_sprites.size() > 0:
		keyboard_mouse_glyph = given_sprites[0]
		keyboard_mouse_glyph.visible = false
		keyboard_mouse_glyph.z_index = 10
		if given_sprites.size() > 1:
			controller_glyph = given_sprites[1]
			controller_glyph.visible = false
			controller_glyph.z_index = 10


func _process(_delta):
	# HACK: the pause_until feature don't belong here.
	if pause_until_press:
		get_tree().paused = true
	
	if Input.is_action_just_pressed("attack") and pause_until_press:
		pause_until_press = false
		get_tree().paused = false
	
	if !target:
		return
	
	var can_see = target.global_position.distance_squared_to(
		global_position
	) < trigger_distance
	
	rect.visible = can_see
	if InputHelpers.gamepad_connected() and controller_glyph:
		controller_glyph.visible = can_see
	elif keyboard_mouse_glyph:
		keyboard_mouse_glyph.visible = can_see
