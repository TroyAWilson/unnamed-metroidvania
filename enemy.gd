class_name Enemy
extends CharacterBody2D

const GRAVITY := 2000.0
var health = 3
var speed = 300.0
var dir := 1
@onready var ray: RayCast2D = get_node_or_null("RayCast2D")
@onready var floorRay: RayCast2D = get_node_or_null("FloorDetection")

func handle_ready() -> void:
	add_to_group("enemy")
	if ray:
		ray.target_position = Vector2(50, 0)  # Point ray to the right
		ray.enabled = true
		ray.add_exception(self)  # Ignore self in collisions
	else:
		print("Warning: ray RayCast2D node not found!")
		
	if floorRay:
		floorRay.target_position = Vector2(0, 50)  # Point ray down
		floorRay.enabled = true
		floorRay.add_exception(self)  # Ignore self in collisions
	else:
		print("Warning: floorRay RayCast2D node not found!")
		
func _ready():
	handle_ready()

func _physics_process(delta: float) -> void:
	if floorRay and not floorRay.is_colliding():
		dir *= -1
		_update_rays()
	if ray and ray.is_colliding():
		dir *= -1  
		_update_rays()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0
	
	velocity.x = speed * delta * dir
	
	move_and_slide()

func _on_hurtbox_body_entered(body:Node2D) -> void:
	print(body)
	if body.is_in_group("player"):
		print('A PLAYER')
		if body.has_method('take_damage'):
			print('OW DAMAGE')
			take_damage(1)
			body.take_damage(1)
		if body.has_method('enter_knockback'):
			var dir := (body.global_position - global_position).normalized()
			body.enter_knockback(dir, body.get_position())
			
func take_damage(amount: int) -> void:
	print(str(self) + " took " + str(amount) + " damage!")
	health -= amount
	if health <= 0:
		print(str(self) + " has been defeated!")
		queue_free()

func _update_rays() -> void:
	if ray and floorRay:
		floorRay.position.x *= -1
		ray.target_position.x *= -1
