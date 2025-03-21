#class_name CardDropzone extends Control
#
#@export var card_pile_ui : FullPile
#@export var stack_display_gap := 8
#@export var max_stack_display := 6
#@export var card_ui_face_up := true
#@export var can_drag_top_card := true
#@export var held_card_direction := true
#@export var layout : FullPile.PilesCardLayouts = FullPile.PilesCardLayouts.up
#
#enum Zone {
	#battle,
	#rip,
	#effect,
	#environment
#}
#
#enum Player {
	#p1,
	#p2,
	#p3
#}
#
#@export var zone := Zone.battle
#@export var player := Player.p1
	#
#var _held_cards := []
#
#func card_ui_dropped(card_ui : CardUI):
	#if card_pile_ui:
		#card_pile_ui.set_card_dropzone(card_ui, self)
#
#func can_drop_card(card_ui : CardUI):
	#return visible
#
#func get_top_card():
	#if _held_cards.size() > 0:
		#return _held_cards[_held_cards.size() - 1]
	#return null
#
#func get_card_at(index):
	#if _held_cards.size() > index:
		#return _held_cards[index]
	#return null
#
#func get_total_held_cards():
	#return _held_cards.size()
#
#func is_holding(card_ui):
	#return _held_cards.find(card_ui) != -1
#
#func get_held_cards():
	#return _held_cards.duplicate() # duplicate to allow the user to mess with the array without messing with this one!!!
#
#func add_card(card_ui):
	#if card_ui_face_up:
		#card_ui.set_direction(Vector2.UP)
	#else:
		#card_ui.set_direction(Vector2.DOWN)
	#_held_cards.push_back(card_ui)
	#
#func remove_card(card_ui):
	#_held_cards = _held_cards.filter(func(c): return c != card_ui)
	##_update_target_positions()
#
#func _update_target_positions():
	#for i in _held_cards.size():
		#var card_ui = _held_cards[i]
		#var target_pos = position
		#if layout == FullPile.PilesCardLayouts.up:
			#if i <= max_stack_display:
				#target_pos.y -= i * stack_display_gap
			#else:
				#target_pos.y -= stack_display_gap * max_stack_display
		#elif layout == FullPile.PilesCardLayouts.down:
			#if i <= max_stack_display:
				#target_pos.y += i * stack_display_gap
			#else:
				#target_pos.y += stack_display_gap * max_stack_display
		#elif layout == FullPile.PilesCardLayouts.right:
			#if i <= max_stack_display:
				#target_pos.x += i * stack_display_gap
			#else:
				#target_pos.x += stack_display_gap * max_stack_display
		#elif layout == FullPile.PilesCardLayouts.left:
			#if i <= max_stack_display:
				#target_pos.x -= i * stack_display_gap
			#else:
				#target_pos.x -= stack_display_gap * max_stack_display
#
		#card_ui.z_index = i
		#card_ui.move_to_front() # must also do this to account for INVISIBLE INTERACTION ORDER
		#card_ui.target_position = target_pos
#
#func _process(_delta):
	#_update_target_positions()
