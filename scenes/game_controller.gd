extends Node

@onready var info = $CanvasLayer/Info
@onready var card_pile_ui = $CardPileUI

#func _ready():
	#card_pile_ui.draw(10)


func _on_card_unhovered(card):
	info.texture = null


func _on_card_hovered(card):
	info.texture = load(card.card_data.big_image)


func _on_hand_card_clicked(card):
	pass # Replace with function body.
