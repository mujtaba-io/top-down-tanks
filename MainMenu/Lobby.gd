extends Control


@export var human_player_scene: PackedScene
@export var player_scene: PackedScene
@export var tank_scenes: Array[Tank]

# Make a system to syn Player instances with the peers list

var players: Array

@rpc
func broadcast_player(_name: String, _tank_scene_path):
	pass
