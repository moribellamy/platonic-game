extends CanvasLayer

const TEXT_COLOR = Color.ORANGE

var bottom_left: Label
var bottom_right: Label
var top_right: Label
var top_right2: Label

var _render_frame = 0
var _physics_frame = 0


func _new_label(
	left: float,
	top: float
) -> Label:
	var label = Label.new()
	label.anchor_left = left
	label.anchor_top = top
	label.visible = false
	label.add_theme_color_override("font_color", TEXT_COLOR)
	return label


func _ready():
	bottom_left = _new_label(.05, .9)
	add_child(bottom_left)
	bottom_right = _new_label(.6, .9)
	add_child(bottom_right)
	top_right = _new_label(.6, .35)
	add_child(top_right)
	top_right2 = _new_label(.6, .4)
	add_child(top_right2)


func _process(_delta):
	_render_frame += 1
	top_right2.text = "Rend Frame: %d" % _render_frame


func _physics_process(_delta):
	_physics_frame += 1
	top_right.text = "Phys Frame: %d" % _physics_frame


func _set_visible(vis: bool):
	bottom_left.visible = vis
	bottom_right.visible = vis
	top_right.visible = vis
	top_right2.visible = vis


func enable_display():
	_set_visible(true)


func disable_display():
	_set_visible(false)
