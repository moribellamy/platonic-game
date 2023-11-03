extends Node

var gamepad_id: int = -1


func _ready():
	Input.connect("joy_connection_changed", self._on_joy_connection_changed)


func _on_joy_connection_changed(device_id, connected):
	if connected:
		gamepad_id = device_id
	elif !connected and device_id == gamepad_id:
		gamepad_id = -1


func gamepad_connected() -> bool:
	return gamepad_id != -1
