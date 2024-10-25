#class_name CardPileUI_Old extends Control
#
#signal draw_pile_updated
#signal hand_pile_p1_updated
#signal discard_pile_updated
#signal card_removed_from_dropzone(dropzone : CardDropzone, card: CardUI)
#signal card_added_to_dropzone(dropzone : CardDropzone, card: CardUI)
#signal card_hovered(card: CardUI)
#signal card_unhovered(card: CardUI)
#signal hand_card_clicked(card: CardUI)
#signal hand_card_unclicked(card:CardUI)
#signal battle_card_clicked(card: CardUI)
#signal card_flipped_up(card_ui: CardUI)
#signal card_flipped_down(card_ui: CardUI)
#signal card_dropped(card: CardUI)
#signal card_removed_from_game(card: CardUI)
#
#enum Piles {
	#draw_pile,
	#hand_pile_p1,
	#hand_pile_p2,
	#hand_pile_p3,
	#grave_pile_p1,
	#grave_pile_p2,
	#grave_pile_p3,
	#discard_pile
#}
#
#enum PilesCardLayouts {
	#up,
	#left,
	#right,
	#down
#}
#
#@export_file("*.json") var json_card_database_path : String
#@export_file("*.json") var json_card_collection_path : String
#@export var extended_card_ui : PackedScene
#
#@export_group("Pile Positions")
#@export var draw_pile_position = Vector2(20, 460)
#@export var hand_pile_p1_position_node = Control
#@export var hand_pile_p2_position_node = Control
#@export var hand_pile_p3_position_node = Control
#@export var discard_pile_position = Vector2(1250, 460)
#
#@export_group("Pile Displays")
#@export var stack_display_gap := 8
#@export var max_stack_display := 6
#
#
#@export_group("Cards")
#@export var card_return_speed := 0.15
#
#@export_group("Draw Pile")
#@export var click_draw_pile_to_draw := true
#@export var cant_draw_at_hand_limit := true
#@export var shuffle_discard_on_empty_draw := true
#@export var draw_pile_layout := PilesCardLayouts.up
#
#@export_group("Hand Pile")
#@export var hand_enabled := true
#@export var hand_face_up := true
#@export var max_hand_size := 10 # if any more cards are added to the hand, they are immediately discarded
#@export var max_hand_spread := 700
#@export var card_ui_hover_distance := 30
#@export var drag_when_clicked := true
### This works best as a 2-point linear rise from -X to +X
#@export var hand_rotation_curve : Curve
### This works best as a 3-point ease in/out from 0 to X to 0
#@export var hand_vertical_curve : Curve
##@export var drag_sort_enabled := true this would be nice to have, but based on how dragging works I'm not 100% sure how to handle it, possibly disable mouse input on the card being dragged? 
#
#@export_group("Discard Pile")
#@export var discard_face_up := true
#@export var discard_pile_layout := PilesCardLayouts.up
#
#
#var card_database := [] # an array of JSON `Card` data
#var card_collection := [] # an array of JSON `Card` data
#
#var _draw_pile := [] # an array of `CardUI`s
#var _hand_pile_p1 := [] # an array of `CardUI`s
#var _hand_pile_p2 := [] # an array of `CardUI`s
#var _hand_pile_p3 := [] # an array of `CardUI`s
#var _discard_pile := [] # an array of `CardUI`s
#
#
#var spread_curve := Curve.new()
#var hand_pile_p1_position: Vector2
#var hand_pile_p2_position: Vector2
#var hand_pile_p3_position: Vector2
#
#func _ready():
	#hand_pile_p1_position = hand_pile_p1_position_node.position
	##hand_pile_p2_position = hand_pile_p2_position_node.position
	#size = Vector2.ZERO
	#spread_curve.add_point(Vector2(0, -1), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	#spread_curve.add_point(Vector2(1, 1), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	#load_json_path()
	#_reset_card_collection()
	#reset_target_positions()
