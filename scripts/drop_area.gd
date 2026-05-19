extends VFlowContainer

const MAX_BLOCKS = 21

func _ready():
	add_to_group("drop_area") 

func can_drop_data(_pos, data):
	# Only allow dropping if it's a valid block AND we haven't hit the 21 block limit
	var is_valid_block = data is Panel and data.is_in_group("draggable_block") 
	var has_room = get_child_count() < MAX_BLOCKS
	return is_valid_block and has_room

func drop_data(_pos, data):
	if not is_instance_valid(data): 
		return 
		
	# Double-check room here just in case an auto-click bypasses can_drop_data
	if get_child_count() >= MAX_BLOCKS:
		if data.get_parent() == null: # It's a fresh orphan clone from a click/drag
			data.queue_free()
		return

	if data.get_parent(): 
		data.get_parent().remove_child(data) 
	
	add_child(data) 
	data.position = Vector2.ZERO 
	data.is_dragging = false 

func get_commands() -> Array[String]: 
	var commands: Array[String] = [] 
	for child in get_children(): 
		var text = child.get("block_text")
		if text != null and text != "": 
			commands.append(text)
	return commands
