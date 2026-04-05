extends Control

signal run_pressed  # add this

@onready var drop_area = $DropArea
@onready var run_button = $RunButton
@onready var character = get_tree().get_first_node_in_group("character")

func _ready():
	run_button.pressed.connect(_on_run_pressed)

func _on_run_pressed():
	var commands = drop_area.get_commands()
	character.run_commands(commands)
