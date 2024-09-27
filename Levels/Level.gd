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
		if player.player_peer_id == multiplayer.get_unique_id():
			continue # As it is `this_player` so handled separately
		self.add_child(player)
	
	# Randomize positions
	for player in players:
		player.position = Vector2(randf_range(0, 100), randf_range(0, 100))




func _on_peers_manager_peers_updated():
	pass # todo: update players as we did in lobby
