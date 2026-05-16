extends Node2D

@onready var editor = $CanvasLayer/BlockEditor
@onready var summary = $CanvasLayer/Summary
@onready var instructions = $CanvasLayer/Instructions

func _ready():
	$avatar_greenie.connect("character_clicked", self._on_character_clicked)
	$CanvasLayer/BlockEditor/CloseEditorButton.connect("pressed", self._on_button_pressed)
	$CanvasLayer/BlockEditor/RunButton.connect("pressed", self._on_button_pressed)
	$CanvasLayer/Instructions/CloseInstructionsButton.connect("pressed", self._on_instructions_button_pressed)
	$CanvasLayer/Summary/summary_screen/CloseSummaryButton.connect("pressed", self._on_summary_button_pressed)

func _on_character_clicked():
	editor.visible = true

func _on_button_pressed() -> void:
	editor.visible = false
	
func _on_summary_button_pressed() -> void:
	summary.visible = false

func _on_instructions_button_pressed() -> void:
	instructions.visible = false
