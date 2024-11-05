extends Node

signal effect_anim_finished

@onready var full_pile: Control = $"../FullPile"

@onready var player_1_pos: Node3D = $"../CardPosition/Player 1"
@onready var p1_hand: Control = $"../HandContainerP1"
@onready var power_p_1: Label = $"../CanvasLayer/UI/PowerP1"
@onready var grave_1: Node3D = $"../CardPosition/Player 1/Grave 1"

@onready var player_2_pos: Node3D = $"../CardPosition/Player 2"
@onready var p2_hand: Control = $"../HandContainerP2"
@onready var grave_2: Node3D = $"../CardPosition/Player 2/Grave 2"

@onready var neutral_slot: Node3D = $"../CardPosition/Neutral"


@onready var ui: Control = $"../CanvasLayer/UI"
const CARD_3D = preload("res://scenes/3d/card_3d.tscn")

var start_battle_hand_amount: int = 5
var start_effect_hand_amount: int = 2

var p1_pile := []
var p1_hand_pile := []
var p1_battle_pile := []
var p1_spell_pile := []
var p1_grave_pile := []
var p1_battle_power: int


var p2_pile := []
var p2_hand_pile := []
var p2_battle_pile := []
var p2_spell_pile := []
var p2_grave_pile := []
var p2_battle_power: int

# some card control

var spell_index: int = 0

# Turn control
var game_round: int = 0
var round_turn: int = 0

var has_action: bool

var turn_new_round := [1,2]
var current_player_turn := 1

var p1_win: bool = false
var game_ended: bool = false

func _ready() -> void:
	Global.draw_pile_updated.connect(draw_card_for_player.rpc)
	Global.card_chosen.connect(place_card.rpc)
	ui.get_node("CardOption").flip_button_pressed.connect(flip_card.rpc)
	ui.get_node("CardOption").use_effect_pressed.connect(use_effect.rpc)
	Global.return_chosen.connect(return_card.rpc)
	Global.end_turn_pressed.connect(update_turn.rpc)
	Global.end_turn_pressed.connect(update_end_turn_button.rpc)
	Global.game_round_end.connect(reset_card_on_field.rpc)
	
	set_multiplayer_authority(multiplayer.get_unique_id())
	
	if multiplayer.is_server():
		set_start_hand.rpc(Global.start_hand_amount)
	
	set_faux_for_player.rpc(Global.faux_cards_chosen[0].card_data.nice_name, \
							Global.faux_cards_chosen[1].card_data.nice_name, \
							multiplayer.get_unique_id())
	
	set_new_round_turn()
	update_end_turn_button.call_deferred()

# FIXME: CREATE 2 card if click too fast

func _process(delta: float) -> void:
	pass



@rpc("any_peer","call_remote","reliable")
func set_randomizer_seed(num: int):
	seed(num)


@rpc("any_peer","call_local","reliable")
func set_start_hand(num: int):
	start_battle_hand_amount = num


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
	Global.finished_set_turn.emit()


