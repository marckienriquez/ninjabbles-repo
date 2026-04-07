extends Control

signal run_pressed 

@onready var drop_area = $DropArea
@onready var run_button = $RunButton

func _ready():
	run_button.pressed.connect(_on_run_pressed)

func _on_run_pressed():
	# 1. Specifically look for the Ninja node in the current scene [cite: 1]
	var character = get_tree().current_scene.find_child("avatar_greenie", true, false)
	
	if character and character.has_method("run_commands"):
		# 2. Get the list of blocks from the drop area [cite: 11]
		var commands = drop_area.get_commands()
		
		# 3. SAVE them into GlobalData so the summary screen can see them later 
		GlobalData.last_run_commands = commands 
		
		# 4. Tell the ninja to execute the animation/logic 
		character.run_commands(commands)
	else:
		print("Error: Could not find 'avatar_greenie' or script is missing!")
