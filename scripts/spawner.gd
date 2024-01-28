extends Node3D
class_name Spawner

@export var scene : PackedScene = null
@export var size : float = 0.0

func _ready():
	randomize()
	
func spawn_one(to_avoid : Array[Vector3]) -> Node3D:
	const min_distance : float = 2.0
	const min_distance_squared : float = min_distance * min_distance
	const tries : int = 3
	for i in range(tries):#tentativas
		var pos : Vector3 = position + Vector3(
			(randf() - 0.5) * size,
			0.0,
			(randf() - 0.5) * size
		)
		var valid : bool = true
		if i < (tries - 1):
			for p in to_avoid:
				var dist : float = pos.distance_squared_to(p) 
				if dist < min_distance_squared:
					valid = false
					break
		if !valid:
			continue
		var new_node = scene.instantiate() as Node3D
		if new_node:
			new_node.position = pos
			add_child(new_node)
			return new_node
	return null

func spawn(to_avoid : Array[Vector3], amount : int) -> Array[Node3D]:
	var out : Array[Node3D] = []
	for i in range(amount):
		out.append(spawn_one(to_avoid))
	return out
