extends Control

@onready var btn_easy = $TextureButton
@onready var btn_character = $TextureButton2

func _ready() -> void:
	btn_easy.pressed.connect(_on_easy_pressed)
	btn_character.pressed.connect(_on_character_pressed)

<<<<<<< HEAD
func _on_easy_pressed() -> void:
=======

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_texture_button_pressed() -> void:
	$AudioStreamPlayer.stop()
>>>>>>> marc-branch
	get_tree().change_scene_to_file("res://scene/easy_screen.tscn")

func _on_character_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/character_select.tscn")
