extends Node

@onready var full_pile = get_tree().get_nodes_in_group("full pile")[0]
@onready var player_piles: PlayerPileUI = $PlayerPiles

const CHOSEN_BOX_01 = preload("res://card/properties/chosen_box_01.png")
const CHOSEN_BOX_02 = preload("res://card/properties/chosen_box_02.png")
const CHOSEN_BOX_03 = preload("res://card/properties/chosen_box_03.png")

var hand_cards: Array[CardUI]
var grave_cards: Array[CardUI]
var cards_is_choosing = []


func _ready() -> void:
	pass

func _on_hand_pile_p1_updated(card: CardUI) -> void:
	hand_cards.append(card)
	print(card.card_data.nice_name)
