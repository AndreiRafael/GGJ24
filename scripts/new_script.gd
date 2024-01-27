extends Node

@export var speed_limit : float = 10.0
@export var turn_speed : float = 3.0
@export var acceleration : float = 2.0
var character : CharacterBody3D = null

func _ready():
	character = get_parent() as CharacterBody3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vel : Vector3 = character.velocity
	var fwd : Vector3 = character.global_basis.z
	
	character.rotate_y(-delta * turn_speed * Input.get_axis("turn_left", "turn_right"))
	
	var hvel : Vector3 = Vector3(vel.x, 0.0, vel.z)
	var hvel_len : float = hvel.length()
	var amount : float = 0.98
	hvel *= amount
	hvel += fwd * hvel_len * (1.0 - amount)
	vel.x = hvel.x
	vel.z = hvel.z	
	
	var mult : float = 1.0
	if vel.length_squared() > 0.0:
		var dot : float = vel.normalized().dot(fwd)
		mult -= 2.0 * (dot - 1.0)
	vel += mult * fwd * acceleration * delta
	vel.y -= delta
	if vel.length_squared() > speed_limit * speed_limit:
		vel = vel.normalized() * speed_limit
	
	character.velocity = vel
	character.move_and_slide()
	