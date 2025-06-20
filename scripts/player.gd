extends CharacterBody2D

const SPEED = 150
const JUMP_VELOCITY = -350.0
const ACCELERATION = 1000
const FRICTION = 600

@onready var animated_sprite = $AnimatedSprite2D
@onready var sfx_jump = $jump_sfx
@onready var sfx_pickup = $Area2D/AudioStreamPlayer2D
@onready var coin_label: Label = $Camera2D/coin_label
@onready var health_label: Label = $Camera2D/health_label
@onready var sfx_hurt = $Area2D/hurt_sfx

var is_hurt := false
var coin_counter = 0
var health_counter = 3

func _ready():
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * SPEED, ACCELERATION * delta)
		animated_sprite.flip_h = input_dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sfx_jump.play()

	if not is_hurt:
		update_animation()

	move_and_slide()

func update_animation():
	if not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x) > 10:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		set_coin(coin_counter + 1)
		sfx_pickup.play()
	elif area.is_in_group("finish"):
		game_over()
	elif area.is_in_group("enemy"):
		if not is_hurt:
			animated_sprite.play("hurt")
			is_hurt = true
			set_health(health_counter - 1)
			sfx_hurt.play()

func _on_animation_finished():
	if animated_sprite.animation == "hurt":
		is_hurt = false
		update_animation()

func game_over():
	get_tree().reload_current_scene()

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()

func set_health(new_health_counter: int) -> void:
	health_counter = max(new_health_counter, 0)
	health_label.text = "❤️".repeat(health_counter)

	if health_counter == 0:
		game_over()

func set_coin(new_coin_counter: int) -> void:
	coin_counter = new_coin_counter
	coin_label.text = "🪙x" + str(coin_counter)