#
#
## this is really the only way we should move cards between piles
#func set_card_pile(card : CardUI, pile : Piles):
	#_maybe_remove_card_from_any_piles(card)
	#_maybe_remove_card_from_any_dropzones(card)
	#if pile == Piles.discard_pile:
		#_discard_pile.push_back(card)
		#emit_signal("discard_pile_updated")
	#if pile == Piles.hand_pile_p1:
		#_hand_pile_p1.push_back(card)
		#emit_signal("hand_pile_p1_updated")
	#if pile == Piles.hand_pile_p2:
		#_hand_pile_p2.push_back(card)
		#emit_signal("hand_pile_p2_updated")
	#if pile == Piles.hand_pile_p3:
		#_hand_pile_p3.push_back(card)
		#emit_signal("hand_pile_p3_updated")
	#if pile == Piles.draw_pile:
		#_draw_pile.push_back(card)
		#emit_signal("draw_pile_updated")
	#reset_target_positions()
	#
#func set_card_dropzone(card : CardUI, dropzone : CardDropzone):
	#_maybe_remove_card_from_any_piles(card)
	#_maybe_remove_card_from_any_dropzones(card)
	#dropzone.add_card(card)
	#emit_signal("card_added_to_dropzone", dropzone, card)
	#reset_target_positions()
	#
#func remove_card_from_game(card : CardUI):
	#_maybe_remove_card_from_any_piles(card)
	#_maybe_remove_card_from_any_dropzones(card)
	#emit_signal("card_removed_from_game", card)
	#card.queue_free()
	#reset_target_positions()
	#
#func is_hand_enabled():
	#return hand_enabled
#
#func get_cards_in_pile(pile : Piles):
	#if pile == Piles.discard_pile:
		#return _discard_pile.duplicate() # duplicating these so the end user can manipulate the returned array without touching the originals (like doing a forEach remove)
	#elif pile == Piles.hand_pile_p1:
		#return _hand_pile_p1.duplicate()
	#elif pile == Piles.hand_pile_p2:
		#return _hand_pile_p2.duplicate()
	#elif pile == Piles.hand_pile_p3:
		#return _hand_pile_p3.duplicate()
	#elif pile == Piles.draw_pile:
		#return _draw_pile.duplicate()
	#return []
	#
#func get_card_in_pile_at(pile : Piles, index : int):
	#if pile == Piles.discard_pile and _discard_pile.size() > index:
		#return _discard_pile[index]
	#elif pile == Piles.draw_pile and _draw_pile.size() > index:
		#return _draw_pile[index]
	#elif pile == Piles.hand_pile_p1 and _hand_pile_p1.size() > index:
		#return _hand_pile_p1[index]
	#return null
		#
#func get_card_pile_size(pile : Piles):
	#if pile == Piles.discard_pile:
		#return _discard_pile.size()
	#elif pile == Piles.hand_pile_p1:
		#return _hand_pile_p1.size()
	#elif pile == Piles.hand_pile_p2:
		#return _hand_pile_p2.size()
	#elif pile == Piles.hand_pile_p3:
		#return _hand_pile_p3.size()
	#elif pile == Piles.draw_pile:
		#return _draw_pile.size()
	#return 0
	#
#
#
#func _maybe_remove_card_from_any_piles(card : CardUI):
	#if _hand_pile_p1.find(card) != -1:
		#_hand_pile_p1.erase(card)
		#emit_signal("hand_pile_p1_updated")
	#if _hand_pile_p2.find(card) != -1:
		#_hand_pile_p2.erase(card)
		#emit_signal("hand_pile_p2_updated")		
	#if _hand_pile_p3.find(card) != -1:
		#_hand_pile_p3.erase(card)
		#emit_signal("hand_pile_p3_updated")
	#elif _draw_pile.find(card) != -1:
		#_draw_pile.erase(card)
		#emit_signal("draw_pile_updated")
	#elif _discard_pile.find(card) != -1:
		#_discard_pile.erase(card)
		#emit_signal("discard_pile_updated")
		#
#
#
#func create_card_in_dropzone(nice_name : String, dropzone : CardDropzone):
	#var card_ui = _create_card_ui(_get_card_data_by_nice_name(nice_name))
	#card_ui.position = dropzone.position
	#set_card_dropzone(card_ui, dropzone)
			#
