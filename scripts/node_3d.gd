extends Node

# 使用强类型数组管理所有 3D 相机
@onready var cameras: Array[Camera3D] = [
	%"2DCameraFront",
	#%"2DCameraBack",
	%"3DCamera"
]

var current_camera_index: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") or (event is InputEventKey and event.pressed and event.keycode == KEY_TAB):
		toggle_camera()

func toggle_camera() -> void:
	# 顺次循环切换索引：0 -> 1 -> 2 -> 0
	current_camera_index = (current_camera_index + 1) % cameras.size()
	
	# 激活当前索引的相机
	cameras[current_camera_index].current = true
