extends Node3D
class_name Controller

enum State {
	CAR,
	CLOWN
}

@export var round_time : float = 20.0

@export var leader_scene : PackedScene = null
@export var clown_scene : PackedScene = null

@export var clown_spawner : Spawner = null
@export var car_spawner : Spawner = null
@export var cone_spawner : Spawner = null
@export var coin_spawner : Spawner = null

var state : State = State.CLOWN
var begun : bool = false #pra dar delay antes de começar o jogo de verdade
var timer : float = 0.0

var car : Car = null
var leader : Leader = null
var cones : Array[Node3D] = []
var coins : Array[Coin] = []

var expected_count : int = 1

const coin_time : float = 5.0
const clowns_per_round : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	set_state(State.CLOWN)

func switch_state() -> void:
	if state == State.CAR:
		set_state(State.CLOWN)
	else:
		set_state(State.CAR)

func get_spawn_postion() -> Vector3:
	if car:
		return car.position
	return position + Vector3(0.0, 1.0, 0.0)

func set_state(new_state : State) -> void:
	#limpeza
	match state:
		State.CAR:
			for cone in cones:
				cone.queue_free()
			cones = []
			for coin in coins:
				coin.queue_free()
			coins = []
		State.CLOWN:
			if leader:
				leader.queue_free()
				leader = null
	
	state = new_state
	begun = false
	
	#inicialização
	match state:
		State.CAR:
			timer = coin_time
			car.stopped = false
			cones = cone_spawner.spawn([car.position], 10)
		State.CLOWN:
			timer = 0.0
			leader = leader_scene.instantiate() as Leader
			leader.position = get_spawn_postion()
			add_child(leader)

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
			car = car_spawner.spawn_one(leader.as_array_positions())
			car.rotate_y(randf() * PI * 2.0)
			car.stopped = true
	else:
		var dist : float = leader.position.distance_squared_to(car.position)
		if dist < 1.0:
			if !leader.cut_front():
				set_state(State.CAR)

func _process_car(_delta : float) -> void:
	if timer > coin_time:
		timer -= coin_time
		var coin_avoid : Array[Vector3] = []
		for cone in cones:
			coin_avoid.append(cone.position)
		coin_avoid.append(car.position)
		var coin : Coin = coin_spawner.spawn_one(coin_avoid) as Coin
		coin.controller = self
		coins.append(coin)
	if car.stopped:#bateu o corcel
		set_state(State.CLOWN)

func _process(delta: float) -> void:
	timer += delta
	match state:
		State.CAR:
			_process_car(delta)
		State.CLOWN:
			_process_clown(delta)

func collect_coin(coin : Coin) -> void:
	coins.remove_at(coins.find(coin))
