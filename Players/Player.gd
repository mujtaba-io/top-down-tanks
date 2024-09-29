extends Node
class_name Player

@export var player_peer_id: int # RPC ID associated
@export var player_name: String
@export var tank: Tank

@export var kills: int


func _ready():
	if tank not in get_children():
		add_child(tank)


func _process(delta):
	pass

func _physics_process(delta):
	pass




#>
#>
#>



@rpc("any_peer", "call_remote")
func broadcast_player_state(
	tank_pos, tank_rot, turret_rot
):
	if multiplayer.get_remote_sender_id() == player_peer_id:
		tank.global_position = tank_pos
		tank.global_rotation = tank_rot
		tank.turret.global_rotation = turret_rot
	
