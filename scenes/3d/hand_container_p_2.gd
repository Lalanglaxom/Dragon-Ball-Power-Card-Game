extends Control



var hand_pile_p2: Array[Card2D]

@export var max_card_hand: int = 18
@export var max_hand_spread: float = 700
@export var hand_position_curve : Curve
@export var hand_rotation_curve : Curve
@export var hand_spread_curve : Curve


func _ready() -> void:
	GlobalManager.card_chosen.connect(card_chosen)



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


func card_chosen(card3d: Card3D, card2d: Card2D):
	if hand_pile_p2.has(card2d):
		hand_pile_p2.erase(card2d)
		remove_child(card2d)
		arrange_hand_card()
