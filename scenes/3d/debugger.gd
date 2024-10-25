extends PanelContainer


@onready var game_controller: Node = $"../../../GameController"
@onready var hand_container_p_1: Control = $"../../../HandContainerP1"

@onready var state: Label = $VBoxContainer/State
@onready var player_turn: Label = $VBoxContainer/PlayerTurn
@onready var your_turn: Label = $VBoxContainer/YourTurn

func _process(delta: float) -> void:
	player_turn.text = "Current Turn: " + str(game_controller.current_player_turn)
	your_turn.text = "Your Turn: " + str(hand_container_p_1.player_turn)
	state.text = "State: " + str(hand_container_p_1.State.keys()[hand_container_p_1.state])
