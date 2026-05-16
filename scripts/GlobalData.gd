extends Node

# This variable will hold your commands even after the level ends
var last_run_commands: Array[String] = []
var full_gameplay_history = [] # All commands used across the level

var selected_character := "MIDORI"

func add_to_history(new_commands: Array):
	full_gameplay_history.append_array(new_commands)

func clear_history():
	full_gameplay_history.clear()
