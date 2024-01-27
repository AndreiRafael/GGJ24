extends CharacterBody3D
class_name Clown

@export var next : Clown = null
@export var follow_distance : float = 1.0

var waypoints : Array[Vector3] = []
var waypoint_timer : float = 0.0
@export var waypoint_frequency : float = 10.0

func _ready():
	set_next(next)

func set_next(clown : Clown):
	waypoints.resize(20)
	waypoints.fill(Vector3(0.0, 0.0, 0.0))
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
		
	_update_waypoints(delta)
		
	var target_pos : Vector3 = lerp(waypoints[0], waypoints[1], waypoint_timer)
	var look : Vector3 = Vector3(
		target_pos.x,
		next.position.y,
		target_pos.z
	)
	if look != next.position:
		next.look_at(look)
		next.rotate_y(PI)
	next.position = target_pos
	next.update_next(delta)
