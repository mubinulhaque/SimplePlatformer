extends Area2D

func _on_body_entered(_body):
	queue_free()
	
	var hearts = get_tree().get_nodes_in_group("hearts")
	if hearts.size() <= 1: # If there are no more hearts left
		Events.level_completed.emit()
