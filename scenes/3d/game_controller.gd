extends Node

@onready var full_pile: Control = $"../FullPile"

@onready var player_1_pos: Node3D = $"../CardPosition/Player 1"
@onready var power_p_1: Label = $"../CanvasLayer/UI/PowerP1"

@onready var player_2_pos: Node3D = $"../CardPosition/Player 2"

@onready var hand_container_p_2: Control = $"../HandContainerP2"
@onready var hand_container_p_1: Control = $"../HandContainerP1"

const CARD_3D = preload("res://scenes/3d/card_3d.tscn")

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
	GlobalManager.card_chosen.connect(func(card2d: Card2D, card_id: int, id: int): place_card.rpc(card_id, id))
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


@rpc("any_peer", "call_local", "reliable")
func place_card(card_id, id):
	if slot_count == 3:
		current_player_turn += 1
		hand_container_p_1.switch_state(current_player_turn)
		slot_count = 0
		return
		
	var card3d = create_card_3d(get_card3d_data_by_id(card_id), id)
	if multiplayer.get_unique_id() == card3d.card_belong_to_id:
		put_card_in_p1_slot(card3d)
	else:
		put_card_in_p2_slot(card3d)
	slot_count += 1



@rpc("any_peer", "call_local", "reliable")
func text(id):
	GlobalManager.print_multi(id)


func put_card_in_p1_slot(card3d: Card3D):
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 0 and slot.name != "Grave":
			slot.add_child(card3d)
			p1_battle_pile.append(card3d)
			update_power_label()
			
			return


func put_card_in_p2_slot(card3d: Card3D):
	for slot in player_2_pos.get_children():
		if slot.get_child_count() == 0 and slot.name != "Grave":
			slot.add_child(card3d)
			p2_battle_pile.append(card3d)
			update_power_label()
			return


func get_card3d_data_by_id(id : int):
	for json_data in full_pile.card_database:
		if int(json_data.id) == id:
			return json_data
	GlobalManager.print_multi("Null 3D Data")
	return null


func create_card_3d(json_data: Dictionary, id: int):
	var card_3d = CARD_3D.instantiate()
	card_3d.frontface_texture = json_data.front_image_path
	card_3d.backface_texture = json_data.back_image_path
	card_3d.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "front_mini_path" and key != "back_mini_path" and key != "resource_script_path":
			card_3d.card_data[key] = json_data[key]
	card_3d.card_belong_to_id = id
	return card_3d
	

func update_power_label():
	p1_battle_power = 0
	for card in p1_battle_pile:
		p1_battle_power += card.card_data.power
	power_p_1.text = str(p1_battle_power)
