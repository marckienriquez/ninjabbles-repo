extends Control

@onready var x_btn = $x

@onready var bgmusic_on = $bgmusic_on
@onready var bgmusic_off = $bgmusic_off

@onready var soundfx_on = $soundfx_on
@onready var soundmusic_off = $soundmusic_off

@onready var home_btn = $Home
@onready var replay_btn = $Replay


func _ready():
	bgmusic_off.visible = false
	soundmusic_off.visible = false

	bgmusic_off.mouse_filter = Control.MOUSE_FILTER_IGNORE
	soundmusic_off.mouse_filter = Control.MOUSE_FILTER_IGNORE

	x_btn.pressed.connect(_on_x_pressed)
	bgmusic_on.pressed.connect(_on_bgmusic_on_pressed)
	soundfx_on.pressed.connect(_on_soundfx_on_pressed)

	home_btn.pressed.connect(_on_home_pressed)
	replay_btn.pressed.connect(_on_replay_pressed)


func _on_x_pressed() -> void:
	queue_free()


func _on_bgmusic_on_pressed() -> void:
	bgmusic_off.visible = !bgmusic_off.visible


func _on_soundfx_on_pressed() -> void:
	soundmusic_off.visible = !soundmusic_off.visible


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_scrn/main_screen.tscn")


func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/easy_screen.tscn")
	
	