@rpc("any_peer", "call_local", "reliable")
func draw_card_for_player():
	if multiplayer.get_unique_id() == 1:
		for i in range(0,start_battle_hand_amount):
			var card = full_pile.draw_pile_battle[i]
			p1_pile.append(card)
			p1_hand_pile.append(card)
			card.reparent(p1_hand, true)
			card.set_multiplayer_authority(1)
			
		for i in range(start_battle_hand_amount, start_battle_hand_amount * 2):
			var card = full_pile.draw_pile_battle[i]
			p2_pile.append(card)
			p2_hand_pile.append(card)
			card.reparent(p2_hand, true)
			card.set_multiplayer_authority(-1) # HACK: For some reason the default id is 0
		
		for i in range(0,start_effect_hand_amount):
			var card = full_pile.draw_pile_effect[i]
			p1_pile.append(card)
			p1_hand_pile.append(card)
			card.reparent(p1_hand, true)
			card.set_multiplayer_authority(1)

		for i in range(start_effect_hand_amount, start_effect_hand_amount * 2):
			var card = full_pile.draw_pile_effect[i]
			p2_pile.append(card)
			p2_hand_pile.append(card)
			card.reparent(p2_hand, true)
			card.set_multiplayer_authority(-1) # HACK: For some reason the default id is 0

	else:
		for i in range(0,start_battle_hand_amount):
			var card = full_pile.draw_pile_battle[i]
			p2_pile.append(card)
			p2_hand_pile.append(card)
			card.reparent(p2_hand, true)
			card.set_multiplayer_authority(1)
			
		for i in range(start_battle_hand_amount, start_battle_hand_amount * 2):
			var card = full_pile.draw_pile_battle[i]
			p1_pile.append(card)
			p1_hand_pile.append(card)
			card.reparent(p1_hand, true)
			card.set_multiplayer_authority(multiplayer.get_unique_id())
		
		for i in range(0,start_effect_hand_amount):
			var card = full_pile.draw_pile_effect[i]
			p2_pile.append(card)
			p2_hand_pile.append(card)
			card.reparent(p2_hand, true)
			card.set_multiplayer_authority(1)
			
		for i in range(start_effect_hand_amount, start_effect_hand_amount * 2):
			var card = full_pile.draw_pile_effect[i]
			p1_pile.append(card)
			p1_hand_pile.append(card)
			card.reparent(p1_hand, true)
			card.set_multiplayer_authority(multiplayer.get_unique_id())
			
	p1_hand.arrange_hand_card()
	p2_hand.arrange_hand_card()


func set_card_2D(card: Card2D, player_id: int):
	if player_id == multiplayer.get_unique_id():
		p1_hand.add_card(card)
		p1_hand_pile.append(card)

@rpc("any_peer", "call_local", "reliable")
func set_faux_for_player(faux_name_1: String, faux_name_2: String, player_id: int):
	if multiplayer.get_unique_id() == player_id:
		for card in Global.faux_cards_chosen:
			card.set_multiplayer_authority(player_id)
			p1_pile.append(card)
			p1_hand_pile.append(card)
			p1_hand.add_card(card)

	else:
		var faux_card_1 = Global.create_faux_ui(faux_name_1)
		var faux_card_2 = Global.create_faux_ui(faux_name_2)
		faux_card_1.set_multiplayer_authority(-1)
		faux_card_2.set_multiplayer_authority(-1)
		p2_pile.append(faux_card_1)
		p2_pile.append(faux_card_2)
		p2_hand_pile.append(faux_card_1)
		p2_hand_pile.append(faux_card_2)
		p2_hand.add_card(faux_card_1)
		p2_hand.add_card(faux_card_2)


@rpc("any_peer", "call_local", "reliable")
func place_card(card_2d, card_name):
	# FIXME: Card P2 don't update
	# FIXME: Can't open flip button
	
	var card3d = Global.create_card_3d(card_name, multiplayer.get_remote_sender_id())

	if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
		put_card_in_p1_slot(card3d, card_2d)
		
	else:
		if !is_p2_slot_available() and card3d.card_data is Battle:
			return
		
		p2_hand.card_chosen(card3d.card_data.id)
		put_card_in_p2_slot(card3d)
		

	update_end_turn_button.rpc()


func put_card_in_p1_slot(card3d: Card3D, card2d: Card2D):
	if card3d.card_data is Effect:
		for slot in player_1_pos.get_children():
			if slot is SpellSLot:
				card3d.rotation.y = deg_to_rad(randf_range(-45,45))
				spell_index += 1
				card3d.get_node("Front").render_priority = spell_index
				p1_spell_pile.append(card3d)
				slot.add_child(card3d)
				p1_hand.card_chosen(card2d)
				effect_anim_finished.emit()
				return
	
	for slot in player_1_pos.get_children():
		if slot.get_child_count() == 1 and slot is BattleSlot:
			card3d.rotation.y = deg_to_rad(randf_range(-3,3)) 
			slot.add_child(card3d)
			p1_battle_pile.append(card3d)
			p1_hand.card_chosen(card2d)
			return
