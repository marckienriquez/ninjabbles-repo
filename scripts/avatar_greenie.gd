extends CharacterBody2D

var right: bool = true  # true = facing right, false = facing left
var on_ladder: bool = false
var current_ladder: Node2D = null
var is_climbing: bool = false
const SPEED = 200.0
const JUMP_VELOCITY = -300.0

func _ready():
	add_to_group("character")

func run_commands(commands: Array[String]):
	for command in commands:
		await execute_command(command)

func execute_command(command: String):
	match command:
		"Move right":
			right = true
			await move_in_direction(Vector2.RIGHT)
		"Move left":
			right = false
			await move_in_direction(Vector2.LEFT)
		"Jump":
			await jump()
		"Climb":
			await climb()

func move_in_direction(dir: Vector2):
	var tween = create_tween()
	tween.tween_property(self, "position", position + dir * 16, 0.4)
	await tween.finished

func jump():
	while not is_on_floor():
		await get_tree().process_frame
	
	var forward = Vector2.RIGHT if right else Vector2.LEFT
	var peak_height = -80  
	var forward_dist = 60 
	
	var jump_peak = position + Vector2(forward_dist / 2, peak_height)
	var landing_pos = position + Vector2(forward_dist, 0)
	
	var tween = create_tween()
	
	# 1. UPWARD: Takes 0.4 seconds to reach the peak
	tween.tween_property(self, "position", jump_peak, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. DOWNWARD: Increased to 0.6 seconds for a slower, floaty fall
	# Using TRANS_SINE and EASE_IN_OUT makes the landing very smooth
	tween.tween_property(self, "position", landing_pos, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

signal character_clicked

func climb():
	if current_ladder == null:
		return
	
	is_climbing = true
	
	# We use a while loop to keep climbing as long as we are on a ladder
	while current_ladder != null:
		var ladder_top_y = current_ladder.global_position.y - current_ladder.ladder_height / 2.0
		var character_half_height = $CollisionShape2D.shape.size.y / 2.0
		var locked_x = global_position.x

		# Move up this specific segment
		while global_position.y - character_half_height > ladder_top_y:
			global_position.y -= 2
			await get_tree().process_frame
			# If we enter a new ladder during this frame, 
			# 'current_ladder' will be updated by the Area2D signal automatically
		
		# Small buffer check: If we are at the top of the current segment, 
		# but current_ladder has been updated to a NEW segment above, keep going.
		# Otherwise, we've reached the very top of the stack.
		await get_tree().process_frame 
		if not is_on_new_ladder_segment(): 
			break

	is_climbing = false

# Helper to check if we are still overlapping a ladder area
func is_on_new_ladder_segment() -> bool:
	# This ensures that if we exited one ladder but entered another, 
	# current_ladder is still valid.
	return current_ladder != null

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("character_clicked")

func _physics_process(delta: float) -> void:
	if is_climbing:
		velocity = Vector2.ZERO
		move_and_slide()
		return  # exit before ANYTHING else, including ladder top update

	# Ladder top collision update only runs when NOT climbing
	if current_ladder != null:
		var ladder_top_y = current_ladder.global_position.y - current_ladder.ladder_height / 2
		var top_col = current_ladder.get_node_or_null("TopCollision/CollisionShape2D")
		if top_col:
			top_col.disabled = global_position.y > ladder_top_y + 4

	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
