extends Node2D

@onready var collision_polygon = $StaticBody2D/CollisionPolygon2D
@onready var polygon = $StaticBody2D/CollisionPolygon2D/Polygon2D

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon.polygon = collision_polygon.polygon #Draws the collision polygon's shape
