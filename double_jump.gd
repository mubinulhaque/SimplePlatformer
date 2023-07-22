extends Ability


func _gain_ability(player: Player) -> void:
	player.unlocked_double_jump = true
