extends Node3D

@export_category("交互设置")
@export var player = CharacterBody3D
@export var uppboard = 0
@export var lowerboard = -15
@export var enable : bool = true

# 节点引用
@onready var depth_bar = $Depth_bar
@onready var depth_dot = $Depth_dot
@onready var Text = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enable:
		var depth = player.position.x
		depth_dot.position.y = 655 - ((655-348) * ((uppboard - depth) / (uppboard - lowerboard)))
		Text.text = depth + "米"
	else:
		depth_bar.hide()
		depth_dot.hide()
		Text.hide()
