extends Control


var hand_pile_p2: Array[Card2D]
var remove_hand: Array[Card2D]

@export var max_card_hand: int = 18
@export var max_hand_spread: float = 700
@export var hand_position_curve : Curve
@export var hand_rotation_curve : Curve
@export var hand_spread_curve : Curve


func _ready() -> void:
	#Global.card_chosen.connect(card_chosen)
	Global.card_return.connect(add_remove_card)
	Global.card_return_local.connect(add_remove_card)
	pass



func _process(delta: float) -> void:
	pass

func arrange_hand_card():
	for card in get_children():
		if card not in hand_pile_p2:
			hand_pile_p2.append(card)
			
	for i in hand_pile_p2.size():
		var card_ui = hand_pile_p2[i]
		card_ui.can_be_interact = false
		
		var hand_ratio = 0.5
		if hand_pile_p2.size() > 1:
			hand_ratio = float(i) / float(hand_pile_p2.size() - 1)
		
		var target_pos = Vector2.ZERO
		var target_rot = self.rotation
		max_hand_spread = 500
		var card_spacing = max_hand_spread / (hand_pile_p2.size() + 1)
		
		target_pos.x += (i + 1) * card_spacing - max_hand_spread / 2.0
		target_rot = 0
		#if hand_position_curve:
			#target_pos.y -= hand_position_curve.sample(hand_ratio)
		#if hand_rotation_curve:
			#target_rot = deg_to_rad(hand_rotation_curve.sample(hand_ratio))
			
		card_ui.set_direction(Vector2.DOWN)
		card_ui.target_position = target_pos
		card_ui.target_rotation = target_rot

func add_card(card: Card2D):
	add_child(card)
	arrange_hand_card()

func add_remove_card(card3d, card_id, player_id):
	await get_tree().create_timer(0.1).timeout
	if multiplayer.get_unique_id() != player_id:
		for card in remove_hand:
			if card.card_data.id == card_id:
				hand_pile_p2.append(card)
				remove_hand.erase(card)
				add_child(card)
		arrange_hand_card()

func card_chosen(card2d_id: int, player_id: int):
	if multiplayer.get_unique_id() != player_id:
		var card_2d = get_card_data_by_id(card2d_id)
		if hand_pile_p2.has(card_2d):
			remove_hand.append(card_2d)
			hand_pile_p2.erase(card_2d)
			remove_child(card_2d)
			arrange_hand_card()


func get_card_data_by_id(id : int):
	for card in hand_pile_p2:
		if card.card_data.id == id:
			return card
	return null
