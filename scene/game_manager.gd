extends Node2D

func _ready():
	$avatar_greenie.connect("character_clicked", self._on_character_clicked)

func _on_character_clicked():
	$CanvasLayer/Panel.visible = true
