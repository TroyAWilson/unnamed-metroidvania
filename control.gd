extends Control

@export var spacing := 64
@export var max_hearts := 3 
@export var health := 0 : set = set_health
@export var player_path:NodePath

var empty_tex := preload("res://heart_e.png")
var full_tex := preload("res://heart_f.png")
var player: Node

func _ready() -> void:
	player = get_node(player_path)
	set_health(player.health)
	max_hearts = player.max_health

func _on_player_health_changed(health: int) -> void:
	set_health(health)
	
func set_health(v:int) -> void:
	health = clamp(v, 0, max_hearts)
	queue_redraw()
	
func _draw() -> void:
	var w := full_tex.get_width() / 8
	for i in range(max_hearts):
		var pos := Vector2(i * (w + spacing), 0)
		var tex := full_tex if i < health else empty_tex
		if tex:
			draw_texture(tex, pos)
