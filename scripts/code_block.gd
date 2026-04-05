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
	if clone == null:
		return

	var drop_area = get_parent().get_parent().get_node("DropArea")
	if drop_area.get_global_rect().has_point(get_global_mouse_position()):
		drop_area.drop_data(Vector2.ZERO, clone)
	else:
		clone.queue_free()

	clone = null
