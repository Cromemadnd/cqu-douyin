extends Node3D

@onready var player: Node3D = %Player

# 设定移动速度（每秒移动多少个单位）
# 如果你希望“3秒移动5个单位”，速度就是 5.0 / 3.0 ≈ 1.67
const SPEED: float = 1.67 

func _process(delta: float) -> void:
	if not player:
		return
		
	# 1. 计算方向：按 X 是 +1，按 Z 是 -1，都不按或同时按是 0
	var direction: float = 0.0
	
	if Input.is_key_pressed(KEY_X):
		direction += 1.0
	if Input.is_key_pressed(KEY_Z):
		direction -= 1.0
		
	# 2. 如果有方向输入，就按“速度 × 时间(delta)”匀速移动
	if direction != 0.0:
		player.position.x += direction * SPEED * delta