#func create_card_in_pile(nice_name : String, pile_to_add_to : Piles):
	#var card_ui = _create_card_ui(_get_card_data_by_nice_name(nice_name))
	#if pile_to_add_to == Piles.hand_pile_p1:
		#card_ui.position = hand_pile_p1_position
	#if pile_to_add_to == Piles.hand_pile_p2:
		#card_ui.position = hand_pile_p2_position
	#if pile_to_add_to == Piles.hand_pile_p3:
		#card_ui.position = hand_pile_p3_position
	#if pile_to_add_to == Piles.discard_pile:
		#card_ui.position = discard_pile_position
	#if pile_to_add_to == Piles.draw_pile:
		#card_ui.position = draw_pile_position
	#set_card_pile(card_ui, pile_to_add_to)
#
#
#func _maybe_remove_card_from_any_dropzones(card : CardUI):
	#var all_dropzones := []
	#_get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
	#for dropzone in all_dropzones:
		#if dropzone.is_holding(card):
			#dropzone.remove_card(card)
			#emit_signal("card_removed_from_dropzone", dropzone, card)
#
#func get_card_dropzone(card : CardUI):
	#var all_dropzones := []
	#_get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
	#for dropzone in all_dropzones:
		#if dropzone.is_holding(card):
			#return dropzone
	#return null
#
			#
#func _get_dropzones(node: Node, className : String, result : Array) -> void:
	#if node is CardDropzone:
		#result.push_back(node)
	#for child in node.get_children():
		#_get_dropzones(child, className, result)
	#
#
#func load_json_path():
	#card_database = _load_json_cards_from_path(json_card_database_path)
	#card_collection = _load_json_cards_from_path(json_card_collection_path)
	#
#func _load_json_cards_from_path(path : String):
	#var found = []
	#if path:
		#var json_as_text = FileAccess.get_file_as_string(path)
		#var json_as_dict = JSON.parse_string(json_as_text)
		#if json_as_dict:
			#for c in json_as_dict:
				#found.push_back(c)
	#return found
#
#func reset():
	#_reset_card_collection()
#
#func _reset_card_collection():
	#for child in get_children():
		#_maybe_remove_card_from_any_piles(child)
		#_maybe_remove_card_from_any_dropzones(child)
		#remove_card_from_game(child)
	#for nice_name in card_collection:
		#var card_data = _get_card_data_by_nice_name(nice_name)
		#var card_ui = _create_card_ui(card_data)
		#_draw_pile.push_back(card_ui)
		##_draw_pile.shuffle()
	#_set_draw_pile_target_positions(true)
	#emit_signal("draw_pile_updated")
	#emit_signal("hand_pile_p1_updated")
	#emit_signal("hand_pile_p2_updated")
	#emit_signal("hand_pile_p3_updated")
	#emit_signal("discard_pile_updated")
#
		#
#func reset_target_positions():
	#_set_draw_pile_target_positions()
	#_set_hand_pile_p1_target_positions()
	#_set_hand_pile_p2_target_positions()
	##_set_hand_pile_p3_target_positions()
	#_set_discard_pile_target_positions()
	#
#func _set_draw_pile_target_positions(instantly_move = false):
	#for i in _draw_pile.size():
		#var card_ui = _draw_pile[i]
		#var target_pos = draw_pile_position
		#if draw_pile_layout == CardPileUI_Old.PilesCardLayouts.up:
			#if i <= max_stack_display:
				#target_pos.y -= i * stack_display_gap
			#else:
				#target_pos.y -= stack_display_gap * max_stack_display
		#elif draw_pile_layout == CardPileUI_Old.PilesCardLayouts.down:
			#if i <= max_stack_display:
				#target_pos.y += i * stack_display_gap
			#else:
				#target_pos.y += stack_display_gap * max_stack_display
		#elif draw_pile_layout == CardPileUI_Old.PilesCardLayouts.right:
			#if i <= max_stack_display:
				#target_pos.x += i * stack_display_gap
			#else:
				#target_pos.x += stack_display_gap * max_stack_display
		#elif draw_pile_layout == CardPileUI_Old.PilesCardLayouts.left:
			#if i <= max_stack_display:
				#target_pos.x -= i * stack_display_gap
			#else:
				#target_pos.x -= stack_display_gap * max_stack_display
		#card_ui.z_index = i
		#card_ui.rotation = 0
		#card_ui.target_position = target_pos
		#card_ui.set_direction(Vector2.DOWN)
		#if instantly_move:
			#card_ui.position = target_pos
	#
