extends Node

@onready var full_pile: Control = $"../FullPile"

@onready var player_1_pos: Node3D = $"../CardPosition/Player 1"
@onready var player_2_pos: Node3D = $"../CardPosition/Player 2"

@onready var hand_container_p_2: Control = $"../HandContainerP2"
@onready var hand_container_p_1: Control = $"../HandContainerP1"

var p1_pile = []
var p2_pile = []

var slot_count = 0

func _ready() -> void:
	GlobalManager.card_chosen.connect(place_card)


func place_card(card3d: Card3D, card2d: Card2D):
	if slot_count == 3:
		for slot in player_1_pos.get_children():
			slot.remove_child(slot.get_child(0))
		slot_count = 0
		put_card_in_slot(card3d)
		return
		
	put_card_in_slot(card3d)
		
		
func put_card_in_slot(card3d: Card3D):
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 0 and slot.name != "Grave":
			slot.add_child(card3d)
			slot_count += 1
			return
			
