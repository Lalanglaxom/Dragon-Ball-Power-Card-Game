extends Control

var hand_pile: Array[Card2D]

@export var max_hand_spread: float = 700
@export var hand_rotation_curve : Curve
@export var hand_vertical_curve : Curve

func _ready() -> void:
	for i in self.get_children():
		hand_pile.append(i)
	arrange_hand_card()

func arrange_hand_card():
	for i in hand_pile.size():
		var card_ui = hand_pile[i]
		var hand_ratio = 0.5
		if hand_pile.size() > 1:
			hand_ratio = float(i) / float(hand_pile.size() - 1)
			var target_pos = self.position
			var target_rot = self.rotation
			var card_spacing = max_hand_spread / (hand_pile.size() + 1)
			target_pos.x += (i + 1) * card_spacing - max_hand_spread / 2.0
			if hand_vertical_curve:
				target_pos.y -= hand_vertical_curve.sample(hand_ratio)
			if hand_rotation_curve:
				target_rot = deg_to_rad(hand_rotation_curve.sample(hand_ratio))
			card_ui.target_position = target_pos
			card_ui.target_rotation = target_rot
