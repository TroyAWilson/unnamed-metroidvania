class_name Slime
extends Enemy

func _ready():
	# Custom initialization for Slime
	speed = 500.0  # Override the parent's speed

func do_slime_behavior():
	print("Slime is doing its unique behavior!")

func _physics_process(delta: float) -> void:
	#If they handle movement in the same way you have to call super
	super._physics_process(delta)
	do_slime_behavior()