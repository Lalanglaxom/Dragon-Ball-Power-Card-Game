extends Button

@onready var full_pile: FullPile = $"../../FullPile"
@onready var hand_container_p_1: Control = $"../../../HandContainerP1"

func _on_pressed() -> void:
	print(str(multiplayer.get_unique_id()) + ": " + str(hand_container_p_1.current_turn))
