extends PanelContainer


@onready var game_controller: Node = $"../../../GameController"
@onready var hand_container_p_1: Control = $"../../../HandContainerP1"

@onready var state: Label = $VBoxContainer/State
@onready var player_turn: Label = $VBoxContainer/PlayerTurn
@onready var your_turn: Label = $VBoxContainer/YourTurn
@onready var phase: Label = $VBoxContainer/Phase
@onready var current_round: Label = $"VBoxContainer/Current Round"
@onready var p_1_card: Label = $"VBoxContainer/P1 Card"
@onready var p_2_card: Label = $"VBoxContainer/P2 Card"


func _process(delta: float) -> void:
	player_turn.text = "Current Turn: " + str(game_controller.current_player_turn)
	your_turn.text = "Your Go: " + str(hand_container_p_1.player_turn)
	state.text = "State: " + str(Global.State.keys()[Global.state])
	phase.text = "Current Phase: " + str(Global.Phase.keys()[Global.current_phase])
	current_round.text = "Current Round: " + str(game_controller.game_round)
	p_1_card.text = "P1 Card: " + str(game_controller.p1_battle_pile.size())
	p_2_card.text = "P2 Card: " + str(game_controller.p2_battle_pile.size())
