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

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT :
			for card in player_piles.hand_pile:
				print(card.card_data.nice_name)
		if event.button_index == MOUSE_BUTTON_RIGHT :
			print("Right mouse button")
		if event.button_index == MOUSE_BUTTON_WHEEL_UP :
			print("Scroll wheel up")
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print("Scroll wheel down")


func set_player_group(index: int):
	add_to_group("p" + str(index))


func _on_hand_pile_p1_updated(card: CardUI) -> void:
	hand_cards.append(card)
	player_piles.set_card_pile(card, player_piles.Piles.hand_pile)
	change_parent(card)


func change_parent(card: CardUI) -> void:
	var temp_card = card
	card.get_parent().remove_child(card)
	player_piles.add_child(card)
