extends Node

@onready var full_pile: Control = $"../FullPile"

@onready var player_1_pos: Node3D = $"../CardPosition/Player 1"
@onready var power_p_1: Label = $"../CanvasLayer/UI/PowerP1"

@onready var player_2_pos: Node3D = $"../CardPosition/Player 2"

@onready var hand_container_p_2: Control = $"../HandContainerP2"
@onready var hand_container_p_1: Control = $"../HandContainerP1"

var start_card_hand_amount: int = 13

var p1_pile := []
var p1_battle_pile := []
var p1_grave_pile := []
var p1_battle_power: int


var p2_pile := []
var p2_battle_pile := []
var p2_grave_pile := []
var p2_battle_power: int

var game_turn: int
var turn_id := [1,2]
var current_player_turn := 1

var slot_count = 0

func _ready() -> void:
	GlobalManager.card_chosen.connect(place_card)
	GlobalManager.draw_pile_updated.connect(func(): draw_card_for_player.rpc())
	self.start()


func start():
	turn_id.shuffle()
	if multiplayer.is_server():
		set_turn.rpc(turn_id[0])
		hand_container_p_1.set_turn(turn_id[1])
		hand_container_p_1.switch_state(current_player_turn)
	
@rpc("any_peer","call_remote")
func set_turn(turn: int):
	hand_container_p_1.set_turn(turn)	
	hand_container_p_1.switch_state(current_player_turn)

@rpc("any_peer", "call_local", "reliable")
func draw_card_for_player():
	if multiplayer.get_unique_id() == 1:
		for i in range(0,start_card_hand_amount):
			var card = full_pile.draw_pile[i]
			p1_pile.append(card)
			card.reparent(hand_container_p_1, true)
			card.card_belong_to_id = multiplayer.get_unique_id()
		hand_container_p_1.arrange_hand_card()

		for i in range(start_card_hand_amount, start_card_hand_amount * 2):
			var card = full_pile.draw_pile[i]
			p2_pile.append(card)
			card.reparent(hand_container_p_2, true)
		hand_container_p_2.arrange_hand_card()
		
	else:
		for i in range(0,start_card_hand_amount):
			var card = full_pile.draw_pile[i]
			p1_pile.append(card)
			card.reparent(hand_container_p_2, true)
		hand_container_p_2.arrange_hand_card()

		for i in range(start_card_hand_amount, start_card_hand_amount * 2):
			var card = full_pile.draw_pile[i]
			p2_pile.append(card)
			card.reparent(hand_container_p_1, true)
			card.card_belong_to_id = multiplayer.get_unique_id()
			hand_container_p_1.arrange_hand_card()

func place_card(card3d: Card3D, card2d: Card2D):
	put_card_in_slot(card3d)


func put_card_in_slot(card3d: Card3D):
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 0 and slot.name != "Grave":
			slot.add_child(card3d)
			p1_battle_pile.append(card3d)
			slot_count += 1
			update_power_label()
			return


func update_power_label():
	p1_battle_power = 0
	for card in p1_battle_pile:
		p1_battle_power += card.card_data.power
	power_p_1.text = str(p1_battle_power)
