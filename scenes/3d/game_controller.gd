extends Node

signal end_turn_valid

@onready var full_pile: Control = $"../FullPile"

@onready var player_1_pos: Node3D = $"../CardPosition/Player 1"
@onready var p1_hand: Control = $"../HandContainerP1"
@onready var power_p_1: Label = $"../CanvasLayer/UI/PowerP1"
@onready var grave_1: Node3D = $"../CardPosition/Player 1/Grave 1"

@onready var player_2_pos: Node3D = $"../CardPosition/Player 2"
@onready var p2_hand: Control = $"../HandContainerP2"
@onready var grave_2: Node3D = $"../CardPosition/Player 2/Grave 2"


@onready var ui: Control = $"../CanvasLayer/UI"
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

# Turn control
var game_turn: int = 0



var has_action: bool

var turn_new_round := [1,2]
var current_player_turn := 1
var amount_turns_end := 0

var p1_slot_count = 0
var p2_slot_count = 0

func _ready() -> void:
	Global.draw_pile_updated.connect(draw_card_for_player.rpc)
	Global.card_chosen.connect(place_card.rpc)
	Global.card_3d_flip.connect(flip_card.rpc)
	Global.card_return.connect(return_card.rpc)
	Global.end_turn_pressed.connect(update_turn.rpc)
	Global.game_turn_end.connect(send_to_grave)
	
	set_new_round_turn()
	
	#set_faux_for_player.rpc(Global.faux_cards_chosen[0].card_data.id, \
							#Global.faux_cards_chosen[1].card_data.id, \
							#multiplayer.get_unique_id())


func _process(delta: float) -> void:
	if check_end_turn_criteria():
		ui.end_turn.disabled = false
	else:
		ui.end_turn.disabled = true

func set_new_round_turn():
	turn_new_round.shuffle()
	if multiplayer.is_server():
		set_turn.rpc(turn_new_round[0])
		p1_hand.set_turn(turn_new_round[1])
		p1_hand.switch_state(current_player_turn)


@rpc("any_peer","call_remote")
func set_turn(turn: int):
	p1_hand.set_turn(turn)	
	p1_hand.switch_state(current_player_turn)


@rpc("any_peer", "call_local", "reliable")
func draw_card_for_player():
	if multiplayer.get_unique_id() == 1:
		for i in range(0,start_card_hand_amount):
			var card = full_pile.draw_pile[i]
			p1_pile.append(card)
			card.reparent(p1_hand, true)
			card.card_belong_to_id = multiplayer.get_unique_id()		
		#p1_hand.arrange_hand_card()

		for i in range(start_card_hand_amount, start_card_hand_amount * 2):
			var card = full_pile.draw_pile[i]
			p2_pile.append(card)
			card.reparent(p2_hand, true)
		#p2_hand.arrange_hand_card()

	else:
		for i in range(0,start_card_hand_amount):
			var card = full_pile.draw_pile[i]
			p1_pile.append(card)
			card.reparent(p2_hand, true)

		for i in range(start_card_hand_amount, start_card_hand_amount * 2):
			var card = full_pile.draw_pile[i]
			p2_pile.append(card)
			card.reparent(p1_hand, true)
			card.card_belong_to_id = multiplayer.get_unique_id()
	
	
	p1_hand.arrange_hand_card()
	p2_hand.arrange_hand_card()
			


@rpc("any_peer", "call_local", "reliable")
func set_faux_for_player(faux_id_1: int, faux_id_2: int, player_id: int):
	if multiplayer.get_unique_id() == player_id:
		for card in Global.faux_cards_chosen:
			card.card_belong_to_id = player_id
			p1_pile.append(card)
			p1_hand.add_card(card)
			Global.print_multi(card.get_parent())
	else:
		var faux_card_1 = Global.create_faux_ui(Global.get_faux_data_by_id(faux_id_1))
		var faux_card_2 = Global.create_faux_ui(Global.get_faux_data_by_id(faux_id_2))
		p2_pile.append(faux_card_1)
		p2_pile.append(faux_card_2)
		p2_hand.add_card(faux_card_1)
		p2_hand.add_card(faux_card_2)

	
@rpc("any_peer", "call_local", "reliable")
func place_card(card_2d, card_id, id):
	
	var card3d = create_card_3d(get_card3d_data_by_id(card_id), id)
	if multiplayer.get_unique_id() == card3d.card_belong_to_id:

		put_card_in_p1_slot(card3d, card_2d, card_id, id)
		p1_slot_count += 1
		
	else:
		
		p2_hand.card_chosen(card_id, id)
		put_card_in_p2_slot(card3d)
		p2_slot_count += 1


func put_card_in_p1_slot(card3d: Card3D, card2d: Card2D, card_id: int, id: int):
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 1 and slot.name != "Grave":
			slot.add_child(card3d)
			p1_battle_pile.append(card3d)
			p1_hand.card_chosen(card2d, card_id, id)
			return


