extends Node

# 预加载你的 BGM 资源（这里换成你自己的音频路径）
#var bgm_gameover = preload("res://assets/bgm/level1.mp3")
var bgm_title = preload("res://assets/bgm/title.mp3")
var bgm_level_1 = preload("res://assets/bgm/level1.mp3")


var audio_player: AudioStreamPlayer

func _ready() -> void:
	# 动态创建一个音频播放器并加到根节点，它独立于任何场景
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = "Master" # 绑定音频总线

# 核心方法：只有当新 BGM 和正在播放的不一样时，才切换
func play_bgm(new_stream: AudioStream):
	if audio_player.stream == new_stream:
		# 如果是同一首歌，什么都不做，继续播放
		return
	
	audio_player.stream = new_stream
	audio_player.play()
