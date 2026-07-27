extends Node

var score: int = 0
var distance: float = 0.0

func reset():
	score = 0
	distance = 0

func add_score(points: int):
	score += points
	EventBus.score_updated.emit(score)

func add_distance(delta_distance: float):
	distance += delta_distance
	EventBus.distance_updated.emit(distance)
