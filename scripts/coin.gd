extends Node3D
class_name Coin

var controller : Controller = null

func collect() -> void:
	if controller:
		controller.collect_coin(self)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	rotate_y(delta)
	pass


func _on_area_3d_body_entered(body):
	var car : Car = body as Car
	if car:
		collect()
