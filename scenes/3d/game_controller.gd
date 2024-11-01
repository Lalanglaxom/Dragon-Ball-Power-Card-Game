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

var start_card_hand_amount: int = 15

var p1_pile := []
var p1_hand_pile := []
var p1_battle_pile := []
var p1_grave_pile := []
var p1_battle_power: int


var p2_pile := []
var p2_hand_pile := []
var p2_battle_pile := []
var p2_grave_pile := []
var p2_battle_power: int

# Turn control
var game_round: int = 0
var round_turn: int = 0

var has_action: bool

var turn_new_round := [1,2]
var current_player_turn := 1

var p1_slot_count = 0
var p2_slot_count = 0

func _ready() -> void:
	Global.draw_pile_updated.connect(draw_card_for_player.rpc)
	Global.card_chosen.connect(place_card.rpc)
	Global.card_3d_flip.connect(flip_card.rpc)
	Global.card_return.connect(return_card.rpc)
	Global.end_turn_pressed.connect(update_turn.rpc)
	Global.end_turn_pressed.connect(update_end_turn_button)
	Global.game_round_end.connect(reset_card_on_field.rpc)
	
	set_new_round_turn()
	
	set_faux_for_player.rpc(Global.faux_cards_chosen[0].card_data.id, \
							Global.faux_cards_chosen[1].card_data.id, \
							multiplayer.get_unique_id())
	
	update_end_turn_button.call_deferred()


func _process(delta: float) -> void:
	pass

	
func set_new_round_turn():
	turn_new_round.shuffle()
	if multiplayer.is_server():
		set_turn.rpc(turn_new_round[0])
		p1_hand.set_turn(turn_new_round[1])
		p1_hand.switch_state(current_player_turn)


@rpc("any_peer","call_remote","reliable")
func set_turn(turn: int):
	p1_hand.set_turn(turn)	
	p1_hand.switch_state(current_player_turn)


@rpc("any_peer", "call_local", "reliable")
func draw_card_for_player():
	if multiplayer.get_unique_id() == 1:
		for i in range(0,start_card_hand_amount):
			var card = full_pile.draw_pile[i]
			p1_pile.append(card)
			p1_hand_pile.append(card)
			card.reparent(p1_hand, true)
			card.card_belong_to_id = multiplayer.get_unique_id()		
		#p1_hand.arrange_hand_card()

		for i in range(start_card_hand_amount, start_card_hand_amount * 2):
			var card = full_pile.draw_pile[i]
			p2_pile.append(card)
			p2_hand_pile.append(card)
			card.reparent(p2_hand, true)
		#p2_hand.arrange_hand_card()

	else:
		for i in range(0,start_card_hand_amount):
			var card = full_pile.draw_pile[i]
			p1_pile.append(card)
			p1_hand_pile.append(card)
			card.reparent(p2_hand, true)

		for i in range(start_card_hand_amount, start_card_hand_amount * 2):
			var card = full_pile.draw_pile[i]
			p2_pile.append(card)
			p2_hand_pile.append(card)
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
			p1_hand_pile.append(card)
			p1_hand.add_card(card)
			Global.print_multi(card.get_parent())
	else:
		var faux_card_1 = Global.create_faux_ui(Global.get_faux_data_by_id(faux_id_1))
		var faux_card_2 = Global.create_faux_ui(Global.get_faux_data_by_id(faux_id_2))
		p2_pile.append(faux_card_1)
		p2_pile.append(faux_card_2)
		p2_hand_pile.append(faux_card_1)
		p2_hand_pile.append(faux_card_2)
		p2_hand.add_card(faux_card_1)
		p2_hand.add_card(faux_card_2)

	
@rpc("any_peer", "call_local", "reliable")
func place_card(card_2d, card_id, id):
	# FIXME: Card P2 don't update
	var card3d = Global.create_card_3d(Global.get_card3d_data_by_id(card_id), id)
	if multiplayer.get_unique_id() == card3d.card_belong_to_id:
		put_card_in_p1_slot(card3d, card_2d, card_id, id)
		p1_slot_count += 1
		
	else:
		p2_hand.card_chosen(card_id, id)
		put_card_in_p2_slot(card3d)
		p2_slot_count += 1

	update_end_turn_button.call_deferred()


