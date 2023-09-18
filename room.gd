extends Area2D

signal new_room_entered(room_size: Vector2, room_centre: Vector2)


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Player:
		var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
		
		if collision_shape:
			var collision_rect: Rect2 = collision_shape.shape.get_rect()
			new_room_entered.emit(collision_rect.size, position)
