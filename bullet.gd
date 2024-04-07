extends Area2D

var world

var who_fired

var pos: Vector2 # must set after instance
var rot: float # must set after instance

var speed: float = 128

var timer: float = 1.0
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
	self.global_position += Vector2(1, 0).rotated(global_rotation - PI / 2) * speed * delta
	
	timer -= delta
	if timer < 0 and not exploded:
		self.explode.emit()
		self.on_explode.rpc()
	
	if exploded:
		if not ($hit_anim as AnimatedSprite2D).is_playing():
			queue_free()
			print("queue freed bullet")


func _on_body_entered(body):
	if body == who_fired: return
	if body.has_signal("reduce_health"):
		body.reduce_health.emit(100) # reduce health by 100 (completely destroy)
	self.explode.emit()
	self.on_explode.rpc()


# explode emitted as signal + called as rpc
@rpc("any_peer", "call_remote", "unreliable")
func on_explode():
	# check if there are tanks nearby, then reduce their health as well
	# based on distance TODO TODO TODO
	exploded = true
	$sprite.visible = false # hide bullet sprite (not whole self)
	($hit_anim as AnimatedSprite2D).visible = true
	($hit_anim as AnimatedSprite2D).play("default")
	($hit_anim/audio_stream_player_2d as AudioStreamPlayer2D).play()
	print('exploded')

