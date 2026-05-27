extends Node


#core gameplay events

signal player_died
signal score_updated(score)
signal bioma_changed(bioma_name)
signal item_collected(item_id)
signal checkpoint_reached(checkpoint_id)

#feature extensibility

signal game_started
signal game_paused
signal game_resumed
signal game_over
