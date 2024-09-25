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
var peers: Array # Array[int] - Array of peer IDs



# API signals:
# Whenever a peer joins or leaves, we get a signal emit, so we can
# update state based on peers array
signal peers_updated



func _ready():
	# Both server & clients emit it
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Client-specific emit only
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_server_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Return null on success
func create_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	peers.append(1) # Add server's peer_id by default which is 1
	return null


# Return null on success
func join_server(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	peer.get_peer(1).set_timeout(0, 0, 5000)  # 5 seconds max timeout
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	return null


## RELATED TO EXTERNAL INCOMING CONNECTIONS:


# If any peer (both server & client) connected. What should we do?
func _on_peer_connected(id: int):
	if not peers.has(id):
		peers.append(id)
	
	# if we are server, then broadcast new peer to all existing peers
	if multiplayer.is_server():
		broadcast_peers.rpc(peers)
	
	print("peer_connected")



# If any peer (both server & client) disconnected. What should we do?
func _on_peer_disconnected(id: int):
	if peers.has(id):
		peers.erase(id)
	
	# if we are server, then remove this peer from all existing peers
	if multiplayer.is_server():
		broadcast_peers.rpc(peers)


## RELATED TO OUR OWN STATE WITH THE SERVER (WE ARE CLIENT):


# If WE are connected to server. What should we do?
func _on_connected_to_server():
	#var local_peer_id = multiplayer.get_unique_id()
	#if not peers.has(local_peer_id):
	#	peers.append(local_peer_id)
	print('i am connected to server')



# If OUR connection to server fail. What should we do?
func _on_server_connection_failed():
	#var local_peer_id = multiplayer.get_unique_id()
	#if peers.has(local_peer_id):
	#	peers.erase(local_peer_id)
	peers.clear()
	multiplayer.multiplayer_peer = null



# If WE disconnect from server. What should we do?
func _on_server_disconnected():
	peers.clear()
	multiplayer.multiplayer_peer = null



##
##
##



# is_adding=true means add to peers, false means remove from peers
@rpc("call_local")
func broadcast_peers(updated_peers: Array): # Array[int] causes bug in Godot
	peers = updated_peers
	peers_updated.emit()
