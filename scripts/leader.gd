extends Clown

@export var speed : float = 2.0
@export var turn_speed : float = 2.0
var last : Clown = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var vel : Vector3 = velocity
	var fwd : Vector3 = global_basis.z
	fwd *= speed
	
	rotate_y(-delta * turn_speed * Input.get_axis("turn_left", "turn_right"))
	
	vel.x = fwd.x
	vel.z = fwd.z
	vel.y -= delta * 9.8
	
	velocity = vel
	move_and_slide()
	
	
	# TODO: checar colisão
	
	update_next(delta)
