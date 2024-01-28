extends CharacterBody3D
class_name Car

@export var speed_limit : float = 10.0
@export var turn_speed : float = 3.0
@export var acceleration : float = 2.0
@export var max_gas : float = 10.0

var turn : float = 0.0
var gas : float = 5.0
var stopped : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	var vel : Vector3 = velocity
	var fwd : Vector3 = global_basis.z
	
	if !stopped:
		var axis : float = Input.get_axis("turn_left", "turn_right")
		if axis != 0.0:
			turn += axis * delta * 5.0
			turn = clampf(turn, -1.0, 1.0)
		elif turn > 0.0:
			turn = maxf(turn - delta, 0.0)
		elif turn < 0.0:
			turn = minf(turn + delta, 0.0)
		rotate_y(-delta * turn_speed * turn)
		
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
		if vel.length_squared() > speed_limit * speed_limit:
			vel = vel.normalized() * speed_limit
	vel.y -= delta * 9.8
	velocity = vel
	move_and_slide()
