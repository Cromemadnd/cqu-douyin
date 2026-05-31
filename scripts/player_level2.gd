extends CharacterBody3D

enum State { IDLE, RUN, JUMP }
var current_state: State = State.IDLE

@export var move_speed: float = 10.0
@export var rotate_speed: float = 3.0 
@export var jump_force: float = 7.0
@export var gravity: float = 9.8      

@onready var ground_check: RayCast3D = $RayCast3D 
@onready var sprite: AnimatedSprite3D = %PlayerSprite

# 全局记录当前帧的移动输入，供状态机精准判断
var last_move_input: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. 物理与输入处理
	apply_gravity(delta)
	
	# 从源头清洗速度，防止空中撞薄墙产生物理滑行和扭转
	last_move_input = handle_rotation_and_movement(delta)
	handle_jump()
	
	# 执行物理移动
	move_and_slide()
	
	# 强行锁死 X 和 Z 轴旋转，确保渲染前绝对摆正
	rotation.x = 0
	#rotation.y = PI / 2
	rotation.z = 0
	
	# 同步网格物体位置
	%CSGPlayer.global_transform = self.global_transform

	# 2. 状态机逻辑（修复了卡墙时速度为0导致切回IDLE的Bug）
	update_state()
	
	# 3. 动画与朝向处理
	tick_animation_and_flip(last_move_input)


# ==================== 物理与控制核心逻辑 ====================

func apply_gravity(delta: float) -> void:
	# 结合内置地面检测与 RayCast，确保完美着地判断
	if not is_on_floor() and not ground_check.is_colliding():
		velocity.y -= gravity * delta


func handle_rotation_and_movement(delta: float) -> float:
	var move_input := Input.get_axis("ui_right", "ui_left") 
	var depth_input := Input.get_axis("ui_x", "ui_z") 
	var rotate_input := Input.get_axis("ui_q", "ui_e") 

	# 处理 Y 轴自主旋转
	rotate_y(rotate_input * rotate_speed * delta)
	
	# 计算基于当前朝向的原始期望移动速度
	var forward_dir := -global_transform.basis.x
	var target_vel := forward_dir * move_input * move_speed
	target_vel += -global_transform.basis.z * depth_input * move_speed
	
	# === 【核心根治点】 ===
	# 如果在空中且已经贴墙，直接在赋值前把冲墙的速度分量削掉
	if not is_on_floor() and is_on_wall():
		var wall_normal = get_wall_normal()
		# 检查玩家输入的方向是否在往墙上推
		if target_vel.dot(wall_normal) < 0:
			# 顺着墙面法线投影速度，消除向墙内的挤压压力，从根本上杜绝滑行抖动
			target_vel = target_vel.slide(wall_normal)
	
	# 安全地将清洗后的水平速度应用到 velocity
	velocity.x = target_vel.x
	velocity.z = target_vel.z
	
	return move_input


func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or ground_check.is_colliding()):
		velocity.y = jump_force


# ==================== 状态机与动画核心逻辑 ====================

func update_state() -> void:
	# 优先判断空中状态：只要脚离地，无视水平速度，铁定是 JUMP
	if not is_on_floor() and not ground_check.is_colliding():
		current_state = State.JUMP
		return
	
	# === 地面状态逻辑 ===
	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	var is_moving_tangibly := horizontal_velocity.length() > 0.1
	
	# 显式指定 bool 类型，解决 Godot 4.x 对 abs() 的类型推导错误 (Error 80, 29)
	var is_pressing_move: bool = absf(last_move_input) > 0.05
	
	# 哪怕撞墙水平速度被挤压成 0，只要玩家还按着移动键，就维持 RUN 状态
	if is_moving_tangibly or is_pressing_move:
		current_state = State.RUN
	else:
		current_state = State.IDLE


func tick_animation_and_flip(move_input: float) -> void:
	# 1. 处理贴图水平翻转
	if move_input > 0:
		sprite.flip_h = true  
	elif move_input < 0:
		sprite.flip_h = false 
		
	# 2. 播放对应动画（带去重保护）
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


func _on_deadzone_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
