extends Area2D

@export var ladder_height: int = 64  # Match your tile size multiples

@onready var top_collision = $TopCollision

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("character"):
		print("Entered ladder: ", body.name)
		body.on_ladder = true
		body.current_ladder = self

func _on_body_exited(body: Node2D):
	if body.is_in_group("character"):
		body.on_ladder = false
		# ONLY clear if this specific ladder is the one the player is tracking
		if body.current_ladder == self:
			body.current_ladder = null

func _update_top_collision(body: Node2D):
	# Enable top collision only when character is above the ladder top
	var ladder_top_y = global_position.y - ladder_height / 2
	top_collision.get_node("CollisionShape2D").disabled = body.global_position.y > ladder_top_y
