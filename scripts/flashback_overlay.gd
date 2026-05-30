extends RefCounted

const FONT := preload("res://assets/fonts/VonwaonBitmap-16px.ttf")
const START_VIDEO := preload("res://assets/videos/start.ogv")
const ENDING_VIDEO := preload("res://assets/videos/ending.ogv")
const TITLE_SCENE := "res://scenes/title.tscn"

const INTRO_LINES: Array[String] = [
	"【警告：患者视觉与空间认知系统彻底离线】",
	"【原因：重度脑部创伤。具体记忆已全部剔除保护】",
	"「正在退回大脑底层——认知退回到最原始的几何与空间逻辑」",
	"「当前状态：逻辑混乱。请通过切换切面重构秩序，寻找认知锚点」"
]

const LEVEL_SWITCH_LINES: Array[String] = [
	"「第一阶段自检通过。捕捉到核心认知锚点。」",
	"「空间知觉同步：50%」",
	"「破碎认知开始拼接，正在载入最终的几何错觉层。请建立闭环。」"
]

const ENDING_STATUS_LINES: Array[String] = [
	"【最终认知锚点已集齐。底层逻辑闭环建立。】",
	"【空间知觉同步：100%】",
	"【大脑自救程序运行完毕】",
	"【正在重组现实记忆。】"
]

const ENDING_MEMORY_LINES: Array[String] = [
	"在那场剧烈的车祸发生后，你的大脑为了保护你，切断了所有痛苦的画面，将你放逐到最荒凉、最冰冷的几何底层。",
	"在那里，没有色彩，没有声音，只有错乱的切面和死胡同。",
	"那是大脑为你建立的终极防御，也是一座将你困住的迷宫。",
	"但你没有放弃。你知道有人在等你，知道你必须要拯救你自己。",
	"于是你在最混乱的维度里，凭借纯粹的理智和直觉，一步一步找回了定位，拼凑出了方向。",
	"你捡起的那三把钥匙，不是别的——",
	"它们是你在绝境中，重新凝聚起的清醒、敢于永恒尝试下去的勇气、与活下去的意志。",
	"迷宫已碎。",
	"欢迎回到这个立体、复杂、却又如此斑斓、值得你再次眷恋的真实世界。",
	"【患者已苏醒】"
]


static func play_intro(tree: SceneTree, target_scene: String = "") -> void:
	await _play_video(tree, START_VIDEO)
	await _play_terminal_lines(tree, INTRO_LINES, 0.72, 1.2, 44, false, target_scene)


static func play_level_switch(tree: SceneTree, target_scene: String = "") -> void:
	await _play_terminal_lines(tree, LEVEL_SWITCH_LINES, 0.8, 1.0, 44, false, target_scene)


static func play_ending(tree: SceneTree) -> void:
	await _play_terminal_lines(tree, ENDING_STATUS_LINES, 0.8, 0.8)
	await _play_terminal_lines(tree, ENDING_MEMORY_LINES, 0.24, 0.7, 34, true)
	await _play_eye_open(tree)
	await _play_video(tree, ENDING_VIDEO)
	tree.change_scene_to_file(TITLE_SCENE)


static func _play_video(tree: SceneTree, stream: VideoStream) -> void:
	_stop_bgm()

	var overlay := CanvasLayer.new()
	overlay.layer = 140
	overlay.name = "VideoOverlay"
	tree.root.add_child(overlay)

	var background := ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(background)

	var player := VideoStreamPlayer.new()
	player.set_anchors_preset(Control.PRESET_FULL_RECT)
	player.expand = true
	player.stream = stream
	overlay.add_child(player)

	player.play()
	await player.finished
	overlay.queue_free()


static func _stop_bgm() -> void:
	if Musicmanager.audio_player != null:
		Musicmanager.audio_player.stop()


static func _play_terminal_lines(
	tree: SceneTree,
	lines: Array[String],
	line_delay: float,
	hold_time: float,
	font_size: int = 44,
	compact: bool = false,
	target_scene: String = ""
) -> void:
	var overlay := _build_overlay()
	var root := tree.root
	root.add_child(overlay)

	var label: Label = overlay.get_node("Text")
	label.label_settings = _make_label_settings(font_size)
	label.text = ""
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if not compact else VERTICAL_ALIGNMENT_TOP

	var visible_lines: Array[String] = []
	var noise: ColorRect = overlay.get_node("Noise")
	for line in lines:
		visible_lines.append(line)
		label.text = "\n".join(visible_lines)
		noise.modulate.a = randf_range(0.1, 0.24)
		await tree.create_timer(line_delay).timeout

	await tree.create_timer(hold_time).timeout
	if target_scene != "":
		await _change_scene_under_overlay(tree, overlay, target_scene)
	await _fade_out(tree, overlay)


