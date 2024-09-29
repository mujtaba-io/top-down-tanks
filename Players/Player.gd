extends Node
class_name Player

@export var player_peer_id: int # RPC ID associated
@export var player_name: String
@export var tank: Tank

@export var kills: int


signal death
var is_dead = false


func _ready():
	add_to_group("players")
	if tank not in get_children():
		add_child(tank)
	
	death.connect(_on_death)


func _process(delta):
	pass

func _physics_process(delta):
	pass



func _on_death():
	if not is_dead:
		is_dead = true
		# Set death anim timer
		# Schedule re-spawn (reset of variables) after animation played
		# For now, just reset variables and respawn:
		# TODO NEEDS THINKING THO
	else:
		print("Error: Death signal called on already dead tank.")
