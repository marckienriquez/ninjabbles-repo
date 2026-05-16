extends Control

@onready var loading_bar: TextureProgressBar = $TextureProgressBar
@onready var label: Label = $Label
@onready var runner: AnimatedSprite2D = $AnimatedSprite2D

var dot_count := 0

func _ready():
	runner.play("default")
	start_loading()
	animate_text()

func start_loading():
	loading_bar.value = 0
	set_runner_position(0)
	fill_step()

func fill_step():
	if loading_bar.value >= 100:
		_on_loading_finished()
		return

	var current_value = loading_bar.value
	var next_value = min(current_value + randi_range(5, 15), 100)

	var tween = create_tween()
	tween.tween_property(loading_bar, "value", next_value, 0.6)
	tween.parallel().tween_method(set_runner_position, current_value, next_value, 0.6)

	tween.finished.connect(fill_step)

func set_runner_position(value: float):
	var percent = value / 100.0

	var start_x = loading_bar.global_position.x
	var end_x = loading_bar.global_position.x + loading_bar.size.x

	runner.global_position.x = lerp(start_x, end_x, percent)
	
	if value >= 95:
		runner.hide()
	else:
		runner.show()

	# inside the bar vertically
	runner.global_position.y = loading_bar.global_position.y + loading_bar.size.y / 2

func animate_text():
	while true:
		await get_tree().create_timer(0.7).timeout
		
		dot_count = (dot_count + 1) % 4
		var dots = ".".repeat(dot_count)
		label.text = "DOWNLOADING CONTENT" + dots

func _on_loading_finished():
	get_tree().change_scene_to_file("res://scene/main_scrn/main_screen.tscn")
