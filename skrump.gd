class_name Skrump #this is probably unecessary but nice if I want different variations of slime?
extends Enemy

@onready var animationPlayer := $AnimationPlayer
@onready var fireCollisionBox := $firebox/CollisionShape2D

var animation_lock = false

func _ready():
	super.handle_ready() #setup base
	
	#override slime specific values
	speed = 500.0  # Override the parent's speed
	health = 10  # Slimes have less health
	fireCollisionBox.disabled = true	

func _physics_process(delta: float) -> void:
	if ray and ray.is_colliding():
		var hit = ray.get_collider()
		if hit.is_in_group('player'):
			animationPlayer.play('fire_attack')
			animation_lock = true
			await animationPlayer.animation_finished
			animation_lock = false			
	elif not animation_lock:
		animationPlayer.play('walk')
		super._physics_process(delta)
		
	
func _on_firebox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method('take_damage'):
			print('FIRE ATTACK')
			body.take_damage(2)
		if body.has_method('enter_knockback'):
			var dir := (body.global_position - global_position).normalized()
			body.enter_knockback(dir, body.get_position())
