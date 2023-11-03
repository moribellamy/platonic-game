# https://github.com/godotengine/godot-proposals/issues/1572
extends Node

var _layers = {}


func _init():
	for i in range(0, 31, 1):
		var layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i + 1))
		if layer != "":
			_layers[layer] = pow(2, i)
	print("Layer Map: ", _layers)


func from_name(layer_name: String) -> int:
	return _layers[layer_name]
