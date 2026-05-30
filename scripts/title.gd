extends Node2D

const FlashbackOverlay := preload("res://scripts/flashback_overlay.gd")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var starting_game: bool = false


func _ready() -> void:
	animation_player.play(&"intro")
	await animation_player.animation_finished
	animation_player.play(&"float")
	Musicmanager.play_bgm(Musicmanager.bgm_title)


func _on_start_button_pressed() -> void:
	if starting_game:
		return
	starting_game = true
	await FlashbackOverlay.play_intro(get_tree(), "res://scenes/level1.tscn")
