extends Interactable


func _interact(player: Player) -> void:
	player.unlocked_double_jump = true
