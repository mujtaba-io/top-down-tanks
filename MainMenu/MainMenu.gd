extends Control


@export var lobby_scene: PackedScene

@onready var ip_input = $VBoxContainer/IPInput


func _ready():
	PeersManager.peers_updated.connect(_on_peers_manager_peers_update)

func _on_create_server_pressed():
	PeersManager.create_server()
	get_tree().change_scene_to_packed(lobby_scene)
	# TODO: Open lobby scene actually



func _on_create_client_pressed():
	PeersManager.join_server()
	get_tree().change_scene_to_packed(lobby_scene)



func _on_peers_manager_peers_update():
	pass

