extends Interactable


func _ready():
	super._ready()
	interacted_sound = SoundManager.PICKUP_HEART_SOUND


func _interact(_player: Player) -> void:
	var hearts = get_tree().get_nodes_in_group("hearts")
	Events.heart_collected.emit()
	if hearts.size() <= 1: # If there are no more hearts left
		Events.level_completed.emit()
