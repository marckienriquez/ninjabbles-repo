extends Panel

@onready var retry = $RetryButton
@onready var label = $TimerTexture/Label
@onready var timer = $TimerTexture/Label/Timer

# Add a variable to hold the final time recorded before stopping
var final_time_saved: float = 0.0
var is_timer_active: bool = false

func _ready():
	var button = get_node("../Instructions/InstructionsTexture/CloseInstructionsButton")
	button.pressed.connect(_on_instructions_button_pressed)
	
	var summaryScreen = get_node("../Summary/summary_screen")
	summaryScreen.visibility_changed.connect(_on_summary_visibility_change)
	
	timer.timeout.connect(_on_timer_timeout)
	retry.pressed.connect(_on_retry_pressed)

func _on_instructions_button_pressed():
	self.show()
	timer.start()
	is_timer_active = true # Track that the timer is now running

func _on_timer_timeout():
	retry.show()
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	is_timer_active = false

func _on_summary_visibility_change():
	# 1. SAVE the time remaining FIRST while it's still running!
	final_time_saved = timer.time_left
	
	# 2. Stop tracking in _process and stop the timer
	is_timer_active = false
	timer.stop()
	
	self.visible = false

func _process(_delta):
	# ONLY update the label if the timer is supposed to be running
	if not is_timer_active:
		return
		
	var time_left = timer.time_left
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	label.text = "%02d:%02d" % [minutes, seconds]

func _on_retry_pressed():
	get_tree().reload_current_scene()
