class_name Enemy
extends CharacterBody2D

var speed = 300.0
@onready var ray: RayCast2D = get_node_or_null("RayCast2D")

func _ready():
	if ray:
		ray.target_position = Vector2(50, 0)  # Point ray to the right
		ray.enabled = true
		ray.add_exception(self)  # Ignore self in collisions
	else:
		print("Warning: RayCast2D node not found!")

func _physics_process(delta: float) -> void:
	if ray and ray.is_colliding():
		speed *= -1  # Reverse direction
		ray.target_position.x *= -1  # Flip ray direction

	print(str(self) + " delta: " + str(delta))
	velocity.x = speed * delta
	move_and_slide()


func _on_hurtbox_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		print("Enemy hit player")
		queue_free() #removes enemy on collision, deal with health later
