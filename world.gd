extends Node2D

func _show_level_completed():
	level_completed.show()
	get_tree().paused = true

@onready var collision_polygon = $StaticBody2D/CollisionPolygon2D
@onready var polygon = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_completed.connect(_show_level_completed)