func put_card_in_p2_slot(card3d: Card3D):
	for slot in player_2_pos.get_children():
		if slot.get_child_count() == 1 and slot.name != "Grave":
			slot.add_child(card3d)
			p2_battle_pile.append(card3d)
			return


@rpc("any_peer", "call_local", "reliable")
func flip_card(card_3d, card_id, player_id):
	if multiplayer.get_unique_id() == player_id:
		card_3d.flip()
		if card_3d.card_data is Battle:
			var card_slot = card_3d.get_parent()
			card_slot.set_target_power(card_3d.card_data.power, card_3d.direction)
			if card_3d.direction == Vector2.UP:
				p1_battle_power += card_3d.card_data.power
			else:
				p1_battle_power -= card_3d.card_data.power
	else:
		for card in p2_battle_pile:
			if card.card_data.id == card_id:
				card.flip()
				if card.card_data is Battle:
					var card_slot = card.get_parent()
					card_slot.set_target_power(card.card_data.power, card.direction)
					if card.direction == Vector2.UP:
						p2_battle_power += card.card_data.power
					else:
						p2_battle_power -= card.card_data.power
					
	Global.print_multi(p1_battle_power)
	Global.print_multi(p2_battle_power)

@rpc("any_peer","call_local","reliable")
func return_card(card3d, card_id, player_id):
	if multiplayer.get_unique_id() == player_id:
		p1_slot_count -= 1
		card3d.move_out()
		p1_battle_pile.erase(card3d)
		Global.print_multi(p1_slot_count)
	else:
		for card in p2_battle_pile:
			if card.card_data.id == card_id:
				p2_slot_count -= 1
				card.move_out()
				p2_battle_pile.erase(card)


func send_to_grave(card3d, player_grave: int):
	if player_grave == 1:
		p1_battle_pile.erase(card3d)
		p1_grave_pile.append(card3d)

		card3d.reparent(grave_1, true)
		card3d.move_to(Vector3(0, card3d.position.y, 0))
	else:
		p2_battle_pile.erase(card3d)
		p2_grave_pile.append(card3d)

		card3d.reparent(grave_2, true)
		card3d.move_to(Vector3(0, card3d.position.y, 0))

	grave_1.arrange_grave_card()
	grave_2.arrange_grave_card()


func get_card3d_data_by_id(id : int):
	if id >= 2000:
		for json_data in Global.faux_database:
			if int(json_data.id) == id:
				return json_data
		Global.print_multi("Null 3D Data")
		return null

	for json_data in full_pile.battle_database:
		if int(json_data.id) == id:
			return json_data
	Global.print_multi("Null 3D Data")
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
	

func update_total_power_label():
	p1_battle_power = 0
	for card in p1_battle_pile:
		p1_battle_power += card.card_data.power
	power_p_1.text = str(p1_battle_power)


@rpc("any_peer","call_local")
func update_turn():
	current_player_turn += 1
	if current_player_turn > 2:
		current_player_turn = 1
	p1_hand.switch_state(current_player_turn)
	
	amount_turns_end += 1
	
	if amount_turns_end == 2:
		switch_phase()
		amount_turns_end = 0



@rpc("any_peer","call_local","reliable")
func switch_phase():
	if Global.current_phase == Global.Phase.STANDOFF:
		Global.current_phase = Global.Phase.BATTLE
		
	else:
		game_turn += 1
		Global.current_phase = Global.Phase.STANDOFF
		reset_card_on_field()
		set_new_round_turn()


func reset_card_on_field():
	for card in p1_battle_pile:
		if card.card_data is Battle:
			send_to_grave(card,1)
			
	for card in p2_battle_pile:
		if card.card_data is Battle:
			send_to_grave(card,2)

func check_end_turn_criteria() -> bool:
	var valid = false
	
	if Global.state != Global.State.YOUR_TURN: return valid
	
	if game_turn == 0:
		if Global.current_phase == Global.Phase.STANDOFF:
			if p1_battle_pile.size() < 3: return valid
			valid = true
			return valid
	else:
		if Global.current_phase == Global.Phase.STANDOFF:
			if p1_battle_pile.size() < 3: return valid
			
			var total_power = 0
			for card in p1_battle_pile:
				total_power += card.card_data.power
			
			if total_power >= p2_battle_power:
				valid = true
			else:
				valid = count_card()
			return valid
			
	if Global.current_phase == Global.Phase.BATTLE:
		if current_player_turn == 1:
			for card in p1_battle_pile:
				if card.direction == Vector2.UP:
					valid = true
		else:
			if p1_battle_power >= p2_battle_power: 
				valid = true
			else:
				valid = count_card()
			
	
	return valid


func count_card():
	var p1_card_count = 0
	var p2_card_count = 0
	
	var valid = false
	
	for card in p1_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			p1_card_count += 1
			
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			p2_card_count += 1
		
	if p1_card_count >= p2_card_count:
		valid = true
	
	return valid
