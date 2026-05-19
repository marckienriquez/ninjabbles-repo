extends Control

const instruction_scene = preload("res://scene/instruction_screen.tscn")
const settings_scene = preload("res://scene/main_settings.tscn")

func _ready() -> void:
	GlobalData.music_setting_changed.connect(_on_music_setting_changed)
	_apply_music_setting()

func _apply_music_setting():
	if GlobalData.music_enabled:
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
	else:
		$AudioStreamPlayer.stop()

func _on_music_setting_changed(enabled: bool):
	_apply_music_setting()

func _on_texture_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	get_tree().change_scene_to_file("res://scene/character_select.tscn")

func _on_instr_btn_pressed() -> void:
	var instructions = instruction_scene.instantiate()
	add_child(instructions)

func _on_settings_pressed() -> void:
	var settings = settings_scene.instantiate()
	add_child(settings)
