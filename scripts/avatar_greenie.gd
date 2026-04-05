extends CharacterBody2D

var right: bool = true  # true = facing right, false = facing left

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

func move_in_direction(dir: Vector2):
	var tween = create_tween()
	tween.tween_property(self, "position", position + dir * 16, 0.4)
	await tween.finished

func jump():
	while not is_on_floor():
		await get_tree().process_frame
	var forward = Vector2.RIGHT if right else Vector2.LEFT
	var arc = position + Vector2(forward.x * 16, -16)
	var tween = create_tween()
	tween.tween_property(self, "position", arc, 0.2)
	await tween.finished

signal character_clicked

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("character_clicked")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
