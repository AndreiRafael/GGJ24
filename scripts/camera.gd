extends Node3D
class_name Camera

@export var target : Node3D = null
@export var offset : Vector3 = Vector3.ZERO
var multiplier : float = 1.0
var center : float = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	if !target:
		return
	
	var off : Vector3 = offset * multiplier
	var target_pos = lerp(
		target.position + off,
		Vector3.ZERO + off,
		center
	)
	position = lerp(position, target_pos, delta * 3.0)
