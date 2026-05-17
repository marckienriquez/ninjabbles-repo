extends CharacterBody2D

<<<<<<< HEAD
var character_frames = {
	"MIDORI": preload("res://asset/sprites/midori_idle.tres"),
	"AO": preload("res://asset/sprites/ao_idle.tres"),
	"HANA": preload("res://asset/sprites/hana_idle.tres"),
	"MURASAKI": preload("res://asset/sprites/murasaki_idle.tres"),
	"FURUI": preload("res://asset/sprites/furui_idle.tres"),
	"WAKAI": preload("res://asset/sprites/wakai_idle.tres")
}


=======
@onready var sfx_player: AudioStreamPlayer2D = $SfxPlayer

@export_group("Sound Effects")
@export var sfx_move: AudioStream
@export var sfx_jump: AudioStream
@export var sfx_climb: AudioStream
@export var sfx_slide: AudioStream
@export var sfx_punch: AudioStream
@export var sfx_dead: AudioStream
>>>>>>> marc-branch

var right: bool = true: 
	set(value):
		right = value
		var sprite = get_node_or_null("AnimatedSprite2D")
		if sprite:
			sprite.flip_h = !right
				
var on_ladder: bool = false
var current_ladder: Node2D = null
var is_climbing: bool = false
var is_jumping: bool = false
var last_safe_position: Vector2
const FALL_THRESHOLD = 200.0
const SPEED = 200.0
const JUMP_VELOCITY = -300.0

func _ready():
	add_to_group("character")
	last_safe_position = global_position
	apply_selected_character()

func apply_selected_character():
	var selected_name = GlobalData.selected_character

	if character_frames.has(selected_name):
		$AnimatedSprite2D.sprite_frames = character_frames[selected_name]
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.sprite_frames = character_frames["MIDORI"]
		$AnimatedSprite2D.play("idle")
		
	$AnimatedSprite2D.scale = Vector2(0.16, 0.16)
		
func run_commands(commands: Array[String]):
	for command in commands:
		await execute_command(command)

func execute_command(command: String):
	match command:
		"Move right":
			right = true
			$AnimatedSprite2D.flip_h = false
			await move_in_direction(Vector2.RIGHT)
		"Move left":
			right = false
			$AnimatedSprite2D.flip_h = true
			await move_in_direction(Vector2.LEFT)
		"Jump":
			await jump()
		"Climb":
			await climb()
		"Slide":
			await slide()
		"Punch":
			await punch()

func play_sfx(stream: AudioStream):
	if stream and sfx_player:
		sfx_player.stream = stream
		sfx_player.play()

func move_in_direction(dir: Vector2):
	play_sfx(sfx_move)
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + dir.x * 35, 0.4)
	await tween.finished
	velocity.y = 0

var jump_count: int = 0 

func jump():
	play_sfx(sfx_jump)
	jump_count += 1
	var current_jump_id = jump_count
	is_jumping = true
	
	# 1. Force the direction
	var forward_multiplier = 1 if right else -1
	
	# 2. Apply slanted velocity
	velocity.y = JUMP_VELOCITY
	velocity.x = 10 * forward_multiplier # Increased for a clearer slant
	
	# 3. CRITICAL: Wait more than one frame 
	# This prevents the script from thinking it "landed" instantly 
	# while still touching the floor from the first jump.
	for i in range(5):
		await get_tree().process_frame
	
	# 4. Wait until we land on the surface shown in image_026f42.png
	while not is_on_floor():
		# Re-assert horizontal velocity in the loop if it's being lost
		velocity.x = 50.0 * forward_multiplier
		await get_tree().process_frame
	
	# 5. Only stop if this is the latest jump
	if current_jump_id == jump_count:
		velocity.x = 0
		is_jumping = false

signal character_clicked

func climb():
	if current_ladder == null:
		return
	
	is_climbing = true
	play_sfx(sfx_climb)
	
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

# Update your _physics_process to respect the jump
func _physics_process(delta: float) -> void:
	if is_climbing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# THE FIX: Continuously save the position whenever we are safely on the floor
	if is_on_floor() and not is_jumping:
		last_safe_position = global_position

	# Standard gravity logic 
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Check if we fell off the map
	if global_position.y > FALL_THRESHOLD:
		play_sfx(sfx_dead)
		reset_to_last_safe_spot()
		
	# MODIFIED: Only handle movement if NOT in a controlled jump
	if not is_jumping:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func slide():
	play_sfx(sfx_slide)
	var forward = Vector2.RIGHT if right else Vector2.LEFT
	var slide_distance = 100 # Adjust based on your tile size
	var target_pos = position + (forward * slide_distance)
	
	# 1. Shrink collision to pass through small gaps
	# Assuming your CollisionShape2D is a RectangleShape2D
	var original_size = $CollisionShape2D.shape.size
	$CollisionShape2D.shape.size.y = original_size.y / 2
	position.y += original_size.y / 4 # Shift down to stay on floor
	
	# 2. Animate the slide move
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.8)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	# 3. Restore collision size
	$CollisionShape2D.shape.size = original_size
	position.y -= original_size.y / 4

func punch():
	play_sfx(sfx_punch)
	var forward = Vector2.RIGHT if right else Vector2.LEFT
	
	# 1. Visual Lunge
	var tween = create_tween()
	tween.tween_property(self, "position", position + (forward * 10), 0.1)
	tween.tween_property(self, "position", position, 0.1)
	
	# 2. Get the RayCast
	var ray = get_node_or_null("PunchRay") 
	if ray != null:
		# Short target so we only hit what is directly in front
		ray.target_position = Vector2(30 if right else -30, 0) 
		ray.force_raycast_update()
		
		if ray.is_colliding():
			var collider = ray.get_collider()
			# Check for TileMap or the newer TileMapLayer[cite: 2]
			if collider is TileMap or (ClassDB.class_exists("TileMapLayer") and collider is TileMapLayer):
				_break_vertical_stack(collider, ray.get_collision_point(), forward)
	
	await tween.finished

func _break_vertical_stack(tile_map, hit_pos: Vector2, forward: Vector2):
	# Tiny 1-pixel offset ensures we stay inside the tile we just hit[cite: 2]
	var internal_hit_pos = hit_pos + (forward * 1) 
	var map_pos = tile_map.local_to_map(tile_map.to_local(internal_hit_pos))
	
	var tiles_to_check = [
		map_pos,                  # The block at the hit point[cite: 2]
		map_pos + Vector2i(0, -1) # The block directly above it[cite: 2]
	]
	
	for pos in tiles_to_check:
		var tile_data = tile_map.get_cell_tile_data(0, pos)
		# Verify that 'is_breakable' is checked in your TileSet editor[cite: 2]
		if tile_data and tile_data.get_custom_data("is_breakable"):
			tile_map.erase_cell(0, pos)

func reset_to_last_safe_spot():
	var backward_direction = -1 if right else 1
	var offset = Vector2(backward_direction * 35, 0) 
	global_position = last_safe_position + offset
	velocity = Vector2.ZERO # Stop all falling momentum
	is_jumping = false      # Reset jump state if they fell during a jump
