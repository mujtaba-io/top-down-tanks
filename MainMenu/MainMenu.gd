extends Control


func _ready():
	PeersManager.peers_updated.connect(_on_peers_manager_peers_update)


func _on_create_server_pressed():
	PeersManager.create_server()



func _on_create_client_pressed():
	PeersManager.join_server()



func _on_peers_manager_peers_update():
	print(PeersManager.peers)
