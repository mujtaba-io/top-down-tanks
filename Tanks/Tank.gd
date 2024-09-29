extends CharacterBody2D
class_name Tank

const MAX_SPEED: float = 64
const ROTATION_SPEED: float = 200

enum Country {
	USA, GERMANY, SOVIET_UNION, BRITAIN, JAPAN
}



@export var tank_name: String
@export var country: Country

@export var turret : Node
@export var health: int = 100

@export var bullet_scene: PackedScene # Tank's bullet that should be spawned
@export var bullet_spawn_point: Marker2D

var speed : float = 0


func _ready():
	add_to_group("tanks")

func _physics_process(delta):
	# Move forward with the current speed.
	move_and_collide(speed * global_transform.y * delta)
	speed -= speed * delta # Decrement the speed with time
	
	$EngineSound.pitch_scale = 0.5 if (abs(speed) / MAX_SPEED) < 0.5 else (abs(speed) / MAX_SPEED)
	$EngineSound.pitch_scale *= 1.5


func move_forward(delta: float):
	speed -= delta * MAX_SPEED

func move_backward(delta: float):
	speed += delta * MAX_SPEED

func rotate_right(delta: float):
	global_rotation += deg_to_rad(delta*ROTATION_SPEED)

func rotate_left(delta: float):
	global_rotation -= deg_to_rad(delta*ROTATION_SPEED)



# Aim/look turret towards
func rotate_turret_to(_global_rotation: float): # or position?
	turret.global_rotation = lerp_angle(
		turret.global_rotation,
		_global_rotation,
		0.08
	)

func look_turret_to(_global_position: Vector2): # or position?
	turret.global_rotation = lerp_angle(
		turret.global_rotation,
		turret.global_position.angle_to_point(_global_position) + PI / 2,
		0.08
	)


# Fire in turret's direction
@rpc("any_peer", "call_local")
func fire():
	var bullet = bullet_scene.instantiate().with_data(
		bullet_spawn_point.global_position,
		turret.global_rotation
	)
	
	bullet.explode.connect(_on_bullet_explode)
	
	get_tree().get_nodes_in_group("levels")[0].add_child(bullet)
	print("Fired bullet")
	
	$FireSound.play()


func _on_bullet_explode(at_global_position: Vector2):
	pass # Bullet itself handles this










#>
#>
#>



@rpc("any_peer", "call_remote")
func broadcast_state(
	tank_pos, tank_rot, turret_rot
):
	global_position = tank_pos
	global_rotation = tank_rot
	turret.global_rotation = turret_rot
