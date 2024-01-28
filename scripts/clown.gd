extends CharacterBody3D
class_name Clown

var next : Clown = null
var waypoints : Array[Vector3] = []
var waypoint_timer : float = 0.0
@export var waypoint_frequency : float = 10.0
@export var animation_player : AnimationPlayer = null

func _ready() -> void:
	waypoints.resize(30)
	waypoints.fill(position)
	animation_player.play("Jump")

func _physics_process(delta):
	velocity.y -= delta * 9.8
	move_and_slide()
	_update_waypoints(delta)

func set_next(clown : Clown):
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
		
	next.position = lerp(waypoints[0], waypoints[1], waypoint_timer)
	var look : Vector3 = Vector3(
		position.x,
		next.position.y,
		position.z
	)
	if (look - next.position).length_squared() > 0.0:
		next.look_at(look)
		next.rotate_y(PI)
	next.update_next(delta)
	
func get_last() -> Clown:
	var last : Clown = self
	while last and last.next:
		last = last.next
	return last

func count() -> int:
	var c : int = 0
	var clown : Clown = self
	while clown:
		c += 1
		clown = clown.next
	return c

func as_array_positions() -> Array[Vector3]:
	var arr : Array[Clown] = as_array()
	var out : Array[Vector3] = []
	out.resize(arr.size())
	for i in range(arr.size()):
		out[i] = arr[i].position
	return out

func as_array() -> Array[Clown]:
	var out : Array[Clown] = []
	var clown = self
	while clown:
		out.append(clown)
		clown = clown.next
	return out
