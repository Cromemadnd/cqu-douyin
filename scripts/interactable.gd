extends Node3D

const FlashbackOverlay := preload("res://scripts/flashback_overlay.gd")
const LEVER_ON_TEXTURE := preload("res://assets/sprites/lever_on.png")
const DOOR_OPEN_TEXTURE := preload("res://assets/door_opened.png")

# 定义交互类型枚举
enum InteractType { LEVER, SIGNBOARD, KEY, DOOR }
enum StorySequence { NONE, LEVEL_SWITCH, ENDING }

@export_category("交互设置")
@export var type: InteractType = InteractType.SIGNBOARD
@export var sign_text: String = "这是一块告示牌的内容"
@export var textRect_texture: Texture2D # 文本框
@export var icon_texture : Texture2D # 显示图标
@export_file("*.tscn") var target_scene: String = ""
@export var story_sequence: StorySequence = StorySequence.NONE
@export var starts_locked: bool = false
@onready var slider_collision = %SlicerCollision

# 节点引用
@onready var area: Area3D = $Area3D
@onready var ui_anchor: Control = $CanvasLayer/Control # 锚
@onready var text_rect: TextureRect = $CanvasLayer/Control/TextureRect # 文本框
@onready var bubble_label: Label = $CanvasLayer/Control/Label # 文字
@onready var icon_sprite: Sprite3D = $Sprite3D

# 状态变量
var lever_on: bool = false
var is_player_near: bool = false
var is_looked_at: bool = false
var interacted: bool = false
var is_transitioning: bool = false
var interaction_locked: bool = false

func _ready():
	# 初始化UI
	interaction_locked = starts_locked
	ui_anchor.hide()
	icon_sprite.hide()
	text_rect.texture = textRect_texture
	bubble_label.text = sign_text
	icon_sprite.texture = icon_texture

# 监听按键输入
func _input(event):
	if is_player_near and not interaction_locked and event.is_action_pressed("interact"):
		match type:
			InteractType.LEVER:
				_handle_lever()
			
			InteractType.SIGNBOARD:
				pass
				
			InteractType.KEY:
				_collect_key()

			InteractType.DOOR:
				await _handle_door()


func _handle_lever() -> void:
	if lever_on:
		return
	lever_on = true
	_set_icon_texture(LEVER_ON_TEXTURE)
	sign_text = "门已打开"
	bubble_label.text = sign_text
	_open_level_door()


func _collect_key() -> void:
	if interacted:
		return
	interacted = true
	_unlock_ending_interactable()
	_disable_own_area()
	hide()
	queue_free()


func _handle_door() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	match story_sequence:
		StorySequence.LEVEL_SWITCH:
			await FlashbackOverlay.play_level_switch(get_tree(), target_scene)
		StorySequence.ENDING:
			await FlashbackOverlay.play_ending(get_tree())
	
	if target_scene != "" and story_sequence != StorySequence.LEVEL_SWITCH:
		get_tree().change_scene_to_file(target_scene)


func unlock_interaction(new_icon_texture: Texture2D = null) -> void:
	interaction_locked = false
	if type == InteractType.DOOR:
		sign_text = "[E] 建立闭环"
		bubble_label.text = sign_text
	if new_icon_texture != null:
		_set_icon_texture(new_icon_texture)
	if is_player_near:
		ui_anchor.show()


func _unlock_ending_interactable() -> void:
	var ending := get_parent().get_node_or_null("EndingInteractable")
	if ending != null and ending.has_method("unlock_interaction"):
		ending.unlock_interaction(DOOR_OPEN_TEXTURE)


func _open_level_door() -> void:
	var door := get_parent().get_node_or_null("门-col")
	if door == null:
		return
	door.hide()
	%CSGMeshDoor.hide()
	_disable_collision_shapes(door)


func _disable_collision_shapes(node: Node) -> void:
	if node is CollisionShape3D:
		node.set_deferred("disabled", true)
	for child in node.get_children():
		_disable_collision_shapes(child)


func _disable_own_area() -> void:
	if area != null:
		area.set_deferred("monitoring", false)
		area.set_deferred("monitorable", false)
		_disable_collision_shapes(area)


func _set_icon_texture(texture: Texture2D) -> void:
	icon_texture = texture
	if icon_sprite != null:
		icon_sprite.texture = texture

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == %Player:
		if type == InteractType.KEY:
			_collect_key()
			return
		is_player_near = true
		if not interaction_locked or type == InteractType.DOOR:
			ui_anchor.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == %Player:
		is_player_near = false
		ui_anchor.hide()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area == %SlicerCollisionArea:
		is_looked_at = true
		icon_sprite.show()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area == %SlicerCollisionArea:
		is_looked_at = false
		icon_sprite.hide()
