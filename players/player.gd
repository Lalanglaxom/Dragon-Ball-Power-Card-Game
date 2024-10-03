extends Node

@export var id: int

@onready var full_pile = get_tree().get_nodes_in_group("full pile")[0]
@onready var player_piles: PlayerPileUI = $PlayerPiles

const CHOSEN_BOX_01 = preload("res://card/properties/chosen_box_01.png")
const CHOSEN_BOX_02 = preload("res://card/properties/chosen_box_02.png")
const CHOSEN_BOX_03 = preload("res://card/properties/chosen_box_03.png")

var hand_cards = []
var grave_cards = []
var cards_is_choosing = []

static var p1_number_is_chosen := 0
static var p2_number_is_chosen := 0
static var p3_number_is_chosen := 0

func _ready() -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT :
			pass
		if event.button_index == MOUSE_BUTTON_RIGHT :
			print("Right mouse button")
		if event.button_index == MOUSE_BUTTON_WHEEL_UP :
			print("Scroll wheel up")
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print("Scroll wheel down")


func set_player_group(index: int):
	add_to_group("p" + str(index))


func update_player_card() -> void:
	for card in hand_cards:
		player_piles.set_card_pile(card, player_piles.Piles.hand_pile)
		change_parent(card)

	for card in grave_cards:
		player_piles.set_card_pile(card, player_piles.Piles.grave_pile)


func change_parent(card: CardUI) -> void:
	var temp_card = card
	card.get_parent().remove_child(card)
	player_piles.add_child(card)
