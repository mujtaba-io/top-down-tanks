extends CharacterBody2D

var bullet_scene = preload("res://bullet.tscn")

var world

const MAX_SPEED: float = 64
const ROTATION_SPEED: float = 200

var speed : float = 0
var turret

var health: int = 100
signal reduce_health(amount: int)

var camera: Camera2D
var is_player_control: bool = false


var team: String

var player_info: Control
var team_color: TextureRect
var health_bar: TextureProgressBar

var is_dead = false
var death_timer: float = 3

var score: int = 0
var score_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	world = get_tree().root.get_node("world")
	turret = $body/turret
	
	team = global.players[multiplayer.get_remote_sender_id()]["team"]
	
	player_info = $info
	team_color = $info/team_color
	health_bar = $info/health_bar
	(team_color as TextureRect).modulate = Color.RED if team == "red" else Color.BLUE
	health_bar.value = health # players[id]["health"]???
	
	reduce_health.connect(on_reduce_health)
	
	score = 0
	score_label = $ui/score

# Make player control the player
func set_player_control():
	is_player_control = true
	camera = Camera2D.new()
	camera.zoom = Vector2(2.5,2.5)
	camera.enabled = true
	add_child(camera)
	$body/turret/indicator_line.visible = true
	
	$ui.visible = true

# both rpc and a signal callback
@rpc("any_peer", "call_local", "unreliable")
func on_reduce_health(amount: int):
	self.health -= amount
	health_bar.value = self.health
	world.get_node("ui").get_node("log").text += "\n"+str(multiplayer.get_unique_id())+" health reduced"
	if self.health <= 0:
		died.rpc()
		print("died")

@rpc("any_peer", "call_local", "unreliable")
func died():
	var who = world.get_node(str(multiplayer.get_remote_sender_id()))
	if who.health <= 0:
		who.visible = false
		who.is_dead = true
		who.is_player_control = false

############
var shake_timer=0.1
var camera_shake = false
func shake_camera(delta):
	if camera_shake:
		if shake_timer < 0:
			camera_shake = false
			shake_timer = 0.1
			camera.offset = Vector2(0,0)
		else:
			camera.offset = Vector2(randf_range(-1, 1),randf_range(-1, 1))
			shake_timer -= delta
#############

func player_control(delta):
	if Input.is_action_pressed("ui_up"):
		speed -= delta * MAX_SPEED
	if Input.is_action_pressed("ui_up"):
		speed -= delta * MAX_SPEED
	if Input.is_action_pressed("ui_down"):
		speed += delta * MAX_SPEED
	if Input.is_action_pressed("ui_right"):
		global_rotation += deg_to_rad(delta*ROTATION_SPEED)
	if Input.is_action_pressed("ui_left"):
		global_rotation -= deg_to_rad(delta*ROTATION_SPEED)
	
	if Input.is_action_just_pressed("mouse_left_click"):
		instance_bullet.rpc()
		camera_shake = true
	
	move_and_collide(speed * global_transform.y * delta)
	speed -= speed * delta
	
	turret.global_rotation = lerp_angle(turret.global_rotation, get_global_mouse_position().angle_to_point(global_position) - PI / 2, 0.08)
	
	
	update_pos_rot.rpc(global_position, global_rotation, turret.global_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_player_control: # is a local keyboard player (not remote), then dont attach input with him
		player_control(delta)
	shake_camera(delta)
	
	$engine_sound.pitch_scale = 0.5 if (abs(speed) / MAX_SPEED) < 0.5 else (abs(speed) / MAX_SPEED)
	
	# keep healthbar, and team icon irrespective of tank rotation
	player_info.rotation = -self.global_rotation
	player_info.global_position = self.global_position
	
	if is_dead:
		visible = false
		if death_timer < 0:
			death_timer = 3
			respawn.rpc()
			is_dead = false
		else:
			death_timer -= delta

@rpc("any_peer", "call_local", "reliable")
func respawn():
	var who = world.get_node(str(multiplayer.get_remote_sender_id()))
	if who.health <= 0:
		who.is_dead = false
		who.visible = true
		who.health = 100
		who.health_bar.value = who.health
		if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
			who.is_player_control = true

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
	bullet.set_bullet_pos_dir_who_fired(global_position + (-turret.global_transform.y * 23), turret.global_rotation, self)
	world.add_child(bullet)
	print("bulleet loaded")
	
	$fire_sound.play()
