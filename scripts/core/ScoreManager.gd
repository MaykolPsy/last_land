extends Node

var score: int = 0
var distance: float = 0.0

func reset():
	score = 0
	distance = 0

func add_distance(delta_distance: float):
	distance += delta_distance

	# El score siempre equivale a la distancia recorrida
	score = int(distance)

	EventBus.distance_updated.emit(distance)
	EventBus.score_updated.emit(score)

func add_score(points: int):
	score += points
	EventBus.score_updated.emit(score)

func get_distance() -> float:
	return distance
	
func get_score() -> int:
	return score
	
