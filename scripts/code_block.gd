extends Panel

@onready var label = $BlockLabel
var is_dragging = false
var offset = Vector2.ZERO
var clone: Panel = null
var click_time: int = 0 # Tracks how long the button is held

@export var block_text: String = "Block"

func _ready():
	# Standard setup for Ninjabbles blocks
	add_to_group("draggable_block") 
	mouse_filter = Control.MOUSE_FILTER_STOP 
	label.text = block_text 

func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
			return
		
		if event.pressed:
			click_time = Time.get_ticks_msec() 
			start_drag(event) 
		else:
			var duration = Time.get_ticks_msec() - click_time 
			if duration < 200: 
				# Scenario A: Clicked on an existing block in the parchment -> DELETE IT 
				if get_parent() and get_parent().is_in_group("drop_area"): 
					_delete_instantly() 
					return
				
				# Scenario B: Clicked on a block in the sidebar -> AUTO-SELECT & SEND TO PARCHMENT
				elif get_parent() and get_parent().name == "BlockList":
					_auto_select_block()
					# Clean up the trailing drag clone that start_drag instantly made
					if clone != null:
						clone.queue_free()
						clone = null
					return
			
			stop_drag() 

	if event is InputEventMouseMotion or event is InputEventScreenDrag: 
		var pos = get_global_mouse_position() 
		if clone != null: 
			clone.global_position = pos - offset 
		elif is_dragging: 
			global_position = pos - offset
			
func start_drag(_event):
	var mouse_pos = get_global_mouse_position()
	# If picking a new block from the scroll list on the left
	if get_parent() and get_parent().name == "BlockList":
		clone = self.duplicate() as Panel
		clone.block_text = self.block_text 
		
		# Add to the BlockEditor (canvas layer) so it renders above everything [cite: 12]
		get_parent().get_parent().add_child(clone) 
		
		clone.global_position = global_position
		offset = mouse_pos - clone.global_position
		clone.move_to_front()
	else:
		# If dragging an existing block already on the parchment
		is_dragging = true
		offset = mouse_pos - global_position
		move_to_front()

func stop_drag():
	var mouse_pos = get_global_mouse_position() 
	
	# Find the parchment area by its group
	var drop_area = get_tree().get_first_node_in_group("drop_area")
	
	var is_inside = false
	if drop_area:
		is_inside = drop_area.get_global_rect().has_point(mouse_pos)
	
	if is_inside:
		if clone != null:
			# Drop the new block into the parchment container
			drop_area.drop_data(Vector2.ZERO, clone) 
			clone = null 
		# Existing blocks stay in the VFlowContainer automatically
	else:
		# --- THE "DRAG OUT TO REMOVE" FIX ---
		# If dropped outside the parchment, destroy the clone or the block
		if clone != null:
			clone.queue_free() 
			clone = null 
		elif get_parent() != null and get_parent().is_in_group("drop_area"):
			_delete_instantly()

	is_dragging = false

# Helper to bypass VFlowContainer's "sticky" sorting [cite: 14]
func _delete_instantly():
	var area = get_parent()
	if area:
		# Detach immediately so the container stops seeing it as a child [cite: 14]
		area.remove_child(self) 
	queue_free() # Final cleanup
	
func _auto_select_block():
	var drop_area = get_tree().get_first_node_in_group("drop_area")
	if drop_area:
		# 1. Create a clean duplicate of this block
		var auto_clone = self.duplicate() as Panel
		auto_clone.block_text = self.block_text
		
		# 2. Safely drop it directly into the parchment layout container
		drop_area.drop_data(Vector2.ZERO, auto_clone)
