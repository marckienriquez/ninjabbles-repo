extends Control

# This path must match your scene tree exactly 
@onready var code_label = $VBoxContainer/CodeLabel 

func _ready():
	# We leave this empty or use it to hide the screen initially
	visible = false

# This is the function called by easy_end.gd [cite: 12]
func display_code():
	# 1. Pull the fresh list of commands saved when 'Run' was pressed [cite: 6, 13]
	var commands = GlobalData.last_run_commands
	
	# 2. Build the string
	var summary_text = "run();\n"
	
	for cmd in commands:
		var technical_name = convert_to_technical(cmd)
		# Adding 4 spaces for better indentation on the scroll
		summary_text += "    " + technical_name + "();\n"
	
	summary_text += "finish();"
	
	# 3. Update the label [cite: 18]
	if code_label:
		code_label.text = summary_text

func convert_to_technical(cmd_name: String) -> String:
	# Using strip_edges() fixes hidden space issues 
	match cmd_name.strip_edges():
		"Move right": return "moveForward"
		"Move left": return "moveBackward"
		"Jump": return "jump"
		"Climb": return "climbWall"
		_: return cmd_name.to_lower().replace(" ", "_")


func _on_close_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/average_screen.tscn")
