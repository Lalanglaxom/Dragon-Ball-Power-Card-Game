extends Control

var hand_pile_p1: Array[Card2D]

@export var max_card_hand: int = 18
@export var max_hand_spread: float = 700
@export var hand_position_curve : Curve
@export var hand_rotation_curve : Curve
@export var hand_spread_curve : Curve

@onready var state_chart: StateChart = $"../StateChart"

enum State {OTHER_TURN, YOUR_TURN}
var state: State
var player_turn: int

func _ready() -> void:
	
	#GlobalManager.card_hover.connect(handle_hover)
	GlobalManager.card_chosen.connect(card_chosen)
	GlobalManager.card_drew.connect(receive_card)


func _process(delta: float) -> void:
	pass

func arrange_hand_card():
	for card in get_children():
		if card not in hand_pile_p1:
			hand_pile_p1.append(card)
			
	for i in hand_pile_p1.size():
		var card_ui = hand_pile_p1[i]
		var hand_ratio = 0.5
		
		if hand_pile_p1.size() > 1:
			hand_ratio = float(i) / float(hand_pile_p1.size() - 1)
		var target_pos = Vector2.ZERO
		var target_rot = self.rotation
		max_hand_spread = hand_spread_curve.sample(float(hand_pile_p1.size()) / float(max_card_hand))
		var card_spacing = max_hand_spread / (hand_pile_p1.size() + 1)
		
		target_pos.x += (i + 1) * card_spacing - max_hand_spread / 2.0
		
		if hand_position_curve and hand_pile_p1.size() > 7:
			target_pos.y -= hand_position_curve.sample(hand_ratio)
		if hand_rotation_curve and hand_pile_p1.size() > 7:
			target_rot = deg_to_rad(hand_rotation_curve.sample(hand_ratio))
		
		card_ui.target_position = target_pos
		card_ui.target_rotation = target_rot
	


func receive_card(card: Card2D):
	add_child(card)
	arrange_hand_card()

func card_chosen(card2d:Card2D, data: CardData, id: int):
	hand_pile_p1.erase(card2d)
	remove_child(card2d)
	arrange_hand_card()


func set_turn(turn_num: int):
	player_turn = turn_num

func switch_state(current_player_turn: int):
	if  player_turn == current_player_turn:
		state = State.YOUR_TURN
	else:
		state = State.OTHER_TURN
	
	GlobalManager.print_multi(State.keys()[state])
	
