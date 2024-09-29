extends Control


@export var human_player_scene: PackedScene
@export var player_scene: PackedScene
@export var tank_scenes: Array[PackedScene]


@onready var player_name_edit: LineEdit = $PlayerNameEdit

@onready var player_list : ItemList = $Panel/CenterContainer/VBoxContainer/PlayerList
@onready var country_list : ItemList = $CountryList

# All player scene instances synced with PeersManager.peers
var this_player: HumanPlayer # Local player instance
var players: Array


func _ready():
	
	this_player = human_player_scene.instantiate()
	this_player.name = str(multiplayer.get_unique_id()) # Node name
	this_player.player_peer_id = multiplayer.get_unique_id()
	this_player.player_name = "Unnamed Player"
	this_player.tank = tank_scenes[0].instantiate() # TODO: add tank dependencies
	
	players.append(this_player)
	
	PeersManager.peers_updated.connect(_on_peers_manager_peers_updated)
	
	if not multiplayer.is_server():
		$Panel/CenterContainer/VBoxContainer/StartGameButton.disabled = true
	
	# Broadcast overselve after connecting
	broadcast_player.rpc(
		this_player.player_peer_id,
		this_player.player_name,
		this_player.tank.scene_file_path
	)
	
	
	# Fill country list with tank scene names
	country_list.clear()
	for tank_scene in tank_scenes:
		var tmp_tank = tank_scene.instantiate() as Tank
		var country: String = str(tmp_tank.Country.keys()[tmp_tank.country])
		var country_icon: Texture2D = tmp_tank.country_icon
		country_list.add_item(
			country,
			country_icon
		)
		tmp_tank.free()
		
	
	# Auto select first item
	country_list.select(0)



func _process(delta):
	# Synchronize connected players with the ItemList
	# CLear al the items
	player_list.clear()
	# Add all the players
	for player in players:
		player_list.add_item(player.player_name + " (" + str(player.tank.Country.keys()[player.tank.country]) + ")")



func _on_leave_button_pressed():
	multiplayer.multiplayer_peer = null
	PeersManager.peers.clear() #$ Happens automatically when disconnected
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")


func _on_start_game_button_pressed():
	if multiplayer.is_server():
		start_game.rpc()



func _on_peers_manager_peers_updated():
	# Remove disconnected players
	for player in players:
		var playerFound = false
		for peer_id in PeersManager.peers:
			if player.player_peer_id == peer_id:
				playerFound = true
				break
		if not playerFound:
			players.erase(player)
			player.tank.queue_free()
			player.queue_free()
	
	# And broadcast ourself so we get added to other machines
	broadcast_player.rpc(
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
		player.name = str(player_id) # Node name
		player.player_peer_id = player_id
		player.player_name = player_name
		player.tank = tank_scenes[0].instantiate() # TODO: add tank dependencies
		players.append(player)
	else:
		player.player_name = player_name
		player.tank.free() # Free older tank
		player.tank = load(tank_scene_path).instantiate() # TODO: add tank dependencies




@rpc("call_local")
func start_game():
	var level = SceneManager.load_scene("res://Levels/Test.tscn")
	level.this_player = this_player
	level.players = players
	SceneManager.switch_scene(level)


func _on_player_name_edit_text_changed(new_text):
	broadcast_player.rpc(
		this_player.player_peer_id,
		new_text,
		this_player.tank.scene_file_path
	)


func _on_countries_list_item_selected(index):
	var tank_scene_path = tank_scenes[index].resource_path
	
	broadcast_player.rpc(
		this_player.player_peer_id,
		this_player.player_name,
		tank_scene_path # Broadcast new tank scene path
	)
