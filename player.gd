extends CharacterBody3D

enum State { IDLE, RUN, JUMP }
var current_state: State = State.IDLE

@export var move_speed: float = 10.0
@export var rotate_speed: float = 3.0 
@export var jump_force: float = 5.0
@export var gravity: float = 9.8      

@onready var ground_check: RayCast3D = $RayCast3D 
@onready var sprite: AnimatedSprite3D = %PlayerSprite

func _physics_process(delta: float) -> void:
	# 1. 物理与输入处理
	apply_gravity(delta)
	var move_input = handle_rotation_and_movement(delta)
	handle_jump()
	
	move_and_slide()
	
	# 锁死 X 和 Z 轴旋转
	rotation.x = 0
	rotation.z = 0
	
	# 同步网格物体位置
	%CSGPlayer.global_transform = self.global_transform

	# 2. 状态机逻辑
	update_state()
	
	# 3. 动画与朝向处理
	tick_animation_and_flip(move_input)

# --- 物理与控制核心逻辑 ---

func apply_gravity(delta: float) -> void:
	if not is_on_floor() and not ground_check.is_colliding():
		velocity.y -= gravity * delta

func handle_rotation_and_movement(delta: float) -> float:
	var move_input := Input.get_axis("ui_right", "ui_left") 
	var rotate_input := Input.get_axis("ui_up", "ui_down") 

	# 处理旋转
	rotate_y(rotate_input * rotate_speed * delta)
		
	# 处理移动
	var forward_dir := -global_transform.basis.x
	var target_vel := forward_dir * move_input * move_speed
	
	velocity.x = target_vel.x
	velocity.z = target_vel.z
	
	return move_input

func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or ground_check.is_colliding()):
		velocity.y = jump_force

# --- 状态机与动画核心逻辑 ---

func update_state() -> void:
	# 优先判断空中状态
	if not is_on_floor() and not ground_check.is_colliding():
		current_state = State.JUMP
		return
	
	# 地面状态：计算水平速度（排除 Y 轴的影响）
	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	
	# 如果水平速度接近 0（考虑浮点数误差），哪怕按了方向键也是 IDLE
	if horizontal_velocity.length() < 0.1:
		current_state = State.IDLE
	else:
		current_state = State.RUN

func tick_animation_and_flip(move_input: float) -> void:
	# 1. 处理贴图翻转（根据按键输入判断朝向）
	# 这里的逻辑对应：按左（move_input > 0）或按右（move_input < 0）
	# 根据你原脚本的映射，如果方向反了，把这里的 > 0 改成 < 0 即可
	if move_input > 0:
		sprite.flip_h = true  # 翻转贴图
	elif move_input < 0:
		sprite.flip_h = false # 恢复默认
		
	# 2. 播放对应动画
	match current_state:
		State.IDLE:
			if sprite.animation != "idle": 
				sprite.play("idle")
		State.RUN:
			if sprite.animation != "run": 
				sprite.play("run")
		State.JUMP:
			if sprite.animation != "jump": 
				sprite.play("jump")
