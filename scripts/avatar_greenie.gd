extends CharacterBody2D

var character_frames = {
	"MIDORI": preload("res://asset/sprites/midori_idle.tres"),
	"AO": preload("res://asset/sprites/ao_idle.tres"),
	"HANA": preload("res://asset/sprites/hana_idle.tres"),
	"MURASAKI": preload("res://asset/sprites/murasaki_idle.tres"),
	"FURUI": preload("res://asset/sprites/furui_idle.tres"),
	"WAKAI": preload("res://asset/sprites/wakai_idle.tres")
}

@onready var sfx_player: AudioStreamPlayer2D = $SfxPlayer

@export_group("Sound Effects")
@export var sfx_move: AudioStream
@export var sfx_jump: AudioStream
@export var sfx_climb: AudioStream
@export var sfx_slide: AudioStream
@export var sfx_punch: AudioStream
@export var sfx_dead: AudioStream

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
const JUMP_VELOCITY = -250.0

func _ready():
	add_to_group("character")
	last_safe_position = global_position
	apply_selected_character()

func apply_selected_character():
	var selected_name = GlobalData.selected_character

	if character_frames.has(selected_name):
		$AnimatedSprite2D.sprite_frames = character_frames[selected_name]
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

	var distance := 35.0
	var duration := 0.4
	var elapsed := 0.0
	var start_x := global_position.x
	var target_x := start_x + dir.x * distance

	while elapsed < duration:
		var delta := get_physics_process_delta_time()
		elapsed += delta

		var remaining_x := target_x - global_position.x
		var step_x := dir.x * (distance / duration) * delta

		if abs(step_x) > abs(remaining_x):
			step_x = remaining_x

		velocity.x = step_x / delta
		move_and_slide()

		if is_on_wall():
			break

		await get_tree().physics_frame

	velocity.x = 0

var jump_count: int = 0

func jump():
	play_sfx(sfx_jump)
	jump_count += 1
	var current_jump_id = jump_count
	is_jumping = true

	var forward_multiplier = 1 if right else -1

	velocity.y = JUMP_VELOCITY
	velocity.x = 10 * forward_multiplier

	for i in range(5):
		await get_tree().process_frame

	while not is_on_floor():
		velocity.x = 50.0 * forward_multiplier
		await get_tree().process_frame

	if current_jump_id == jump_count:
		velocity.x = 0
		is_jumping = false

signal character_clicked

func climb():
	if current_ladder == null:
		return

	is_climbing = true
	play_sfx(sfx_climb)

	while current_ladder != null:
		var ladder_top_y = current_ladder.global_position.y - current_ladder.ladder_height / 2.0
		var character_half_height = $CollisionShape2D.shape.size.y / 2.0

		while global_position.y - character_half_height > ladder_top_y:
			global_position.y -= 2
			await get_tree().process_frame

		await get_tree().process_frame

		if not is_on_new_ladder_segment():
			break

	is_climbing = false

func is_on_new_ladder_segment() -> bool:
	return current_ladder != null

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("avatar clicked")
			character_clicked.emit()

func _physics_process(delta: float) -> void:
	if is_climbing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_on_floor() and not is_jumping:
		last_safe_position = global_position

	if not is_on_floor():
		velocity += get_gravity() * delta

	if global_position.y > FALL_THRESHOLD:
		play_sfx(sfx_dead)
		reset_to_last_safe_spot()

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
	var slide_distance := 100.0
	var slide_speed := 180.0
	var moved := 0.0

	var original_size = $CollisionShape2D.shape.size
	$CollisionShape2D.shape.size.y = original_size.y / 2
	$CollisionShape2D.position.y += original_size.y / 4 

	# Change: The loop now keeps running if we are still under a ceiling!
	while moved < slide_distance or is_under_ceiling():
		await get_tree().physics_frame
		
		var delta := get_physics_process_delta_time()
		var step := slide_speed * delta

		# Only track the slide distance limit while we haven't reached it
		if moved < slide_distance:
			if moved + step > slide_distance:
				step = slide_distance - moved
			moved += step

		velocity.x = forward.x * slide_speed
		move_and_slide()

		if is_on_wall():
			break
		
	velocity.x = 0
	$CollisionShape2D.shape.size = original_size
	$CollisionShape2D.position.y -= original_size.y / 4

# Helper function to cast a quick ray upwards and see if the ceiling is clear
func is_under_ceiling() -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# Casts a ray from the avatar's center straight up by 25 pixels
	# Adjust the -25 up or down depending on how tall your full character is
	var query = PhysicsRayQueryParameters2D.create(
		global_position, 
		global_position + Vector2(0, -25), 
		1 # Assumes your TileMap environment is on Collision Layer 1
	)
	query.exclude = [get_rid()] # Don't clip against yourself
	
	var result = space_state.intersect_ray(query)
	return not result.is_empty() # Returns true if a tile is detected above

func punch():
	play_sfx(sfx_punch)

	var forward = Vector2.RIGHT if right else Vector2.LEFT

	var tween = create_tween()
	tween.tween_property(self, "position", position + (forward * 10), 0.1)
	tween.tween_property(self, "position", position, 0.1)

	var ray = get_node_or_null("PunchRay")

	if ray != null:
		ray.target_position = Vector2(30 if right else -30, 0)
		ray.force_raycast_update()

		if ray.is_colliding():
			var collider = ray.get_collider()

			if collider is TileMap or (ClassDB.class_exists("TileMapLayer") and collider is TileMapLayer):
				_break_vertical_stack(collider, ray.get_collision_point(), forward)

	await tween.finished

func _break_vertical_stack(tile_map, hit_pos: Vector2, forward: Vector2):
	var internal_hit_pos = hit_pos + (forward * 1)
	var map_pos = tile_map.local_to_map(tile_map.to_local(internal_hit_pos))

	var tiles_to_check = [
		map_pos,
		map_pos + Vector2i(0, -1)
	]

	for pos in tiles_to_check:
		var tile_data = tile_map.get_cell_tile_data(0, pos)

		if tile_data and tile_data.get_custom_data("is_breakable"):
			tile_map.erase_cell(0, pos)

func reset_to_last_safe_spot():
	var backward_direction = -1 if right else 1
	var offset = Vector2(backward_direction * 35, 0)

	global_position = last_safe_position + offset
	velocity = Vector2.ZERO
	is_jumping = false