# TODO: Create new 2d when put on hand again

func put_card_in_p2_slot(card3d: Card3D):
	if card3d.card_data is Effect:
		for slot in player_2_pos.get_children():
			if slot is SpellSLot:
				p2_spell_pile.append(card3d)
				slot.add_child(card3d)
				card3d.rotation.y = deg_to_rad(randf_range(-45,45))
				spell_index += 1
				card3d.get_node("Front").render_priority = spell_index
				effect_anim_finished.emit()
				return

	for slot in player_2_pos.get_children():
		if slot.get_child_count() == 1 and slot is BattleSlot:
			slot.add_child(card3d)
			card3d.rotation.y = deg_to_rad(randf_range(-3,3))
			p2_battle_pile.append(card3d)
			return


# HACK: Not cool
func is_p2_slot_available():
	var slot_count = 0
	
	for slot in player_2_pos.get_children():
		if slot.get_child_count() == 1 and slot != Grave:
			slot_count += 1
	
	return slot_count > 0


@rpc("any_peer", "call_local", "reliable")
func flip_card(card_3d, card_id, player_id):
	if multiplayer.get_unique_id() == player_id:
		card_3d.flip()
		if card_3d.card_data is Battle:
			var card_slot = card_3d.get_parent()
			card_slot.set_target_power(card_3d.properties.power, card_3d.direction)
			if card_3d.direction == Vector2.UP:
				p1_battle_power += card_3d.properties.power
			else:
				p1_battle_power -= card_3d.properties.power
	else:
		for card in p2_battle_pile:
			if card.card_data.id == card_id:
				card.flip()
				if card.card_data is Battle:
					var card_slot = card.get_parent()
					card_slot.set_target_power(card.properties.power, card.direction)
					if card.direction == Vector2.UP:
						p2_battle_power += card.properties.power
					else:
						p2_battle_power -= card.properties.power
						
	update_end_turn_button.rpc()





@rpc("any_peer","call_local","reliable")
func use_effect(card, card_name, player_id):
	place_card(card, card_name)
	
	p1_hand.switch_state(99)
	
	Global.card2d_button_unneeded.emit()
	
	await get_tree().create_timer(2).timeout

	if get_multiplayer_authority() == player_id:
		var eff_callable = Callable(card.card_data, "activate_effect")
		eff_callable.call(self, card)
		await card.card_data.func_finished
		
		p1_hand.switch_state(current_player_turn)

	else:
		for card3d in p2_spell_pile:
			if card3d.card_data.nice_name == card_name:
				var eff_callable = Callable(card3d.card_data, "activate_effect")
				eff_callable.call(self, card3d)
				
				await card3d.card_data.func_finished
				p1_hand.switch_state(current_player_turn)


@rpc("any_peer","call_local","reliable")
func return_card(card3d, card_name, player_id):
	if get_multiplayer_authority() == player_id:
		card3d.move_out()
		p1_battle_pile.erase(card3d)
		Global.card_returned.emit(card3d)
	else:
		for card in p2_battle_pile:
			if card.card_data.nice_name == card_name:
				card.move_out()
				p2_battle_pile.erase(card)
				Global.card_returned.emit(card)
				
	update_end_turn_button.rpc()


func send_to_grave(card3d):
	if card3d.get_multiplayer_authority() == multiplayer.get_unique_id():
		card3d.set_direction(Vector2.UP)
		card3d.reparent(grave_1, true)
		p1_grave_pile.append(card3d)
		p1_hand.hand_pile_p1.erase(card3d)
		card3d.move_to_grave(Vector3(0, card3d.position.y, 0), 1)
	else:
		
		card3d.set_direction(Vector2.UP)
		card3d.reparent(grave_2, true)
		p2_grave_pile.append(card3d)
		p2_hand.hand_pile_p2.erase(card3d)
		card3d.move_to_grave(Vector3(0, card3d.position.y, 0), 1)
	
	await card3d.moved_to_grave
	
	grave_1.arrange_grave_card()
	grave_2.arrange_grave_card()
	
	update_end_turn_button.rpc()


