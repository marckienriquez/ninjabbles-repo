extends Control

@onready var tab_container: TabContainer = $scroll/TabContainer
@onready var prev_button: TextureButton = $scroll/prev_btn
@onready var next_button: TextureButton = $scroll/next_btn
func _ready() -> void:
	# Start on the first manual slide layout
	tab_container.current_tab = 0
	update_arrow_visibility()

func update_arrow_visibility() -> void:
	# Hide left arrow on the first page, hide right arrow on the last page
	prev_button.visible = (tab_container.current_tab > 0)
	next_button.visible = (tab_container.current_tab < tab_container.get_child_count() - 1)

# Connect this to your next_btn's pressed() signal
func _on_next_btn_pressed() -> void:
	if tab_container.current_tab < tab_container.get_child_count() - 1:
		tab_container.current_tab += 1
		update_arrow_visibility()

# Connect this to your prev_btn's pressed() signal
func _on_prev_btn_pressed() -> void:
	if tab_container.current_tab > 0:
		tab_container.current_tab -= 1
		update_arrow_visibility()

# Connect this to your close_btn's pressed() signal
func _on_close_btn_pressed() -> void:
	# Removes the instruction overlay pop-up and reveals the menu below
	queue_free()
