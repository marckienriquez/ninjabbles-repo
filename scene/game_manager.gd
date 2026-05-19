extends Node2D

const game_settings_scene = preload("res://scene/game_settings.tscn")
@onready var settings = $CanvasLayer/settings
@onready var editor = $CanvasLayer/BlockEditor
@onready var summary = $CanvasLayer/Summary
@onready var instructions = $CanvasLayer/Instructions


func _ready():
	$avatar_greenie.connect("character_clicked", self._on_character_clicked)
	$CanvasLayer/BlockEditor/CloseEditorButton.connect("pressed", self._on_button_pressed)
	$CanvasLayer/BlockEditor/RunButton.connect("pressed", self._on_button_pressed)
	$CanvasLayer/Instructions/InstructionsTexture/CloseInstructionsButton.connect("pressed", self._on_instructions_button_pressed)
	$CanvasLayer/Summary/summary_screen/CloseSummaryButton.connect("pressed", self._on_summary_button_pressed)
	$CanvasLayer/settings.pressed.connect(_on_settings_pressed)

func _on_settings_pressed() -> void:
	var settings_popup = game_settings_scene.instantiate()
	$CanvasLayer.add_child(settings_popup)
	
func _on_character_clicked():
	editor.visible = true

func _on_button_pressed() -> void:
	editor.visible = false
	
func _on_summary_button_pressed() -> void:
	summary.visible = false

func _on_instructions_button_pressed() -> void:
	instructions.visible = false