static func _change_scene_under_overlay(tree: SceneTree, overlay: CanvasLayer, target_scene: String) -> void:
	var label: Label = overlay.get_node("Text")
	label.text = ""
	var noise: ColorRect = overlay.get_node("Noise")
	noise.modulate.a = 0.08

	var error := tree.change_scene_to_file(target_scene)
	if error != OK:
		push_error("Failed to change scene to %s. Error code: %s" % [target_scene, error])
		return

	await tree.process_frame
	await tree.process_frame


static func _play_eye_open(tree: SceneTree) -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 128
	overlay.name = "EyeOpenOverlay"
	tree.root.add_child(overlay)

	var white := ColorRect.new()
	white.color = Color(1, 1, 1, 1)
	white.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(white)

	var top_lid := ColorRect.new()
	top_lid.color = Color(0, 0, 0, 1)
	overlay.add_child(top_lid)

	var bottom_lid := ColorRect.new()
	bottom_lid.color = Color(0, 0, 0, 1)
	overlay.add_child(bottom_lid)

	var wake_label := Label.new()
	wake_label.label_settings = _make_label_settings(56, Color(0, 0, 0, 1))
	wake_label.text = "【患者已苏醒】"
	wake_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wake_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wake_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	wake_label.modulate.a = 0.0
	overlay.add_child(wake_label)

	var viewport_size := tree.root.get_visible_rect().size
	top_lid.anchor_right = 1.0
	top_lid.offset_left = 0.0
	top_lid.offset_top = 0.0
	top_lid.offset_right = 0.0
	top_lid.offset_bottom = viewport_size.y * 0.5
	bottom_lid.anchor_right = 1.0
	bottom_lid.offset_left = 0.0
	bottom_lid.offset_top = viewport_size.y * 0.5
	bottom_lid.offset_right = 0.0
	bottom_lid.offset_bottom = viewport_size.y

	var tween := tree.create_tween()
	tween.set_parallel(true)
	tween.tween_property(top_lid, "offset_bottom", 0.0, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bottom_lid, "offset_top", viewport_size.y, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(wake_label, "modulate:a", 1.0, 1.3).set_delay(1.0)
	await tween.finished
	await tree.create_timer(1.2).timeout
	await _fade_out(tree, overlay, 1.1)


static func _build_overlay() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.layer = 128
	overlay.name = "FlashbackOverlay"

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.015, 0.015, 0.02, 0.96)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(background)

	var noise := ColorRect.new()
	noise.name = "Noise"
	noise.color = Color(0.85, 0.95, 1.0, 0.16)
	noise.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(noise)

	var scanlines := VBoxContainer.new()
	scanlines.name = "Scanlines"
	scanlines.set_anchors_preset(Control.PRESET_FULL_RECT)
	scanlines.add_theme_constant_override("separation", 12)
	overlay.add_child(scanlines)
	for index in range(48):
		var line := ColorRect.new()
		line.custom_minimum_size = Vector2(0, 2)
		line.color = Color(0.0, 0.0, 0.0, 0.2 + float(index % 3) * 0.06)
		scanlines.add_child(line)

	var label := Label.new()
	label.name = "Text"
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 150.0
	label.offset_top = 120.0
	label.offset_right = -150.0
	label.offset_bottom = -120.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_constant_override("line_spacing", 18)
	overlay.add_child(label)

	return overlay


static func _make_label_settings(font_size: int, color: Color = Color(0.82, 0.98, 0.9, 1)) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font = FONT
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = 8
	settings.outline_color = Color(0, 0, 0, 1)
	return settings


static func _fade_out(tree: SceneTree, overlay: CanvasLayer, duration: float = 0.6) -> void:
	var tween := tree.create_tween()
	tween.set_parallel(true)
	for child in overlay.get_children():
		if child is CanvasItem:
			tween.tween_property(child, "modulate:a", 0.0, duration)
	await tween.finished
	overlay.queue_free()