func put_card_in_p1_slot(card3d: Card3D, card2d: Card2D, card_id: int, id: int):
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 1 and slot != Grave:
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
						
	update_end_turn_button.call_deferred()
	
@rpc("any_peer","call_local","reliable")
func return_card(card3d, card_id, player_id):
	if multiplayer.get_unique_id() == player_id:
		p1_slot_count -= 1
		card3d.move_out()
		p1_battle_pile.erase(card3d)

	else:
		for card in p2_battle_pile:
			if card.card_data.id == card_id:
				p2_slot_count -= 1
				card.move_out()
				p2_battle_pile.erase(card)
				
	update_end_turn_button.call_deferred()


func send_to_grave(card3d):
	if card3d.card_belong_to_id == multiplayer.get_unique_id():
		card3d.set_direction(Vector2.UP)
		card3d.reparent(grave_1, true)
		p1_grave_pile.push_front(card3d)
		p1_hand.hand_pile_p1.erase(card3d)
		card3d.move_to(Vector3(0, card3d.position.y, 0), 1)
	else:
		card3d.set_direction(Vector2.UP)
		card3d.reparent(grave_2, true)
		p2_grave_pile.push_front(card3d)
		p2_hand.hand_pile_p2.erase(card3d)
		card3d.move_to(Vector3(0, card3d.position.y, 0), 1)

	grave_1.arrange_grave_card()
	grave_2.arrange_grave_card()
	update_end_turn_button.call_deferred()


func update_total_power_label():
	p1_battle_power = 0
	for card in p1_battle_pile:
		p1_battle_power += card.card_data.power
	power_p_1.text = str(p1_battle_power)


@rpc("any_peer","call_local","reliable")
func update_turn():
	
	current_player_turn += 1
	if current_player_turn > 2:
		current_player_turn = 1
	p1_hand.switch_state(current_player_turn)
	
	round_turn += 1
	
	if round_turn >= 2:
		if Global.current_phase == Global.Phase.STANDOFF:
			switch_phase(Global.Phase.BATTLE)
		elif Global.current_phase == Global.Phase.BATTLE:
			if p1_battle_power > p2_battle_power:
				for card in p2_battle_pile:
					if card.direction == Vector2.DOWN:
						return
						
			else:
				for card in p1_battle_pile:
					if card.direction == Vector2.DOWN:
						return
			
			
			switch_phase(Global.Phase.STANDOFF)
			switch_round()
			round_turn = 0

			if p1_hand.hand_pile_p1.size() - 2 <= 0:
				print("PLAYER 2 WIN")
			if p2_hand.hand_pile_p2.size() - 2 <= 0:
				print("PLAYER 1 WIN")
				
	update_end_turn_button.call_deferred()

@rpc("any_peer","call_local","reliable")
func switch_phase(phase: Global.Phase):
	Global.current_phase = phase

func damage_phase_behaviour():
	# TODO: The avatar with stronger attack beat the one with lower attack
	# Then switch_phase
	pass


func switch_round():
	game_round += 1
	reset_card_on_field()
	set_new_round_turn()


