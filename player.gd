extends CharacterBody2D

const GRAVITY := 2000.0
const JUMP_VELOCITY := -600.0
const COYOTE_TIME := 0.12
const SPEED := 300.0
const JUMP_CUT := 0.5

const KNOCKBACK_SPEED := 420.0
const KNOCKBACK_TIME := 0.15

var max_health := 3
var health := 3 : set = set_health
var coyote_timer := 0.0
var knockback_time_left := 0.0
var was_on_floor := false

@onready var sprite := $Sprite2D
@onready var AP := $Sprite2D/AnimationPlayer
@onready var hurtBox := $weapon/player_hurtbox

signal health_changed(health:int)

# Add a knockback state
enum PlayerState {IDLE, WALKING, JUMPING, ATTACKING, KNOCKBACK}
var current_state = PlayerState.IDLE

func _ready() -> void:
	hurtBox.disabled = true
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	up_direction = Vector2.UP
	floor_snap_length = 6.0

func _physics_process(delta: float) -> void:
	# ---------- timers ----------
	if knockback_time_left > 0.0:
		knockback_time_left -= delta

	# ---------- gravity (once) ----------
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	# ---------- input & horizontal move (disabled during knockback) ----------
	if current_state != PlayerState.KNOCKBACK:
		var dir := Input.get_axis("ui_left", "ui_right")
		if dir != 0.0:
			velocity.x = dir * SPEED
			sprite.scale.x = (-1) if dir < 0 else 1
			hurtBox.position.x = (-25) if dir < 0 else 25
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# optional: add light air resistance during knockback
		velocity.x = move_toward(velocity.x, 0, 800 * delta)

	# ---------- coyote & jump (blocked during knockback) ----------
	if was_on_floor and not is_on_floor():
		coyote_timer = 0.0
	elif is_on_floor():
		coyote_timer = 0.0
	else:
		coyote_timer += delta

	if current_state != PlayerState.KNOCKBACK:
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote_timer < COYOTE_TIME):
			velocity.y = JUMP_VELOCITY
			current_state = PlayerState.JUMPING
		if Input.is_action_just_released("ui_accept") and velocity.y < 0.0:
			velocity.y *= JUMP_CUT

		# attack state example (keep your logic):
		if Input.is_physical_key_pressed(KEY_X):
			current_state = PlayerState.ATTACKING
			AP.play("attack")

	# ---------- move; then inspect this frame's slide collisions ----------
	was_on_floor = is_on_floor()
	move_and_slide()

	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var other := c.get_collider()
		if other and other.is_in_group("enemy") and current_state != PlayerState.KNOCKBACK:
			enter_knockback(c.get_normal(), c.get_position())
			#damage on collision
			take_damage(1)
			
			if other.has_method('take_damage'):
				other.take_damage(1)		
			break

	# ---------- state resolution when not in explicit states ----------
	if current_state != PlayerState.KNOCKBACK and current_state != PlayerState.ATTACKING:
		if not is_on_floor():
			current_state = PlayerState.JUMPING
		else:
			current_state = PlayerState.WALKING if abs(velocity.x) > 0.1 else PlayerState.IDLE

	# When knockback ends, restore to movement states
	if current_state == PlayerState.KNOCKBACK and knockback_time_left <= 0.0:
		current_state = PlayerState.IDLE if is_on_floor() else PlayerState.JUMPING

func enter_knockback(surface_normal: Vector2, contact_pos: Vector2) -> void:
	# push away from the enemy; surface_normal points out of the enemy
	var dir := surface_normal.normalized()
	# ensure some horizontal push if the hit is almost vertical
	if abs(dir.x) < 0.2:
		dir.x = sign(global_position.x - contact_pos.x)
	velocity = dir * KNOCKBACK_SPEED
	knockback_time_left = KNOCKBACK_TIME
	current_state = PlayerState.KNOCKBACK
	AP.play("hit")
	hurtBox.disabled = true
	
func set_health(v:int) -> void:
	health = clamp(v,0,max_health)
	health_changed.emit(health)

func take_damage(dmg:int)->void:
	set_health(health - dmg)

func _on_weapon_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy'):
		if body.has_method('take_damage'):
			body.take_damage(1)


func _on_move_levels_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://demo.tscn")
