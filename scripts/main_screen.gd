extends Control
const instruction_scene = preload("res://scene/instruction_screen.tscn")

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_texture_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	get_tree().change_scene_to_file("res://scene/character_select.tscn")


func _on_instr_btn_pressed() -> void:
	var instruction_resource = preload("res://scene/instruction_screen.tscn")
	var instructions = instruction_resource.instantiate()
	# 1. Add it to the scene tree first
	add_child(instructions)
