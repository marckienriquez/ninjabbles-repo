extends VBoxContainer

func _ready():
	# Ensuring the group is set via code just in case
	add_to_group("drop_area") 

func can_drop_data(_pos, data):
	# The 'data' passed from stop_drag is the Panel node itself
	return data is Panel and data.is_in_group("draggable_block") 

func drop_data(_pos, data):
	# Prevent errors if the node is already being deleted
	if not is_instance_valid(data):
		return 
		
	# Remove from the temporary "drag" parent
	if data.get_parent():
		data.get_parent().remove_child(data) 
	
	add_child(data) 
	# Crucial: Reset position and let VBoxContainer take over layout
	data.position = Vector2.ZERO 
	data.is_dragging = false # Ensure drag state is reset 

func get_commands() -> Array[String]:
	var commands: Array[String] = []
	print("DEBUG: DropArea has ", get_child_count(), " nodes.") # Check this in Output
	for child in get_children():
		# Using 'get()' is safer for checking exported variables
		var text = child.get("block_text")
		if text != null and text != "":
			commands.append(text) 
	print("DEBUG: Commands captured: ", commands)
	return commands
