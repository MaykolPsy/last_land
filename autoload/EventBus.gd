extends Node

signal player_died
signal score_updated(score)
signal distance_updated(distance)
signal bioma_changed(bioma_name)
signal item_collected(item_id)
signal checkpoint_reached(checkpoint_id)
signal camera_shake(intensity)
signal shield_changed(active)

signal game_started
signal game_paused
signal game_resumed
signal game_over
signal game_won
