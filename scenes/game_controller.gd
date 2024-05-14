extends Node

@onready var info = $CanvasLayer/Info

func _on_card_unhovered(card):
	info.texture = null


func _on_card_hovered(card):
	info.texture = load(card.card_data.big_image)
