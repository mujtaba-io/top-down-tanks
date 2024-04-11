extends Node2D

var tank_scene = preload("res://tiger.tscn")

var world

# Called when the node enters the scene tree for the first time.
func _ready():
	world = get_tree().root.get_node("world")
	global.world = world
	
	instance_player.rpc()
	global.player_loaded.rpc_id(1)
	
	# make human player control tank if it is same computer
	var player = world.get_node(str(multiplayer.multiplayer_peer.get_unique_id()))
	player.set_player_control()
	
	
	#######3333333333333333333333333333
	global.player_connected.connect(on_player_connected)
	global.player_disconnected.connect(on_player_disconnected)
	global.server_disconnected.connect(on_server_disconnected)

# there 3 functions are unstable and should not be added without addressing
# whole thing related to player connection management
func on_player_connected(peer_id, player_info):
	pass
func on_player_disconnected(peer_id):
	world.get_node(str(peer_id)).queue_free()
func on_server_disconnected():
	pass
#######3333333333333333333333333333

func start_game():
	pass

@rpc("any_peer", "call_local", "reliable")
func instance_player():
	var tank = tank_scene.instantiate()
	var tank_name := str(multiplayer.get_remote_sender_id())
	tank.name = tank_name
	tank.position = Vector2(randf_range(-20, 128), randf_range(-20, 128))
	world.add_child(tank, true)
	tank.add_to_group("tanks")
	print("LOADEDDDDDDDDDDDDDDDDDDDDDD " + tank_name)
