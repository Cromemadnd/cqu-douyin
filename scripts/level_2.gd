extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var depth_layers: Array[MeshInstance3D] = [
	%LevelLayer1,
	%LevelLayer2,
	%LevelLayer3
]

var layer_depth_ranges: Array[Vector2] = []

func _ready() -> void:
	# 刚进关卡时通知音频管理器
	# 哪怕场景被重载，_ready 重新执行，SoundManager 发现是同一首歌也会直接忽略，BGM 不会断
	Musicmanager.play_bgm(Musicmanager.bgm_level_1)
	cache_layer_depth_ranges()
	update_depth_layer_visibility()

# 使用强类型数组管理所有 3D 相机
@onready var cameras: Array[Camera3D] = [
	%"2DCameraFront",
	#%"2DCameraBack",
	%"3DCamera"
]

var current_camera_index: int = 0

func _process(_delta: float) -> void:
	update_depth_layer_visibility()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") or (event is InputEventKey and event.pressed and event.keycode == KEY_TAB):
		toggle_camera()

func toggle_camera() -> void:
	# 顺次循环切换索引：0 -> 1 -> 2 -> 0
	current_camera_index = (current_camera_index + 1) % cameras.size()
	
	# 激活当前索引的相机
	cameras[current_camera_index].current = true


func cache_layer_depth_ranges() -> void:
	layer_depth_ranges.clear()
	for layer in depth_layers:
		var aabb := layer.get_aabb()
		var min_x := INF
		var max_x := -INF
		
		for x in [aabb.position.x, aabb.end.x]:
			for y in [aabb.position.y, aabb.end.y]:
				for z in [aabb.position.z, aabb.end.z]:
					var world_point := layer.global_transform * Vector3(x, y, z)
					min_x = minf(min_x, world_point.x)
					max_x = maxf(max_x, world_point.x)
		
		layer_depth_ranges.append(Vector2(min_x, max_x))


func update_depth_layer_visibility() -> void:
	if layer_depth_ranges.size() != depth_layers.size():
		return
	
	var player_x := player.global_position.x
	var player_layer_index := get_player_layer_index(player_x)
	
	for index in range(depth_layers.size()):
		depth_layers[index].visible = index >= player_layer_index


func get_player_layer_index(player_x: float) -> int:
	var closest_layer_index := 0
	var closest_distance := INF
	
	for index in range(layer_depth_ranges.size()):
		var depth_range := layer_depth_ranges[index]
		if player_x >= depth_range.x and player_x <= depth_range.y:
			return index
		
		var distance_to_layer := minf(absf(player_x - depth_range.x), absf(player_x - depth_range.y))
		if distance_to_layer < closest_distance:
			closest_distance = distance_to_layer
			closest_layer_index = index
	
	return closest_layer_index
