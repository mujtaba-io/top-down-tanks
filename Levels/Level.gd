extends Node
class_name Level


@export var human_player_scene: PackedScene


var this_player: HumanPlayer
var players: Array # Array[Player]


func _ready():
	add_to_group('levels')
	PeersManager.peers_updated.connect(_on_peers_manager_peers_updated)
	
	
	self.add_child(this_player)
	
	for player in players:
		if player == this_player:
			continue
		self.add_child(player)
	
	# Randomize positions
	for player in players:
		player.tank.position = Vector2(1, 1) * randf_range(0, 100)



func _on_peers_manager_peers_updated():
	pass # todo: update players as we did in lobby
