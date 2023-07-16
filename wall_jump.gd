extends Ability


func _gain_ability(player: Player):
	player.unlocked_wall_jump = true
