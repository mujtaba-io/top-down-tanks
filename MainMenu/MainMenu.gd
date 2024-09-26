extends Control


@onready var ip_input = $VBoxContainer/IPInput


func _ready():
	PeersManager.peers_updated.connect(_on_peers_manager_peers_update)

func _on_create_server_pressed():
	PeersManager.create_server()
	get_tree().change_scene_to_file("res://Levels/Test.tscn")
	# TODO: Open lobby scene actually



func _on_create_client_pressed():
	PeersManager.join_server()
	# TODO: Open lobby scene actually



func _on_peers_manager_peers_update():
	print(PeersManager.peers)

