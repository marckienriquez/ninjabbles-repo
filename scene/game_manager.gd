extends Node2D

@onready var panel = $CanvasLayer/BlockEditor

func _ready():
	$avatar_greenie.connect("character_clicked", self._on_character_clicked)
	$CanvasLayer/BlockEditor/CloseEditorButton.connect("pressed", self._on_button_pressed)
	$CanvasLayer/BlockEditor/RunButton.connect("pressed", self._on_button_pressed)

func _on_character_clicked():
	panel.visible = true


func _on_button_pressed() -> void:
	panel.visible = false
