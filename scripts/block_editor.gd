extends Control

@onready var drop_area = $DropArea
@onready var run_button = $RunButton
@onready var clear_button = $ClearButton

func _ready():
	run_button.pressed.connect(_on_run_pressed)
	clear_button.pressed.connect(_on_clear_pressed)

func _on_clear_pressed():
	# Check if the drop_area exists to avoid null reference errors
	if drop_area:
		# Iterate through all blocks currently in the drop area
		for child in drop_area.get_children():
			child.queue_free()
		
		# Optional: If your drop_area has a custom internal list/array 
		# for logic tracking, you might need to clear it too:
		if drop_area.has_method("clear_internal_commands"):
			drop_area.clear_internal_commands()
	else:
		print("Error: drop_area node not found!")

func _on_run_pressed():
	# 1. Specifically look for the Ninja node in the current scene [cite: 1]
	var character = get_tree().current_scene.find_child("avatar_greenie", true, false)
	
	if character and character.has_method("run_commands"):
		# 2. Get the list of blocks from the drop area [cite: 11]
		var commands = drop_area.get_commands()
		
		# 3. SAVE them into GlobalData so the summary screen can see them later 
		GlobalData.last_run_commands = commands 
		GlobalData.full_gameplay_history.append_array(commands)
		
		# 4. Tell the ninja to execute the animation/logic 
		character.run_commands(commands)
	else:
		print("Error: Could not find 'avatar_greenie' or script is missing!")

func _on_avatar_greenie_character_clicked() -> void:
	var character = get_tree().current_scene.find_child("avatar_greenie", true, false) 
	var current_drop_area = get_tree().current_scene.find_child("DropArea", true, false)
	
	if character and current_drop_area:
		var commands = current_drop_area.get_commands()
		GlobalData.last_run_commands = commands 
		character.run_commands(commands) 
	else:
		print("Error: Required nodes (avatar or DropArea) not found in this scene!")
	
