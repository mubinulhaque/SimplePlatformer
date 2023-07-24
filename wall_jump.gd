extends Interactable


func _interact(player: Player) -> void:
	player.unlocked_wall_jump = true
