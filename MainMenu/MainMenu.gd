extends Control



func _on_create_server_pressed():
	PeersManager.create_server()



func _on_create_client_pressed():
	PeersManager.join_server()
