extends Node

func _on_area_3d_body_entered(body):
	var car : Car = body as Car
	if car:
		car.stopped = true
		car.velocity.x = 0.0
		car.velocity.z = 0.0
	var leader : Leader = body as Leader
	if leader:
		leader.dead = true
