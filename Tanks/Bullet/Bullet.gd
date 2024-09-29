extends Area2D



var speed: float = 500

var timer: float = 0.4
var exploded: bool = false


signal explode(at_global_position: Vector2) # API, can be connected by tanks



func with_data(pos, rot):
	self.global_rotation = rot
	self.global_position = pos
	return self # Important, else its not constructor



# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("bullets")
	self.explode.connect(_on_explode)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not exploded:
		self.global_position += Vector2(1, 0).rotated(global_rotation - PI / 2) * speed * delta
	
	timer -= delta
	if timer < 0 and not exploded:
		timer = 0.4
		self.explode.emit(global_position)
	
	if exploded:
		if not $Explosion.is_playing() and not $Explosion/ExplosionSound.is_playing():
			queue_free()
			print("Bullet.gd line 40: Queue-free")



func _on_body_entered(body):
	self.explode.emit(global_position)



func _on_explode(at_global_position: Vector2):
	if exploded: return # if already exploded
	exploded = true
	$Sprite2D.visible = false # hide bullet sprite (not whole self)
	($Explosion as AnimatedSprite2D).visible = true
	($Explosion as AnimatedSprite2D).play("default")
	($Explosion/ExplosionSound as AudioStreamPlayer2D).play()
	
	for player in get_tree().get_nodes_in_group("players"):
		if player.tank.global_position.distance_to(at_global_position) < 32:
			player.tank.health -= 10
			print("Player health reduced to: "+ str(player.tank.health))
		elif player.tank.global_position.distance_to(at_global_position) < 64:
			player.tank.health -= 5
			print("Player health reduced to: "+ str(player.tank.health))
		
		if player.health <= 0:
			player.death.emit()
	print('exploded')

