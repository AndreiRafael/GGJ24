extends CharacterBody3D
class_name Clown

@export var next : Clown = null
var waypoints : Array[Vector3] = []
var waypoint_timer : float = 0.0
@export var waypoint_frequency : float = 10.0

func _ready():
	set_next(next)

func _physics_process(delta):
	velocity.y -= delta * 9.8
	move_and_slide()
	_update_waypoints(delta)

func set_next(clown : Clown):
	waypoints.resize(20)
	waypoints.fill(position)
	if clown is Leader:
		return
	if !next and clown:
		next = clown
		next.position = position

func _update_waypoints(delta : float):
	waypoint_timer += delta * waypoint_frequency
	while waypoint_timer > 1.0:
		for i in range(waypoints.size() - 1):
			waypoints[i] = waypoints[i + 1]
		waypoint_timer -= 1.0
		waypoints[-1] = position

func update_next(delta : float):
	if !next:
		return
		
	var target_pos : Vector3 = lerp(waypoints[0], waypoints[1], waypoint_timer)
	var look : Vector3 = Vector3(
		position.x,
		next.position.y,
		position.z
	)
	if look != next.position:
		next.look_at(look)
		next.rotate_y(PI)
	next.position = target_pos
	next.update_next(delta)
	
func get_last() -> Clown:
	var last : Clown = self
	while last and last.next:
		last = last.next
	return last
