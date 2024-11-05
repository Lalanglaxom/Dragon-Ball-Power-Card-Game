extends Control

@onready var big_image: TextureRect = $BigImage
@onready var end_turn: Button = $"End Turn"
@onready var card_option: VBoxContainer = $CardOption
@onready var end_turn_text: Panel = $"End Turn Player"
@onready var winner: Panel = $Winner

var offset = Vector2(5, -225)
var base_end_text_pos: Vector2

func _ready() -> void:
	Global.card_hover.connect(show_big_image)
	Global.card_unhover.connect(hide_big_image)
	Global.card_3d_hover.connect(show_big_image_3d)
	Global.card_3d_unhover.connect(hide_big_image_3d)
	Global.finished_set_turn.connect(show_player_turn.rpc)
	
	base_end_text_pos = end_turn_text.position


func _process(delta: float) -> void:
	big_image.position = get_viewport().get_mouse_position() + offset
	pass


@rpc("any_peer","call_local","reliable")
func show_player_turn():
	end_turn_text.show()
	
	if Global.state == Global.State.YOUR_TURN:
		end_turn_text.get_child(0).text = "Your Turn"
	else:
		end_turn_text.get_child(0).text = "Opponent Turn"
	
	end_turn_text.position = Vector2(base_end_text_pos.x + 900, end_turn_text.position.y)
	
	var tween = get_tree().create_tween()
	tween.tween_property(end_turn_text, "position", Vector2(base_end_text_pos.x, end_turn_text.position.y), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(end_turn_text, "position", Vector2(base_end_text_pos.x - 900, end_turn_text.position.y), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_IN)


func show_player_win(player: int):
	winner.show()
	if player == 1:
		winner.get_child(0).text = "You Win"
	else:
		winner.get_child(0).text = "You Lose"
		

func show_big_image(card: Card2D):
	big_image.show()
	big_image.texture = load(card.card_data.front_image_path)


func hide_big_image(card: Card2D):
	big_image.texture = null
	big_image.hide()


func show_big_image_3d(card: Card3D):
	big_image.show()
	big_image.texture = load(card.card_data.front_image_path)


func hide_big_image_3d(card: Card3D):
	big_image.texture = null
	big_image.hide()


func _on_end_turn_pressed() -> void:
	Global.end_turn_pressed.emit()


func _on_test_button_pressed() -> void:
	Global.game_turn_end.emit()


func _on_quit_game_pressed() -> void:
	get_tree().quit()
