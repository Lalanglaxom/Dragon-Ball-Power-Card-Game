extends Button

@onready var full_pile: FullPile = $"../../FullPile"

func _on_pressed() -> void:
	if multiplayer.is_server():
		full_pile.sync_draw_pile.rpc(full_pile.id_pile)
