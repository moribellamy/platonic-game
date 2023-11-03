extends Node


func play_audio(
	source: AudioStreamPlayer2D,
	from: float = 0.0,
	scheduled_s = 0.0
):
	var player = source.duplicate()
	player.position = source.owner.position
	Utils.defer(
		scheduled_s,
		func():
			add_child(player)
			player.play(from)
			await player.finished
			player.queue_free()
	)


func show(source: Node2D, duration_s: float, scheduled_s = 0.0):
	var obj = source.duplicate()
	obj.position = source.owner.position + obj.position
	Utils.defer(
		scheduled_s,
		func():
			obj.visible = true
			add_child(obj)
	)
	Utils.defer(duration_s + scheduled_s, func(): obj.queue_free())


func _process(_delta):
	pass
	# Node.print_orphan_nodes()