@rpc("any_peer","call_local","reliable")
func reset_card_on_field():
	# FIXME: DONT PUT CARD FACE DOWN TO GRAVE
	# FIXME: CAN"T END TURN WITH 1 CARD FACE UP
	# FIXME: CAN END TURN WITHOUT FACE UP
	# FIXME: CAN END TURN WITH 1 FAUX CARD
	# FIXME: GAME GET BROKEN TOWARD THE END
	# FIXME: FACE DOWN CARD GET ALL SEND TO GRAVE WTF
	# FIXME: TWO PLAYER OUT OF CARD WHICH PLAYER STRONGER WIN
	if p1_battle_power > p2_battle_power:
		for card in p2_battle_pile:
			card.health = 2
			
			if card.card_data is not Faux:
				send_to_grave(card)
			else:
				return_faux_card(card, card.card_belong_to_id)
		
		p2_battle_power = 0
		p2_battle_pile.clear()
			
		for card in p1_battle_pile:
			if card.card_data is Battle and card.direction == Vector2.UP:
				card.health -= 1
			
			if card.card_data is Battle and card.health == 0:
				send_to_grave(card)
			elif card.card_data is Faux:
				return_faux_card(card, card.card_belong_to_id)
		
		for slot in player_2_pos.get_children():
			if slot is BattleSlot:
				slot.power_label.hide()
		
		for slot in player_1_pos.get_children():
			if slot is BattleSlot and slot.get_child_count() < 2:
				slot.power_label.hide()
		
		
		for card in p1_grave_pile:
			if p1_battle_pile.has(card):
				p1_battle_pile.erase(card)
				p1_battle_power -= card.card_data.power
			
	else:
		for card in p2_battle_pile:
			if card.card_data is Battle and card.direction == Vector2.UP:
				card.health -= 1
			
			if card.card_data is Battle and card.health == 0:
				send_to_grave(card)
			elif card.card_data is Faux:
				return_faux_card(card, card.card_belong_to_id)
				
		for card in p2_grave_pile:
			if p2_battle_pile.has(card): 
				p2_battle_pile.erase(card)
				p2_battle_power -= card.card_data.power

		
		for card in p1_battle_pile:
			card.health = 2
			
			if card.card_data is not Faux:
				send_to_grave(card)
			else:
				return_faux_card(card, card.card_belong_to_id)
		
		p1_battle_power = 0
		p1_battle_pile.clear()
	
		for slot in player_1_pos.get_children():
			if slot is BattleSlot:
				slot.power_label.hide()
		
		for slot in player_2_pos.get_children():
			if slot is BattleSlot and slot.get_child_count() < 2:
				slot.power_label.hide()
	
	remove_faux_card()

func remove_faux_card():
	for i in range(p1_battle_pile.size() - 1, -1 , -1):
		if p1_battle_pile[i].card_data is Faux:
			p1_battle_pile.remove_at(i)
	
	for i in range(p2_battle_pile.size() - 1, -1 , -1):
		if p2_battle_pile[i].card_data is Faux:
			p2_battle_pile.remove_at(i)


func return_faux_card(card3d, player_id):
	if multiplayer.get_unique_id() == player_id:
		card3d.move_out()
		Global.card_return_local.emit(card3d, card3d.card_data.id, player_id)
	else:
		#for card in p2_battle_pile:
			#if card.card_data.id == card3d.card_data.id:
		card3d.move_out()
		Global.card_return_local.emit(card3d, card3d.card_data.id, player_id)
	

#func check_end_turn_criteria() -> bool:	
	#var valid = false
	#
	#if Global.state != Global.State.YOUR_TURN: return valid
	#
	#if game_round == 0:
		#if Global.current_phase == Global.Phase.STANDOFF:
			#if p1_battle_pile.size() < 3: return valid
			#valid = true
			#return valid
#
		#if Global.current_phase == Global.Phase.BATTLE:
			#if current_player_turn == 1 and round_turn <= 2:
				#if p1_battle_power > 0:
					#valid = true
					#return valid
						#
			#elif current_player_turn == 2 and round_turn <= 2:
				#if p1_battle_power >= p2_battle_power: 
					#valid = true
				#else:
					#if count_card_up() == 3:
						#valid = true
					#
			#elif round_turn > 2:
				#if p1_battle_power >= p2_battle_power:
					#valid = true
					#return valid
				#else:
					#if count_card_up() == 3:
						#valid = true
						#
	#elif game_round > 0:
		#if Global.current_phase == Global.Phase.STANDOFF:
			#if p1_battle_pile.size() < 3: return valid
			#
			#if get_p1_total_power() >= p2_battle_power:
				#valid = true
			#else:
				#valid = count_card_battle_p1_p2() # FIXME: NOT WORK WHEN OTHER HAVE ONLY 1 CARDs
			#return valid						  # FIXME: CAN NOT END TURN WHEN ALL CARD ON FIELD ON ROUND 2
			#
		#if Global.current_phase == Global.Phase.BATTLE:
			#if p1_battle_power >= p2_battle_power:
				#valid = true
				#return valid
			#else: 
				#if count_card_up() == 3:
					#valid = true
