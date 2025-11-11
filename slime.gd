class_name Slime #this is probably unecessary but nice if I want different variations of slime?
extends Enemy

func _ready():
	super.handle_ready() #setup base
	
	#override slime specific values
	speed = 500.0  # Override the parent's speed
	health = 1  # Slimes have less health

func do_slime_behavior():
	print("Slime is doing its unique behavior!")

func _physics_process(delta: float) -> void:
	#If they handle movement in the same way you have to call super
	super._physics_process(delta)
	do_slime_behavior()
