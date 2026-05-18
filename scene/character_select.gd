extends Node2D

@onready var big_sprite: AnimatedSprite2D = $Control/AnimatedSprite2D
@onready var char_name: Label = $Control/char_name
@onready var char_desc: Label = $Control/char_desc
@onready var in_use: Label = $Control/in_use

@onready var current_char: TextureButton = $Control/current_char
@onready var prev_char: TextureButton = $Control/prev_char
@onready var next_char: TextureButton = $Control/next_char

@onready var move_right: TextureButton = $Control/move_right
@onready var move_left: TextureButton = $Control/move_left
@onready var back_button: TextureButton = $Control/Back
@onready var play_button: TextureButton = $Control/Play

var current_index := 0

var characters = [
	{
		"name": "MIDORI",
		"desc": "Midori is a male, born on the 25th of November. Sagittarius. Utilizes his charming personality as bait and has fun delivering puns left and right. Despite being goofy, he’s the person everyone relies on first to have their back.",
		"frames": preload("res://asset/sprites/midori_idle.tres"),
		"icon": preload("res://asset/others/midori.png")
	},
	{
		"name": "AO",
		"desc": "Ao is a male, born on the 12th of August. Leo. He is the more strategic one out of all, always having contingency plans for situations. Mostly aloof with a sense of humor. Unexpectedly writes poetry as a hobby.",
		"frames": preload("res://asset/sprites/ao_idle.tres"),
		"icon": preload("res://asset/others/ao.png")
	},
	{
		"name": "HANA",
		"desc": "Hana is a female, born on the 7th of June. Gemini. Provides the steady optimism the group needs to carry on in each of their roles. Friendly and cheerful.",
		"frames": preload("res://asset/sprites/hana_idle.tres"),
		"icon": preload("res://asset/others/hana.png")
	},
	{
		"name": "MURASAKI",
		"desc": "Murasaki is a female, born on the 19th day of February. Pisces. Possesses the natural ability to lead the group with her rational mind. Calm and open-minded, always acknowledging every member’s opinion.",
		"frames": preload("res://asset/sprites/murasaki_idle.tres"),
		"icon": preload("res://asset/others/murasaki.png")
	},
	{
		"name": "FURUI",
		"desc": "Furui sensei is considered one of the top-ranking ninjas in “The Clan,” tasked with leading and guiding the rookies towards their success in the mission. Imparts wisdom that the group hangs on to.",
		"frames": preload("res://asset/sprites/furui_idle.tres"),
		"icon": preload("res://asset/others/furui.png")
	},
	{
		"name": "WAKAI",
		"desc": "Wakai sensei is a ninja who is a few years older than the rookies. He is assigned as a second-in-command to watch over the group in case anything goes wrong.",
		"frames": preload("res://asset/sprites/wakai_idle.tres"),
		"icon": preload("res://asset/others/wakai.png")
	}
]

func _ready():
	move_right.pressed.connect(_on_move_right_pressed)
	move_left.pressed.connect(_on_move_left_pressed)
	next_char.pressed.connect(_on_next_char_pressed)
	prev_char.pressed.connect(_on_prev_char_pressed)
	current_char.pressed.connect(_on_current_char_pressed)
	back_button.pressed.connect(_on_back_pressed)
	play_button.pressed.connect(_on_play_pressed)

	update_character()

func update_character():
	var selected = characters[current_index]

	var prev_index = (current_index - 1 + characters.size()) % characters.size()
	var next_index = (current_index + 1) % characters.size()

	char_name.text = selected["name"]
	char_desc.text = selected["desc"]

	if GlobalData.selected_character == selected["name"]:
		in_use.text = "SELECTED"
	else:
		in_use.text = ""

	big_sprite.sprite_frames = selected["frames"]
	big_sprite.play("idle")

	current_char.texture_normal = selected["icon"]
	prev_char.texture_normal = characters[prev_index]["icon"]
	next_char.texture_normal = characters[next_index]["icon"]

func next_character():
	current_index = (current_index + 1) % characters.size()
	update_character()

func previous_character():
	current_index = (current_index - 1 + characters.size()) % characters.size()
	update_character()

func _on_move_right_pressed():
	next_character()

func _on_move_left_pressed():
	previous_character()

func _on_next_char_pressed():
	next_character()

func _on_prev_char_pressed():
	previous_character()

func _on_current_char_pressed():
	pass

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/main_scrn/main_screen.tscn")

func _on_play_pressed():
	GlobalData.selected_character = characters[current_index]["name"]
	update_character()
	get_tree().change_scene_to_file("res://scene/easy_screen.tscn")
