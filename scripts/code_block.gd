extends Panel

@onready var label = $BlockLabel
var is_dragging = false
var offset = Vector2.ZERO
var clone: Panel = null

@export var block_text: String = "Block"

func _ready():
	add_to_group("draggable_block")
	mouse_filter = Control.MOUSE_FILTER_STOP
	label.text = block_text

func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pressed = event.pressed
		if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
			return
		if pressed:
			start_drag(event)
		else:
			stop_drag()

	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		var pos = get_global_mouse_position()
		# Drive whichever node is "active"
		if clone != null:
			clone.global_position = pos - offset
		elif is_dragging:
			global_position = pos - offset

func start_drag(event):
	if get_parent().name == "BlockList":
		clone = self.duplicate() as Panel
		get_parent().get_parent().add_child(clone)
		clone.global_position = global_position   # 1. place it first
		offset = get_global_mouse_position() - clone.global_position  # 2. THEN calc offset
		clone.move_to_front()
		# clone does NOT need is_dragging — the original drives it
	else:
		is_dragging = true
		offset = get_global_mouse_position() - global_position
		move_to_front()

func stop_drag():
	is_dragging = false 
	var mouse_pos = get_global_mouse_position() 
	
	# 1. Find the workspace
	var drop_area = get_tree().get_first_node_in_group("drop_area") 
	
	# 2. Check if we are dropping inside the DropArea
	if drop_area and drop_area.get_global_rect().has_point(mouse_pos):
		if clone != null:
			# Successfully dropping a NEW block from the list
			drop_area.drop_data(Vector2.ZERO, clone) 
			clone = null # Clear reference so it isn't freed below 
		else:
			# Just moving a block that was already in the DropArea
			# VBoxContainer handles the re-ordering automatically
			pass 
	else:
		# 3. Dropped OUTSIDE: Delete the block
		if clone != null:
			clone.queue_free() 
			clone = null 
		elif get_parent() != null and get_parent().is_in_group("drop_area"):
			# If it was an existing block dragged out of the scroll, delete it
			queue_free() 

	is_dragging = false
