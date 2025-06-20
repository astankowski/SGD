extends CharacterBody2D

const SPEED = 25
const PAUSE_TIME = 0.5  # seconds to pause at an edge

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var raycast_left = $RayCast2D_left
@onready var raycast_right = $RayCast2D_right

var direction := -1  # -1 = left, 1 = right
var pause_timer := 0.0

func _physics_process(delta: float) -> void:
	# Gravity
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	if pause_timer > 0.0:
		pause_timer -= delta
		velocity.x = 0
	else:
		if is_on_floor():
			if direction == 1 and not raycast_right.is_colliding():
				direction = -1
				pause_timer = PAUSE_TIME
			elif direction == -1 and not raycast_left.is_colliding():
				direction = 1
				pause_timer = PAUSE_TIME

		velocity.x = SPEED * direction

	update_animation()
	move_and_slide()

func update_animation():
	if velocity.x != 0:
		animated_sprite_2d.flip_h = direction < 0
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
