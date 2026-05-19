extends Control

# This path must match your scene tree exactly 
@onready var code_label = $VBoxContainer/CodeLabel
@onready var timeElapsed = $TimerTexture/timeElapsed

func _ready():
	# We leave this empty or use it to hide the screen initially
	visible = false

func display_code():
	var timer_panel = get_node("../../TimerPanel") 
	
	if timer_panel and timeElapsed:
		# Read the saved variable we just created instead of the dead timer
		var time_left = timer_panel.final_time_saved
		var calculated_time = 120 - time_left
		
		timeElapsed.text = str(snappedf(calculated_time, 0.1)) + "s"
		
	# 1. Pull the full list of commands used
	var all_commands = GlobalData.full_gameplay_history
	
	# 2. Create a list to keep track of unique actions
	var unique_commands = []
	
	for cmd in all_commands:
		# Only add the command if it's not already in our unique list
		if not unique_commands.has(cmd):
			unique_commands.append(cmd)
	
	# 3. Build the string using the filtered list
	var summary_text = "run();\n"
	
	for cmd in unique_commands:
		var technical_name = convert_to_technical(cmd)
		summary_text += "    " + technical_name + "();\n"
	
	summary_text += "finish();"
	
	# 4. Update the label[cite: 2]
	if code_label:
		code_label.text = summary_text

func convert_to_technical(cmd_name: String) -> String:
	# Using strip_edges() fixes hidden space issues 
	match cmd_name.strip_edges():
		"Move right": return "moveRight"
		"Move left": return "moveLeft"
		"Jump": return "jump"
		_: return cmd_name.to_lower().replace(" ", "_")

func _on_close_summary_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/average_screen.tscn")
