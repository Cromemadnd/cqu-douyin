extends Area3D

@onready var white_screen: ColorRect = %ColorRect
@onready var shader_material = white_screen.material

func _process(_delta: float) -> void:
	# 监听玩家按下 R 键（需要在项目设置-输入映射中配置 "reset" 动作为 R）
	if Input.is_action_just_pressed("reset"):
		trigger_reset()

func _on_body_entered(body: Node3D) -> void:
	if body == %Player:
		trigger_reset()

# 核心重载逻辑抽离出来
func trigger_reset() -> void:
	# 1. 暂停时间（让游戏世界动画、物理静止）
	Engine.time_scale = 0.0
	
	# 2. 闪烁白屏
	for _i in range(3):
		white_screen.material = null
		# 注意：因为 time_scale 变为了 0，这里必须设置 process_always = true (第四个参数)
		# 确保 Timer 在游戏暂停时也能计时
		await get_tree().create_timer(0.1, false, false, true).timeout
		white_screen.material = shader_material
		await get_tree().create_timer(0.1, false, false, true).timeout
	
	# 5. 恢复时间流速
	Engine.time_scale = 1.0
	
	# 6. 重载场景
	get_tree().reload_current_scene()
