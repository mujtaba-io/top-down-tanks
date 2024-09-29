extends Node
class_name Player

@export var player_peer_id: int # RPC ID associated
@export var player_name: String
@export var tank: Tank

@export var kills: int = 0
@export var died_count: int = 0


signal death
var is_dead = false
const MAX_DEATH_TIMER := 4.0
var death_timer := MAX_DEATH_TIMER

signal respawn(player: Player) # Whom to respawn (signal for Level node)


func _ready():
	add_to_group("players")
	if tank not in get_children():
		add_child(tank)
	
	death.connect(_on_death)


func _process(delta):
	if is_dead:
		death_timer -= delta
		tank.visible = false
		if death_timer < 0:
			is_dead = false
			death_timer = MAX_DEATH_TIMER
			tank.visible = true
			tank.health = 100
			respawn.emit(self)
			if player_peer_id == multiplayer.get_unique_id():
				get_tree().get_nodes_in_group("levels")[0].players_panel.visible = false




func _physics_process(delta):
	pass



func _on_death():
	if not is_dead:
		is_dead = true
		died_count += 1
		if player_peer_id == multiplayer.get_unique_id():
			get_tree().get_nodes_in_group("levels")[0].players_panel.visible = true
	else:
		print("Error: Death signal called on already dead tank.")
