extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play(&"intro")
	await animation_player.animation_finished
	animation_player.play(&"float")
	Musicmanager.play_bgm(Musicmanager.bgm_title)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level1.tscn")