#func _set_hand_pile_p1_target_positions():
	#for i in _hand_pile_p1.size():
		#var card_ui = _hand_pile_p1[i]
		#if !card_ui.is_clicked:
			#card_ui.move_to_front()
			#var hand_ratio = 0.5
			#if _hand_pile_p1.size() > 1:
				#hand_ratio = float(i) / float(_hand_pile_p1.size() - 1)
			#var target_pos = hand_pile_p1_position
			#var card_spacing = max_hand_spread / (_hand_pile_p1.size() + 1)
			#target_pos.x += (i + 1) * card_spacing - max_hand_spread / 2.0
			#if hand_vertical_curve:
				#target_pos.y -= hand_vertical_curve.sample(hand_ratio)
			#if hand_rotation_curve:
				#card_ui.rotation = deg_to_rad(hand_rotation_curve.sample(hand_ratio))
			#if hand_face_up:
				#card_ui.set_direction(Vector2.UP)
			#else:
				#card_ui.set_direction(Vector2.DOWN)
			#card_ui.target_position = target_pos
			#
	#while _hand_pile_p1.size() > max_hand_size:
		#set_card_pile(_hand_pile_p1[_hand_pile_p1.size() - 1], Piles.discard_pile)
	#_reset_hand_pile_p1_z_index()
	#
	#
#func _set_hand_pile_p2_target_positions():
	#for i in _hand_pile_p2.size():
		#var card_ui = _hand_pile_p2[i]
		#if !card_ui.is_clicked:
			#card_ui.move_to_front()
			#var hand_ratio = 0.5
			#if _hand_pile_p2.size() > 1:
				#hand_ratio = float(i) / float(_hand_pile_p2.size() - 1)
			#var target_pos = hand_pile_p2_position
			#var card_spacing = max_hand_spread / (_hand_pile_p2.size() + 1)
			#target_pos.x += (i + 1) * card_spacing - max_hand_spread / 2.0
			#card_ui.set_direction(Vector2.DOWN)
			#card_ui.target_position = target_pos
			#
	#while _hand_pile_p2.size() > max_hand_size:
		#set_card_pile(_hand_pile_p2[_hand_pile_p2.size() - 1], Piles.discard_pile)
	#_reset_hand_pile_p2_z_index()
#
	#
#func _set_discard_pile_target_positions():
	#for i in _discard_pile.size():
		#var card_ui = _discard_pile[i]
		#var target_pos = discard_pile_position
		#if discard_pile_layout == CardPileUI_Old.PilesCardLayouts.up:
			#if i <= max_stack_display:
				#target_pos.y -= i * stack_display_gap
			#else:
				#target_pos.y -= stack_display_gap * max_stack_display
		#elif draw_pile_layout == CardPileUI_Old.PilesCardLayouts.down:
			#if i <= max_stack_display:
				#target_pos.y += i * stack_display_gap
			#else:
				#target_pos.y += stack_display_gap * max_stack_display
		#elif discard_pile_layout == CardPileUI_Old.PilesCardLayouts.right:
			#if i <= max_stack_display:
				#target_pos.x += i * stack_display_gap
			#else:
				#target_pos.x += stack_display_gap * max_stack_display
		#elif discard_pile_layout == CardPileUI_Old.PilesCardLayouts.left:
			#if i <= max_stack_display:
				#target_pos.x -= i * stack_display_gap
			#else:
				#target_pos.x -= stack_display_gap * max_stack_display
		#if discard_face_up:
			#card_ui.set_direction(Vector2.UP)
		#else:
			#card_ui.set_direction(Vector2.DOWN)
		#card_ui.z_index = i
		#card_ui.rotation = 0
		#card_ui.target_position = target_pos
#
## called by CardUI
#func reset_card_ui_z_index():
	#for i in _draw_pile.size():
		#var card_ui = _draw_pile[i]
		#card_ui.z_index = i
	#for i in _discard_pile.size():
		#var card_ui = _discard_pile[i]
		#card_ui.z_index = i
	#_reset_hand_pile_p1_z_index()
#
#func _reset_hand_pile_p1_z_index():
	#for i in _hand_pile_p1.size():
		#var card_ui = _hand_pile_p1[i]
		## if card_ui.is_clicked == false:	
		#card_ui.z_index = 1000 + i
		#card_ui.move_to_front()
		#if card_ui.mouse_is_hovering:
			#card_ui.z_index = 2000 + i
