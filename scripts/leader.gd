extends Clown
class_name Leader

@export var speed : float = 2.0
@export var turn_speed : float = 2.0
var dead : bool = false

func _process(_delta):
	if Input.is_action_just_pressed("test"):
		cut_front()

func _physics_process(delta):
	if dead:
		return
	
	var vel : Vector3 = velocity
	var fwd : Vector3 = global_basis.z
	fwd *= speed
	
	rotate_y(-delta * turn_speed * Input.get_axis("turn_left", "turn_right"))
	
	vel.x = fwd.x
	vel.z = fwd.z
	velocity = vel
	super(delta)
	update_next(delta)

func check_hit(other : Clown) -> void:
	if !other or other == self or other == self.next:
		return
	
	var clown : Clown = next
	while clown:
		if clown == other:
			dead = true
			return
		clown = clown.next
	
	var last : Clown = get_last()
	if last:
		last.set_next(other)

func cut_back() -> bool:
	var to_free : Clown = get_last()
	if !to_free or to_free == self:
		return false
	var prev : Clown = self
	while(prev.next != to_free):
		prev = prev.next
	prev.next = null
	to_free.queue_free()
	return true
	
func cut_front() -> bool:
	var to_free : Clown = next
	if !to_free or to_free == self:
		return false
	position = to_free.position
	waypoints = to_free.waypoints
	next = to_free.next
	to_free.queue_free()
	return true

func _on_hitbox_body_entered(body):
	var clown : Clown = body as Clown 
	if clown:
		check_hit(clown)
