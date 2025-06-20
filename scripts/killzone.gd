extends Area2D

@onready var timer: Timer = $Timer
@onready var sfx_death = $death_sfx

func _on_body_entered(body: Node2D) -> void:
	print(body)
	sfx_death.play()
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
