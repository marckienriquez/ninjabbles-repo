extends Node

signal music_setting_changed(enabled: bool)
signal soundfx_setting_changed(enabled: bool)

var last_run_commands: Array[String] = []
var full_gameplay_history = []

var selected_character := "MIDORI"

var music_enabled := true
var soundfx_enabled := true

func set_music_enabled(value: bool):
	music_enabled = value
	music_setting_changed.emit(music_enabled)

func set_soundfx_enabled(value: bool):
	soundfx_enabled = value
	soundfx_setting_changed.emit(soundfx_enabled)

func add_to_history(new_commands: Array):
	full_gameplay_history.append_array(new_commands)

func clear_history():
	full_gameplay_history.clear()
