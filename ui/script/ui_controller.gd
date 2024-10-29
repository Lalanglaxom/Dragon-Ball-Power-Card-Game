extends Control

@onready var big_image: TextureRect = $BigImage
@onready var end_turn: Button = $"End Turn"

var offset = Vector2(5, -225)

func _ready() -> void:
	Global.card_hover.connect(show_big_image)
	Global.card_unhover.connect(hide_big_image)
	Global.card_3d_hover.connect(show_big_image_3d)
	Global.card_3d_unhover.connect(hide_big_image_3d)
	



func _process(delta: float) -> void:
	pass


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
