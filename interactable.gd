extends Node3D

# 定义交互类型枚举
enum InteractType { LEVER, SIGNBOARD, KEY }

@export_category("交互设置")
@export var type: InteractType = InteractType.SIGNBOARD
@export var sign_text: String = "这是一块告示牌的内容"
@export var textRect_texture: Texture2D # 文本框
@export var icon_texture : Texture2D # 显示图标

# 节点引用
@onready var area = $Area3D
@onready var ui_anchor = $CanvasLayer/Control # 锚
@onready var text_rect = $CanvasLayer/Control/TextureRect # 文本框
@onready var bubble_label = $CanvasLayer/Control/Label # 文字
@onready var icon_sprite = $Sprite3D

# 状态变量
var lever_on: bool = false
var is_player_near: bool = false
var is_looked_at: bool = false
var interacted: bool = false

func _ready():
	# 连接Area3D的信号 (假设玩家节点在特定的碰撞层或名为"Player")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# 初始化UI
	ui_anchor.hide()
	icon_sprite.hide()
	text_rect.texture = textRect_texture
	bubble_label.text = sign_text
	icon_sprite.texture = icon_sprite

func _process(_delta):
	pass

# 监听按键输入
func _input(event):
	if is_player_near and event.is_action_pressed("interact"):
		match type:
			InteractType.LEVER:
				lever_on = !lever_on
			
			InteractType.SIGNBOARD:
				pass
				
			InteractType.KEY:
				interacted = true

# 信号回调
func _on_body_entered(body):
	if body.is_in_group("Player") & body.is("Collision"): # 确保玩家节点在"Player"组
		is_player_near = true
		ui_anchor.show()
	if body.is_in_group("Player") & body.is("Slicer_collision"):
		is_looked_at = true
		icon_sprite.show()

func _on_body_exited(body):
	if body.is_in_group("Player") & body.is("Collision"):
		is_player_near = false
		ui_anchor.hide()
	if body.is_in_group("Player") & body.is("Slicer_collision"):
		is_looked_at = false
		icon_sprite.hide()
