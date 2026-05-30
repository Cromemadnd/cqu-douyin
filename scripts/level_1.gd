extends Node3D

func _ready() -> void:
	# 刚进关卡时通知音频管理器
	# 哪怕场景被重载，_ready 重新执行，SoundManager 发现是同一首歌也会直接忽略，BGM 不会断
	Musicmanager.play_bgm(Musicmanager.bgm_level_1)
