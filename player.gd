
'''
	TODO:
		- Flesh out state machine
		- expand movement (variable jump, coyote time, etc.)
		- dash?
'''

extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 2.2
var coyote_timer = 0.0

@onready var sprite := $Sprite2D
@onready var AP := $Sprite2D/AnimationPlayer
@onready var hurtBox := $weapon/player_hurtbox

#state machine
enum PlayerState {
	IDLE,
	WALKING,
	JUMPING,
	ATTACKING
}

var current_state = PlayerState.IDLE

func _ready() -> void:
	hurtBox.disabled = true
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# print(current_state)
	if not is_on_floor():
		coyote_timer += delta
	else:
		coyote_timer = 0.0 #reset after jump

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if abs(velocity.x) > 0:
			current_state = PlayerState.WALKING
		else:
			current_state = PlayerState.IDLE

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote_timer < COYOTE_TIME):
		velocity.y = JUMP_VELOCITY
		current_state = PlayerState.JUMPING

	if Input.is_physical_key_pressed(KEY_X):
		current_state = PlayerState.ATTACKING
		AP.play("attack")
	elif Input.is_physical_key_pressed(KEY_X) and current_state == PlayerState.ATTACKING:
		current_state = PlayerState.IDLE
		AP.play("idle")
		hurtBox.disabled = true
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if direction < 0:
			sprite.scale.x = -1
			hurtBox.position.x = -25
		else:
			sprite.scale.x = 1
			hurtBox.position.x = 25

		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()