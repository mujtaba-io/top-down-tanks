extends Control


@export var human_player_scene: PackedScene
@export var player_scene: PackedScene
@export var tank_scenes: Array[PackedScene]

@onready var player_list : ItemList = $Panel/CenterContainer/VBoxContainer/PlayerList


# All player scene instances synced with PeersManager.peers
var this_player: HumanPlayer # Local player instance
var players: Array


func _ready():
	
	this_player = human_player_scene.instantiate()
	this_player.player_peer_id = multiplayer.get_unique_id()
	this_player.player_name = "Player Name"
	this_player.tank = tank_scenes[0].instantiate() # TODO: add tank dependencies
	
	players.append(this_player)
	
	PeersManager.peers_updated.connect(_on_peers_manager_peers_updated)
	if not multiplayer.is_server():
		$Panel/CenterContainer/VBoxContainer/StartGameButton.disabled = true




func _process(delta):
	# Synchronize connected players with the ItemList
	for player in players:
		var playerFound = false
		for i in range(player_list.item_count):
			if player_list.get_item_text(i).contains(player.player_name):
				playerFound = true
				break
		if not playerFound:
			player_list.add_item(player.player_name)
	
	# Remove disconnected players from the ItemList
	for i in range(player_list.item_count):
		var playerName = player_list.get_item_text(i)
		var playerExists = false
		for player in players:
			if playerName.contains(player.player_name):
				playerExists = true
				break
		if not playerExists:
			player_list.remove_item(i)
			i -= 1



func _on_leave_button_pressed():
	multiplayer.multiplayer_peer = null
	PeersManager.peers.clear() #$ Happens automatically when disconnected
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")


func _on_start_game_button_pressed():
	if multiplayer.is_server():
		start_game.rpc()



func _on_peers_manager_peers_updated():
	for peer_id in PeersManager.peers:
		broadcast_player.rpc_id(
			peer_id,
			this_player.player_peer_id,
			this_player.player_name,
			this_player.tank.scene_file_path
		)


#>
#>
#>



@rpc("call_local", "any_peer")
func broadcast_player(
	player_id: int, # Peer RPC ID of this player
	player_name: String,
	tank_scene_path: String
	):
	# Check if player already exists, then just update its variables, else create a new player
	var player: Player
	for p in players:
		if p.player_peer_id == player_id:
			player = p
			break
	if player == null:
		player = player_scene.instantiate()
		player.player_peer_id = player_id
		player.player_name = player_name
		player.tank = tank_scenes[0].instantiate() # TODO: add tank dependencies
		players.append(player)
	else:
		player.player_name = player_name
		player.tank = tank_scenes[0].instantiate() # TODO: add tank dependencies




@rpc("call_local")
func start_game():
	var level = SceneManager.load_scene("res://Levels/Test.tscn")
	level.this_player = this_player
	level.players = players
	SceneManager.switch_scene(level)
