extends Panel

@onready var retry = $RetryButton
@onready var label = $TimerTexture/Label
@onready var timer = $TimerTexture/Label/Timer # Adjust path to your Timer node

func _ready():
	# ".." goes up to ParentNode, then we go down into the sibling
	var button = get_node("../Instructions/InstructionsTexture/CloseInstructionsButton")
	button.pressed.connect(_on_instructions_button_pressed)
	
	var summaryScreen = get_node("../Summary/summary_screen")
	summaryScreen.visibility_changed.connect(_on_summary_visibility_change)
	
	# Connect the Timer's timeout signal to show the retry button
	timer.timeout.connect(_on_timer_timeout)
	retry.pressed.connect(_on_retry_pressed)

func _on_instructions_button_pressed():
	self.show()
	timer.start()

func _on_timer_timeout():
	# This runs exactly when the timer reaches 0
	retry.show()
	self.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_summary_visibility_change():
	timer.stop()
	self.visible = false

func _process(_delta):
	var time_left = timer.time_left
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	# %02d means: format as an integer, at least 2 digits wide, padded with zeros
	label.text = "%02d:%02d" % [minutes, seconds]

func _on_retry_pressed():
	# Reloads the currently active scene from scratch
	get_tree().reload_current_scene()