func update_total_power_label():
	p1_battle_power = 0
	for card in p1_battle_pile:
		p1_battle_power += card.properties.power
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
			var phase = Global.Phase.STANDOFF # HACK: Can not find a way to not show the end turn text 
			var can_switch_round = true
			
			if p1_battle_power > p2_battle_power:
				for card in p2_battle_pile:
					if card.direction == Vector2.DOWN:
						phase = Global.Phase.BATTLE
						can_switch_round = false
						
			else:
				for card in p1_battle_pile:
					if card.direction == Vector2.DOWN:
						phase = Global.Phase.BATTLE
						can_switch_round = false
			
			if get_p1_total_power() > get_p2_total_up_power():
				p1_win = true
			else:
				p1_win = false
				
			
			switch_phase(phase)

			if can_switch_round:
				damage_phase_behaviour()
				
				reset_card_on_field()
				
				if get_p2_battle_hand() <= 0 and get_p2_num_card_up() == 0:
					end_game()
					return
				
				if get_p1_battle_hand() <= 0 and get_p1_num_card_up() == 0:
					end_game()
					return
				
				set_new_round_turn()
				round_turn = 0
				game_round += 1
				
	if game_ended:
		return
	
	ui.show_player_turn()
	
	update_end_turn_button.rpc()

@rpc("any_peer","call_local","reliable")
func switch_phase(phase: Global.Phase):
	Global.current_phase = phase


func damage_phase_behaviour():
	pass


@rpc("any_peer","call_local","reliable")
func end_game():
	game_ended = true
	if p1_win == true:
		ui.show_player_win(1)
	else:
		ui.show_player_win(0)


@rpc("any_peer","call_local","reliable")
func reset_card_on_field():
	Global.card3d_button_unneeded.emit()
	Global.card2d_button_unneeded.emit()
	
	if p1_battle_power > p2_battle_power:
		for card in p2_battle_pile:
			card.properties.health = 2
			
			if card.card_data is Battle:
				send_to_grave(card)
			else:
				return_faux_card(card, card.get_multiplayer_authority())
		
		p2_battle_power = 0
		p2_battle_pile.clear()
			
		for card in p1_battle_pile:
			if card.card_data is Battle and card.direction == Vector2.UP:
				card.properties.health -= 1
			
			if card.card_data is Battle and card.properties.health == 0:
				send_to_grave(card)
			elif card.card_data is Faux:
				return_faux_card(card, card.get_multiplayer_authority())
		
		for slot in player_2_pos.get_children():
			if slot is BattleSlot:
				slot.power_label.hide()
		
		for slot in player_1_pos.get_children():
			if slot is BattleSlot and slot.get_child_count() < 2:
				slot.power_label.hide()
		
		
		for card in p1_grave_pile:
			if p1_battle_pile.has(card):
				p1_battle_pile.erase(card)
				p1_battle_power -= card.properties.power
			
	else:
		for card in p2_battle_pile:
			if card.card_data is Battle and card.direction == Vector2.UP:
				card.properties.health -= 1
			
			if card.card_data is Battle and card.properties.health == 0:
				send_to_grave(card)
			elif card.card_data is Faux:
				return_faux_card(card, card.get_multiplayer_authority())
				
		for card in p2_grave_pile:
			if p2_battle_pile.has(card): 
				p2_battle_pile.erase(card)
				p2_battle_power -= card.properties.power

		
		for card in p1_battle_pile:
			card.properties.health = 2
			
			if card.card_data is not Faux:
				send_to_grave(card)
			else:
				return_faux_card(card, card.get_multiplayer_authority())
		
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

	else:
		for card in p2_battle_pile:
			if card.card_data.id == card3d.card_data.id:
				card3d.move_out()
		
	Global.card_returned.emit(card3d.card_data.id)


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
		
		if get_p1_card_hand() - 2 <= get_p2_num_card_up():
			if get_p1_num_card() == 3:
				return true
			
		if get_p2_num_card_up() > 0:
			if get_p1_total_power() >= get_p2_total_up_power():
				return true
			if get_p1_total_power() < get_p2_total_up_power():
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

		if get_p1_card_hand() - 2 <= get_p2_num_card_up():
			if get_p1_card_down() == 0:
				return true
		
		if get_p2_num_card_up() > 0:
			if get_p1_total_up_power() > get_p2_total_up_power():
				return true
			if get_p1_total_up_power() < get_p2_total_up_power():
				if get_p1_card_down() > 0:
					return false
			if get_p1_num_card_up() >= get_p2_num_card_up():
				return true
			if get_p1_num_card_up() >= get_p2_1hp_num_card_up():
				return true
	
	return valid


