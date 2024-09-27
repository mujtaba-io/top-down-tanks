extends Node2D
class_name Player

@export var player_peer_id: int # RPC ID associated
@export var player_name: String
@export var tank: Tank

@export var kills: int


func _ready():
	if tank not in get_children():
		add_child(tank)

func _physics_process(delta):
	pass

