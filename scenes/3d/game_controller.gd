extends Node

@onready var player_1_pos: Node3D = $"../CardPosition/Player 1"
@onready var player_2_pos: Node3D = $"../CardPosition/Player 2"

func _ready() -> void:
	GlobalManager.card_chosen.connect(place_card)


func place_card(card3d: Card3D, card2d: Card2D):
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 0 and slot.name != "Grave":
			slot.add_child(card3d)