@rpc("any_peer","call_local","reliable")
func update_end_turn_button():
	if check_end_turn_criteria():
		ui.end_turn.disabled = false
	else:
		ui.end_turn.disabled = true


func find_card(card_name: String):
	for card in p1_battle_pile:
		if card.card_data.nice_name == card_name:
			return card
	for card in p2_battle_pile:
		if card.card_data.nice_name == card_name:
			return card
	for card in p1_grave_pile:
		if card.card_data.nice_name == card_name:
			return card
	for card in p2_grave_pile:
		if card.card_data.nice_name == card_name:
			return card
	for card in p1_spell_pile:
		if card.card_data.nice_name == card_name:
			return card
	for card in p2_spell_pile:
		if card.card_data.nice_name == card_name:
			return card


func print_card_status():
	print("p1 num card: ", str(get_p1_num_card()))
	print("p1 num card up: ", str(get_p1_num_card_up()))
	print("p1 card battle: ", str(get_p1_card_battle()))
	print("p1 total power: ", str(get_p1_total_power()))
	print("p1 total up power: ", str(get_p1_total_up_power()))
	print("p1 card down: ", str(get_p1_card_down()))
	
	print("p2 num card: ", str(get_p2_num_card()))
	print("p2 num card up: ", str(get_p2_num_card_up()))
	print("p2 1hp card: ", str(get_p2_1hp_num_card_up()))
	print("p2 total up power: ", str(get_p2_total_up_power()))


func get_p2_num_card():
	return p2_battle_pile.size()

func get_p2_card_hand():
	return p2_hand.hand_pile_p2.size()

func get_p2_num_card_up():
	var total = 0
	
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += 1
			
	return total

func get_p2_1hp_num_card_up():
	var total = 0
	
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP and card.properties.health == 1:
															# or card.properties.health != card.data.properties.health
			total += 1
			
	return total

func get_p2_total_up_power():
	var total = 0
	for card in p2_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += card.properties.power
	
	return total

func get_p2_battle_hand():
	var total = 0
	for card in p2_hand.hand_pile_p2:
		if card.card_data is Battle:
			total += 1
	return total

func get_p1_num_card():
	return p1_battle_pile.size()

func get_p1_card_hand():
	return p1_hand.hand_pile_p1.size()

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
		if card.card_data is Battle:
			total += card.properties.power
	
	return total

func get_p1_total_up_power():
	var total = 0
	for card in p1_battle_pile:
		if card.card_data is Battle and card.direction == Vector2.UP:
			total += card.properties.power
	
	return total

func get_p1_card_down():
	var total = 0
	
	for card in p1_battle_pile:
		if card.direction == Vector2.DOWN:
			total += 1
	
	return total

func get_p1_battle_hand():
	var total = 0
	for card in p1_hand.hand_pile_p1:
		if card.card_data is Battle:
			total += 1
	return total