#
#func _reset_hand_pile_p2_z_index():
	#for i in _hand_pile_p2.size():
		#var card_ui = _hand_pile_p2[i]
		## if card_ui.is_clicked == false:	
		#card_ui.z_index = 1000 + i
		#card_ui.move_to_front()
		#if card_ui.mouse_is_hovering:
			#card_ui.z_index = 2000 + i
#
#func is_card_ui_in_hand(card_ui):
	#return _hand_pile_p1.filter(func(c): return c == card_ui).size()
	#
#
#
#func is_any_card_ui_clicked():
	#for card_ui in _hand_pile_p1:
		#if card_ui.is_clicked:
			#return true
	#var all_dropzones := []
	#_get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
	#for dropzone in all_dropzones:
		#for card in dropzone.get_held_cards():
			#if card.is_clicked:
				#return true
	#return false
#
#@rpc("authority","call_local")
#func full_pile_test(number):
	#print("full pile number: ",number," of ",multiplayer.get_unique_id())
#
##public function to try and draw a card
#@rpc("any_peer","call_local")
#func draw(num_cards := 1):
	#for i in num_cards:
		#if _hand_pile_p1.size() >= max_hand_size and cant_draw_at_hand_limit:
			#continue
		#if _draw_pile.size():
			#set_card_pile(_draw_pile[_draw_pile.size() - 1], Piles.hand_pile_p1)
			#set_card_pile(_draw_pile[_draw_pile.size() - 1], Piles.hand_pile_p2)
			##set_card_pile(_draw_pile[_draw_pile.size() - 1], Piles.hand_pile_p3)
		#elif shuffle_discard_on_empty_draw and _discard_pile.size():
			#var dupe_discard = _discard_pile.duplicate()
			#for c in dupe_discard: # you can't remove things from the thing you loop!!
				#set_card_pile(c, Piles.draw_pile)
			#_draw_pile.shuffle()
			#set_card_pile(_draw_pile[_draw_pile.size() - 1], Piles.hand_pile_p1)
	#reset_target_positions()
#
#@rpc("authority", "call_local")
#func shuffle_deck():
	#_draw_pile.shuffle()
#
#@rpc("any_peer","call_local")
#func add_to_global_pile():
	#_draw_pile.shuffle()
	#GlobalManager.full_pile = _draw_pile
			#
#
#func hand_is_at_max_capacity():
	#return _hand_pile_p1.size() >= max_hand_size
#
#func sort_hand(sort_func):
	#_hand_pile_p1.sort_custom(sort_func)
	#reset_target_positions()
#
#func _create_card_ui(json_data : Dictionary):
	#var card_ui = extended_card_ui.instantiate()
	#card_ui.frontface_texture = json_data.texture_path
	#card_ui.backface_texture = json_data.backface_texture_path
	#card_ui.return_speed = card_return_speed
	#card_ui.hover_distance = card_ui_hover_distance
	#card_ui.drag_when_clicked = drag_when_clicked
	#
	#card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	#for key in json_data.keys():
		#if key != "texture_path" and key != "backface_texture_path" and key != "resource_script_path":
			#card_ui.card_data[key] = json_data[key]
	#card_ui.connect("card_hovered", func(c_ui): emit_signal("card_hovered", c_ui))
	#card_ui.connect("card_unhovered", func(c_ui): emit_signal("card_unhovered", c_ui))
	#card_ui.connect("hand_card_clicked", func(c_ui): emit_signal("hand_card_clicked", c_ui))
	#card_ui.connect("hand_card_unclicked", func(c_ui): emit_signal("hand_card_unclicked", c_ui))
	#card_ui.connect("battle_card_clicked", func(c_ui): emit_signal("battle_card_clicked", c_ui))
	#card_ui.connect("card_flipped_up", func(c_ui): emit_signal("card_flipped_up", c_ui))	
	#card_ui.connect("card_flipped_down", func(c_ui): emit_signal("card_flipped_down", c_ui))	
	#card_ui.connect("card_dropped", func(c_ui): emit_signal("card_dropped", c_ui))
	#add_child(card_ui)
	#return card_ui
#
#
#func _get_card_data_by_nice_name(nice_name : String):
	#for json_data in card_database:
		#if json_data.nice_name == nice_name:
			#return json_data
	#return null
