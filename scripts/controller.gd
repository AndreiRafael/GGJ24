extends Node3D
class_name Controller

enum State {
	CAR,
	CLOWN
}

@export var round_time : float = 20.0

@export var car_scene : PackedScene = null
@export var leader_scene : PackedScene = null
@export var clown_scene : PackedScene = null

var state : State = State.CLOWN
var timer : float = 0.0

var car : Car = null
var leader : Leader = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_state(State.CLOWN)

func switch_state() -> void:
	if state == State.CAR:
		set_state(State.CLOWN)
	else:
		set_state(State.CAR)

func get_spawn_postion() -> Vector3:
	return position + Vector3(0.0, 1.0, 0.0)

func set_state(new_state : State) -> void:
	#limpeza
	match state:
		State.CAR:
			if car:
				car.queue_free()
				car = null
		State.CLOWN:
			if leader:
				leader.queue_free()
				leader = null
	
	state = new_state
	
	#inicialização
	match state:
		State.CAR:
			car = car_scene.instantiate() as Car
			car.position = get_spawn_postion()
			add_child(car)
		State.CLOWN:
			leader = leader_scene.instantiate() as Leader
			leader.position = get_spawn_postion()
			add_child(leader)

func _process(delta: float) -> void:
	timer += delta
	if timer > round_time:
		timer -= round_time
		switch_state()
