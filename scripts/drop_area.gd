extends VBoxContainer

func can_drop_data(position, data):
	return data is Dictionary and data.has("block_text")

func drop_data(position, data):
	var block = data  # data is the clone Panel
	block.get_parent().remove_child(block)
	add_child(block)
	# Reset position so VBoxContainer can lay it out
	block.position = Vector2.ZERO

func _get_insert_index(y: float) -> int:
	for i in get_child_count():
		var child = get_child(i)
		if y < child.position.y + child.size.y * 0.5:
			return i
	return get_child_count()
