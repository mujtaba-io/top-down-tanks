# Autoload
extends Node


const PORT = 53463
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 16



# No peer data is saved. After peers are connected
# and relevant signals connected, both sides' scenes
# will listen to the signals and instantiate relevant
# nodes (such as Player, Tank, etc) based on later
# RPC calls in the relevant scenes...

# Tho, other scenes will also not directly call rpc,
# but outsource them to base NetworkNode.
var peers: Array[int] # Array of peer IDs



# API signals:
signal player_connected
signal player_disconnected # ???


func _ready():
	# Both server & clients emit it
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Client-specific emit only
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_server_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)



func _on_peer_connected(id: int):
	if not peers.has(id):
		peers.append(id)



func _on_peer_disconnected(id: int):
	if peers.has(id):
		peers.erase(id)



func _on_connected_to_server():
	var local_peer_id = multiplayer.get_unique_id()
	if not peers.has(local_peer_id):
		peers.append(local_peer_id)
	# todo: broadcast TO ALL OTHER PLAYERS



func _on_server_connection_failed():
	var local_peer_id = multiplayer.get_unique_id()
	if peers.has(local_peer_id):
		peers.erase(local_peer_id)
	multiplayer.multiplayer_peer = null



func _on_server_disconnected():
	peers.clear()
	multiplayer.multiplayer_peer = null


