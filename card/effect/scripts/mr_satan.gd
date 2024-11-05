extends Effect
class_name MrSatan

signal func_finished

@export var satan: bool

func activate_effect(game_controller, this_card):
	var temp_array = []
	var faux_1_array = []
	var faux_2_array = []
	
	var index_render = 100
	
	var total_card_p1 = 0
	var total_card_p2 = 0
	
	total_card_p1 = get_p1_battle(game_controller)
	total_card_p2 = get_p2_battle(game_controller)
	
	for card in game_controller.p1_battle_pile:
		if card.card_data is Faux:
			card.flip()
			faux_1_array.append(card)
			continue
			
		temp_array.append(card)
		card.reparent(game_controller.neutral_slot, true)
		card.set_multiplayer_authority(-1)
		
		card.get_node("Back").render_priority = index_render
		
		var tween = game_controller.get_tree().create_tween()
		tween.tween_property(card, "position", Vector3(0,0.01,0), 0.5) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)
		await tween.finished
		
		index_render += 1
		
	for card in game_controller.p2_battle_pile:
		if card.card_data is Faux:
			card.flip()
			faux_2_array.append(card)
			continue
		
		temp_array.append(card)
		card.reparent(game_controller.neutral_slot, true)
		card.set_multiplayer_authority(-1)
		
		card.get_node("Back").render_priority = index_render
		var tween = game_controller.get_tree().create_tween()
		tween.tween_property(card, "position", Vector3(0,0.01,0), 0.5) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)
		await tween.finished
		
		index_render += 1
	
	
	game_controller.neutral_slot.set_array(temp_array)
	
	if game_controller.get_multiplayer_authority() == this_card.get_multiplayer_authority():
		game_controller.neutral_slot.card_array.shuffle()
		game_controller.neutral_slot.make_name_array()
		game_controller.neutral_slot.set_name_array.rpc(game_controller.neutral_slot.name_array)
	else:
		game_controller.get_tree().create_timer(0.1).timeout
	
	
	
	game_controller.p1_battle_pile = faux_1_array
	game_controller.p2_battle_pile = faux_2_array
	
	Global.print_multi(game_controller.neutral_slot.name_array)
	
	if game_controller.get_multiplayer_authority() == this_card.get_multiplayer_authority():
		var i = 0
		for slot in game_controller.player_1_pos.get_children():
			if slot.get_child_count() < 2 and slot is BattleSlot:
				var card = game_controller.neutral_slot.card_array[i]
				card.rotation.y = deg_to_rad(randf_range(-3,3)) 
				card.reparent(slot, true)
				
				var tween = game_controller.get_tree().create_tween()
				tween.tween_property(card, "position", Vector3(0,0.01,0), 0.3) \
					.set_trans(Tween.TRANS_LINEAR) \
					.set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				
				game_controller.p1_battle_pile.append(card)
				card.set_multiplayer_authority(game_controller.get_multiplayer_authority())
				i += 1
				
		i = 0
		
		for slot in game_controller.player_2_pos.get_children():
			if slot.get_child_count() < 2 and slot is BattleSlot:
				var card = game_controller.neutral_slot.card_array[i + total_card_p1]
				card.reparent(slot, true)
				card.rotation.y = deg_to_rad(randf_range(-3,3)) 
				
				var tween = game_controller.get_tree().create_tween()
				tween.tween_property(card, "position", Vector3(0,0.01,0), 0.3) \
					.set_trans(Tween.TRANS_LINEAR) \
					.set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				
				game_controller.p2_battle_pile.append(card)
				card.set_multiplayer_authority(-1)
				i += 1
				
	else:
		var card_array = arrange_card_from_name(game_controller)
		
		var i = 0
		for slot in game_controller.player_1_pos.get_children():
			if slot.get_child_count() < 2 and slot is BattleSlot:
				var card = card_array[i + total_card_p1]
				card.reparent(slot, true)
				card.rotation.y = deg_to_rad(randf_range(-3,3))
				
				var tween = game_controller.get_tree().create_tween()
				tween.tween_property(card, "position", Vector3(0,0.01,0), 0.3) \
					.set_trans(Tween.TRANS_LINEAR) \
					.set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				
				game_controller.p1_battle_pile.append(card)
				card.set_multiplayer_authority(game_controller.get_multiplayer_authority())
				i += 1
				
		i = 0
		
		for slot in game_controller.player_2_pos.get_children():
			if slot.get_child_count() < 2 and slot is BattleSlot:
				var card = card_array[i]
				card.reparent(slot, true)
				card.rotation.y = deg_to_rad(randf_range(-3,3)) 
				
				var tween = game_controller.get_tree().create_tween()
				tween.tween_property(card, "position", Vector3(0,0.01,0), 0.3) \
					.set_trans(Tween.TRANS_LINEAR) \
					.set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				
				game_controller.p2_battle_pile.append(card)
				card.set_multiplayer_authority(-1)
				i += 1
	
	func_finished.emit()

func arrange_card_from_name(controller):
	var array = []
	
	for name in controller.neutral_slot.name_array:
		for i in range(controller.neutral_slot.card_array.size() - 1, -1 , -1):
			var card = controller.neutral_slot.card_array[i]
			if card.card_data.nice_name == name:
				array.append(card)
				controller.neutral_slot.card_array.remove_at(i)
				continue
				
	return array


func get_p1_battle(game_controller):
	var total = 0
	for card in game_controller.p1_battle_pile:
		if card.card_data is Battle:
			total += 1
	
	return total
	
func get_p2_battle(game_controller):
	var total = 0
	for card in game_controller.p1_battle_pile:
		if card.card_data is Battle:
			total += 1
	
	return total


func move_to_zero(controller, card):
	var tween = controller.get_tree().create_tween()
	tween.tween_property(card, "position", Vector3(0,0.01,0), 1) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN)
	await tween.finished
