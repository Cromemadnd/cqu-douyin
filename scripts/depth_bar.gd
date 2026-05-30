extends CanvasLayer

@export_category("交互设置")
@export var player = CharacterBody3D
@export var uppboard = 0.0
@export var lowerboard = -15.0
@export var enable : bool = true

# 节点引用
@onready var depth_bar = $Depth_bar
@onready var depth_dot = $Depth_dot
@onready var Text = $Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enable:
		var depth = -player.position.x
		depth_dot.position.y = 72 + ((360 - 72) * ((depth - lowerboard) / (uppboard - lowerboard)))
		Text.text = "%.2f 米" % depth
	else:
		depth_bar.hide()
		depth_dot.hide()
		Text.hide()
