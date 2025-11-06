extends ColorRect

func _ready() -> void:
	# If you’re not using anchors/containers:
	set_anchors_preset(Control.PRESET_TOP_LEFT)  # optional, keeps offsets absolute
	position = position.round()
	size = size.round()
	scale = Vector2.ONE  # avoid fractional scaling

# If the rect is moved/resized at runtime, re-snap each frame (cheap for UI):
func _process(_delta: float) -> void:
	position = position.round()
	size = size.round()


func _on_area_2d_body_entered(body: Node2D) -> void:
	#damage logic here
	print('body enter')
