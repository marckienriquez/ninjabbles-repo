extends Control

@onready var x_btn = $Control/x

@onready var bgmusic_on = $Control/bgmusic_on
@onready var bgmusic_off = $Control/bgmusic_off

@onready var soundfx_on = $Control/soundfx_on
@onready var soundmusic_off = $Control/soundmusic_off

@onready var home_btn = $Control/Home
@onready var replay_btn = $Control/Replay




func _ready():
	bgmusic_off.mouse_filter = Control.MOUSE_FILTER_IGNORE
	soundmusic_off.mouse_filter = Control.MOUSE_FILTER_IGNORE

	bgmusic_off.visible = !GlobalData.music_enabled
	soundmusic_off.visible = !GlobalData.soundfx_enabled

	x_btn.pressed.connect(_on_x_pressed)

	bgmusic_on.pressed.connect(_on_bgmusic_on_pressed)
	soundfx_on.pressed.connect(_on_soundfx_on_pressed)

	home_btn.pressed.connect(_on_home_pressed)
	replay_btn.pressed.connect(_on_replay_pressed)


func _on_x_pressed() -> void:
	queue_free()


func _on_bgmusic_on_pressed() -> void:
	GlobalData.set_music_enabled(!GlobalData.music_enabled)
	bgmusic_off.visible = !GlobalData.music_enabled


func _on_soundfx_on_pressed() -> void:
	GlobalData.set_soundfx_enabled(!GlobalData.soundfx_enabled)
	soundmusic_off.visible = !GlobalData.soundfx_enabled


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_scrn/main_screen.tscn")


func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/easy_screen.tscn")