#
	#return valid

func check_end_turn_criteria() -> bool:	
	var valid = false
	
	if Global.state != Global.State.YOUR_TURN: return valid


	if p1_battle_pile.size() < 3: return false
	
	if Global.current_phase == Global.Phase.STANDOFF:
		
		if get_p2_num_card() == 0:
			return true
		
		if get_p2_num_card_up() == 0:
			if get_p1_card_battle() > 0:
				return true
			
		if get_p2_num_card_up() > 0:
			if get_p1_total_power() > get_p2_total_power():
				return true
			if get_p1_total_power() < get_p2_total_power():
				if get_p1_card_battle() == get_p2_num_card_up():
					return true
				else:
					return false
					
	if Global.current_phase == Global.Phase.BATTLE:
		if get_p2_num_card_up() == 0:
			if get_p1_num_card_up() > 0:
				return true
			else:
				return false
		
		if get_p2_num_card_up() > 0:
			if get_p1_total_power() > get_p2_total_power():
				return true
			if get_p1_total_power() < get_p2_total_power():
				if get_p1_card_down() > 0:
					return false
			if get_p1_num_card_up() >= get_p2_num_card_up():
				return true
			if get_p1_num_card_up() >= get_p2_1hp_num_card_up():
				return true
		
	# FIXME: NOT WORK WHEN OTHER HAVE ONLY 1 CARDs
	# FIXME: If Other up 1 card this turn, it count toward the total up amount -> khong the thi 2 la

	return valid

func update_end_turn_button():
	if check_end_turn_criteria():
		ui.end_turn.disabled = false
	else:
		ui.end_turn.disabled = true


func get_p2_num_card():
	return p2_battle_pile.size()

func get_p2_num_card_up():
	var total = 0
	
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += 1
			
	return total

func get_p2_1hp_num_card_up():
	var total = 0
	
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP and card.health == 1:
															# or card.health != card.data.health
			total += 1
			
	return total

func get_p2_total_power():
	var total = 0
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += card.card_data.power
	
	return total
	
func get_p1_num_card():
	return p1_battle_pile.size()

func get_p1_num_card_up():
	var total = 0
	
	for card in p1_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += 1
			
	return total


func get_p1_card_battle():
	var total = 0
	for card in p1_battle_pile:
		if card.card_data is Battle:
			total += 1
	return total

func get_p1_total_power():
	var total = 0
	for card in p1_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += card.card_data.power
	
	return total

func get_p1_card_down():
	var total = 0
	
	for card in p1_battle_pile:
		if card.direction == Vector2.DOWN:
			total += 1
	
	return total

func count_card_battle_p1_p2():
	var p1_card_battle_count = 0
	var p2_card_battle_count = 0
	
	var p1_hand_battle_card = 0
	
	for card in p1_battle_pile:
		if card.card_data is Battle:
			p1_card_battle_count += 1
			
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			p2_card_battle_count += 1
	
	
	
	if p1_hand.hand_pile_p1.size() - 2 < p2_card_battle_count:
		return true
	
	return p1_card_battle_count == p2_card_battle_count


func count_card_up():
	var p1_card_up_count = 0
	var p2_card_up_count = 0
	
	var valid = false
	
	for card in p1_battle_pile:

		if card.direction == Vector2.UP:
			p1_card_up_count += 1

			
	for card in p2_battle_pile:

		if card.direction == Vector2.UP:
			p2_card_up_count += 1
			
	
	return p1_card_up_count
