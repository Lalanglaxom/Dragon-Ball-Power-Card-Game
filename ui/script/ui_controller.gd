extends Control

@onready var big_image: TextureRect = $BigImage

var offset = Vector2(5, -225)

func _ready() -> void:
	GlobalManager.card_hover.connect(show_big_image)
	GlobalManager.card_unhover.connect(hide_big_image)
	GlobalManager.card_3d_hover.connect(show_big_image_3d)
	GlobalManager.card_3d_unhover.connect(hide_big_image_3d)



func _process(delta: float) -> void:
	#big_image.global_position = get_viewport().get_mouse_position() + offset
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
	GlobalManager.end_turn_pressed.emit()
