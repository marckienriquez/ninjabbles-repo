extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

# easy_end.gd 
func _on_body_entered(body):
	if body.is_in_group("character"):
		# Try to find the node by script type if the name changed
		var summary = get_tree().current_scene.find_child("summary_screen", true, false)
		
		# If it's still not found, try the other name you used
		if not summary:
			summary = get_tree().current_scene.find_child("Summary", true, false)

		if summary:
			summary.visible = true 
			if summary.has_method("display_code"):
				summary.display_code()
		else:
			print("Error: Could not find the Summary node in the scene!")
			
			# Optional: Hide the coding blocks so it's not cluttered
			var editor = get_tree().current_scene.find_child("BlockEditor", true, false)
			if editor:
				editor.visible = false
