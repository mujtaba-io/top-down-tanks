extends Player
class_name HumanPlayer


@export var camera: Camera2D


func _ready():
	super()
	add_to_group("human_players")
	camera.reparent(tank) # So camera moves with tank
	camera.make_current()


func _physics_process(delta):
	super(delta)
	
	if Input.is_action_pressed("ui_up"):
		tank.move_forward(delta)
	if Input.is_action_pressed("ui_down"):
		tank.move_backward(delta)
	if Input.is_action_pressed("ui_right"):
		tank.rotate_right(delta)
	if Input.is_action_pressed("ui_left"):
		tank.rotate_left(delta)
	
	if Input.is_action_just_pressed("mouse_left_click"):
		tank.fire.rpc() # Fire broadcast on all peers
	
	tank.look_turret_to(tank.get_global_mouse_position())



func _process(delta):
	super(delta)
	tank.broadcast_state.rpc( # Update tank state on all peers
		tank.global_position,
		tank.global_rotation,
		tank.turret.global_rotation
	)

