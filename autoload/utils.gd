extends Node


func animation_condition(
	animation_tree: AnimationTree,
	param: String,
	condition: Variant
):
	animation_tree["parameters/conditions/" + param] = condition


func intersection(arr1: Array, arr2: Array):
	var ret = []
	for elem in arr1:
		if arr2.has(elem):
			ret.append(elem)
	return ret


func defer(schedule_s, lambda, occurrences = 1, done_callback = null):
	if occurrences <= 0:
		if done_callback != null:
			done_callback.call()
		return
	get_tree().create_timer(schedule_s).timeout.connect(
		func():
			defer(schedule_s, lambda, occurrences - 1)
			lambda.call()
	)


func sprite_size(sprite: Sprite2D) -> Vector2:
	var ret = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
	ret *= sprite.scale
	ret /= Vector2(sprite.hframes, sprite.vframes)
	return ret


func free_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func find_by_duck_type(node: Node, method_name: String, result : Array) -> void:
	if node.has_method(method_name):
		result.push_back(node)
	for child in node.get_children():
		find_by_duck_type(child, method_name, result)
