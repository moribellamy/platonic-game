extends Node


func _ready():
	get_window().size = Constants.FULL_HD
	center_window()
	print(
		"Reference Resolution: ",
		Constants.ASPECT_RATIO.x, ":", Constants.ASPECT_RATIO.y
	)
	

func _process(_delta):
	var root = get_tree().root
	if Input.is_action_just_pressed("debug_plus"):
		root.size += Constants.ASPECT_RATIO
		print(root.size)
	elif Input.is_action_just_pressed("debug_minus"):
		root.size -= Constants.ASPECT_RATIO
		print(root.size)


func center_window():
	# https://ask.godotengine.org/485/how-to-center-game-window o7
	DisplayServer.window_set_position(
		Vector2i(DisplayServer.screen_get_position())
		+ DisplayServer.screen_get_size() / 2
		- DisplayServer.window_get_size() / 2
	)

