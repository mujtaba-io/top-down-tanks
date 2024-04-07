extends CharacterBody2D

var bullet_scene = preload("res://bullet.tscn")

var world

var speed : float = 0
var turret

var health: int = 100
signal reduce_health(amount: int)


var is_player_control: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	world = get_tree().root.get_node("world")
	turret = $body/turret
	
	reduce_health.connect(on_reduce_health)

func on_reduce_health(amount: int):
	self.health -= amount
	if health <= 0:
		print("died")
		queue_free() # TODO: propagate death to all players

func player_control(delta):
	if Input.is_action_pressed("ui_up"):
		speed -= delta * 64
	if Input.is_action_pressed("ui_up"):
		speed -= delta * 64
	if Input.is_action_pressed("ui_down"):
		speed += delta * 64
	if Input.is_action_pressed("ui_right"):
		global_rotation += deg_to_rad(delta*128)
	if Input.is_action_pressed("ui_left"):
		global_rotation -= deg_to_rad(delta*128)
	
	if Input.is_action_just_pressed("ui_home"):
		instance_bullet.rpc()
	
	move_and_collide(speed * global_transform.y * delta)
	speed -= speed * delta
	
	turret.global_rotation = lerp_angle(turret.global_rotation, get_global_mouse_position().angle_to_point(global_position) - PI / 2, 0.05)
	
	
	update_pos_rot.rpc(global_position, global_rotation, turret.global_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_player_control: # is a local keyboard player (not remote), then dont attach input with him
		player_control(delta)


@rpc("any_peer", "call_remote", "reliable")
func update_pos_rot(new_position, new_rotation, turret_rotation):
	var sender_name := str(multiplayer.get_remote_sender_id())
	var sender_node = world.get_node(sender_name)
	sender_node.global_position = new_position
	sender_node.global_rotation = new_rotation
	sender_node.turret.global_rotation = turret_rotation
	#print("updating posrot of " + sender_name + " by " + str(multiplayer.multiplayer_peer.get_unique_id()) + " to pos: " + str(global_position))


@rpc("any_peer", "call_local", "reliable")
func instance_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.set_bullet_pos_dir_who_fired(global_position, turret.global_rotation, self)
	world.add_child(bullet)
	print("bulleet loaded")
