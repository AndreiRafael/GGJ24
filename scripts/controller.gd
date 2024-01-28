extends Node3D
class_name Controller

enum State {
	CAR,
	CLOWN
}

@export var round_time : float = 20.0
@export var camera : Camera = null

@export var leader_scene : PackedScene = null
@export var clown_scene : PackedScene = null

@export var clown_spawner : Spawner = null
@export var car_spawner : Spawner = null
@export var cone_spawner : Spawner = null
@export var coin_spawner : Spawner = null

@export var ui_gas : ColorRect = null
@export var ui_score : Label = null
@export var ui_game_over : Label = null

var state : State = State.CLOWN
var game_over : bool = false
var begun : bool = false #pra dar delay antes de começar o jogo de verdade
var timer : float = 0.0
var score : int = 0

var car : Car = null
var leader : Leader = null
var cones : Array[Node3D] = []
var coin : Coin = null

var expected_count : int = 8

const clowns_per_round : int = 6

func _set_score(value : int) -> void:
	score = value
	if ui_score:
		ui_score.text = str(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_score(0)
	set_state(State.CAR)

func switch_state() -> void:
	if state == State.CAR:
		set_state(State.CLOWN)
	else:
		set_state(State.CAR)

func get_spawn_postion() -> Vector3:
	if car:
		return car.position
	return position + Vector3(0.0, 1.0, 0.0)

func spawn_coin():
	var avoid : Array[Vector3] = []
	if car:
		avoid = [car.position]
	coin = coin_spawner.spawn_one(avoid) as Coin
	coin.controller = self
	
func spawn_car() -> Car:
	var avoid : Array[Vector3] = []
	if leader:
		avoid = leader.as_array_positions()
	car = car_spawner.spawn_one(avoid)
	car.ui = ui_gas
	car.rotate_y(randf() * PI * 2.0)
	return car

func set_state(new_state : State) -> void:
	#limpeza
	match state:
		State.CAR:
			for cone in cones:
				cone.queue_free()
			cones = []
			if coin:
				coin.queue_free()
			coin = null
			if ui_gas:
				ui_gas.visible = false
		State.CLOWN:
			if leader:
				leader.queue_free()
				leader = null
	
	state = new_state
	begun = false
	
	#inicialização
	match state:
		State.CAR:
			if !car:
				car = spawn_car()
			car.go()
			camera.target = car
			camera.multiplier = 0.9
			camera.center = 0.5
			cones = cone_spawner.spawn([car.position], 10)
			spawn_coin()
			if ui_gas:
				ui_gas.visible = true
		State.CLOWN:
			timer = 0.0
			leader = leader_scene.instantiate() as Leader
			leader.position = get_spawn_postion()
			leader.rotate_y(randf() * PI * 2.0)
			add_child(leader)
			camera.target = leader
			camera.multiplier = 0.6
			camera.center = 0.2

func map_position(clown : Clown) -> Vector3:
	return clown.position

func _process_clown(_delta : float) -> void:
	if !begun:
		if leader.count() < expected_count:
			if timer > (1.0 / leader.speed):
				timer -= (1.0 / leader.speed)
				var new_clown = clown_scene.instantiate() as Clown
				if new_clown:
					new_clown.position = get_spawn_postion()
					add_child(new_clown)
					leader.get_last().set_next(new_clown)
		else:
			clown_spawner.spawn(leader.as_array_positions(), clowns_per_round)
			expected_count += clowns_per_round
			if(car):
				car.queue_free()
				car = null
			begun = true
	elif !car:
		if leader.count() >= expected_count:
			car = spawn_car()
			car.stop()
	else:
		var dist : float = leader.position.distance_squared_to(car.position)
		if dist < 1.0:
			car.animation_player.stop()
			car.animation_player.play("Enter")
			if !leader.cut_front():
				set_state(State.CAR)
	if !game_over and leader and leader.dead:
		game_over = true
		ui_game_over.visible = true
	if game_over and Input.is_action_just_pressed("start"):
		get_tree().reload_current_scene()

func _process_car(_delta : float) -> void:
	if car.stopped:#bateu o corcel
		set_state(State.CLOWN)

func _process(delta: float) -> void:
	timer += delta
	match state:
		State.CAR:
			_process_car(delta)
		State.CLOWN:
			_process_clown(delta)

func collect_coin() -> void:
	if car:
		car.gas = min(car.gas + car.max_gas / 2.0, car.max_gas)
	spawn_coin()
	_set_score(score + 1)
