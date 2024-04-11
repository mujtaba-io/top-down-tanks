extends Area2D

var world

var who_fired

var pos: Vector2 # must set after instance
var rot: float # must set after instance

var speed: float = 300

var timer: float = 0.4
var exploded: bool = false

signal explode

# Called when the node enters the scene tree for the first time.
func _ready():
	world = get_tree().root.get_node("world")
	
	self.explode.connect(on_explode)

func set_bullet_pos_dir_who_fired(pos, rot, who_fired):
	self.global_rotation = rot
	self.global_position = pos
	self.who_fired = who_fired

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not exploded:
		self.global_position += Vector2(1, 0).rotated(global_rotation - PI / 2) * speed * delta
	
	timer -= delta
	if timer < 0 and not exploded:
		timer = 0.4
		self.explode.emit()
		#self.on_explode.rpc()
	
	if exploded:
		if not $hit_anim.is_playing() and not $hit_anim/explosion_sound.is_playing():
			queue_free()
			print("queue freed bullet")


func _on_body_entered(body):
	if body == who_fired: return
	if body.has_signal("reduce_health"):
		#body.reduce_health.emit(100) # reduce health by 100 (completely destroy)
		pass
	self.explode.emit()


# explode emitted as signal + called as rpc
@rpc("any_peer", "call_local", "unreliable")
func on_explode():
	if exploded: return # hacky wy to solve bug that reduces health twice per explosion
	for tank in get_tree().get_nodes_in_group("tanks"):
		if tank == who_fired: continue
		var distance_to_tank: float = tank.global_position.distance_to(self.global_position)
		if distance_to_tank < 12:
			tank.reduce_health.emit(100)
			#tank.on_reduce_health.rpc(100)
			# shake camra
		elif distance_to_tank < 32:
			tank.reduce_health.emit(70)
			#tank.on_reduce_health.rpc(70)
			# shake camra
		elif distance_to_tank < 128:
			tank.reduce_health.emit(30)
			#tank.on_reduce_health.rpc(30)
			# shake camra
	exploded = true
	$sprite.visible = false # hide bullet sprite (not whole self)
	($hit_anim as AnimatedSprite2D).visible = true
	($hit_anim as AnimatedSprite2D).play("default")
	($hit_anim/explosion_sound as AudioStreamPlayer2D).play()
	print('exploded')

