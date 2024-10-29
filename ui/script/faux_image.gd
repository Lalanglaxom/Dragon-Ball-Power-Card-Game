extends Control

@onready var color_rect: ColorRect = $TextureRect/ColorRect
@onready var texture_rect: TextureRect = $TextureRect

const FAUX_MATERIAL = preload("res://card/faux/faux_image.tres")
const FAUX_HIGHLIGHT = preload("res://card/faux/faux_highlight.tres")

var card2d: Card2D
var isSelect: bool = false

func _ready() -> void:
	texture_rect.self_modulate.v = 0.5
	texture_rect.material = null

func _process(delta: float) -> void:
	pass

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if !isSelect:
				Global.faux_cards_chosen.append(card2d)
				if Global.faux_cards_chosen.size() > 2:
					Global.faux_cards_chosen.erase(Global.faux_cards_chosen[0])
				Global.faux_chosen.emit(self)
				
			
			else:
				Global.faux_cards_chosen.erase(card2d)
				Global.faux_chosen.emit(self)
			
			Global.faux_id_chosen.clear()
			for card in Global.faux_cards_chosen:
				Global.faux_id_chosen.append(card.card_data.id)


func _on_mouse_entered() -> void:
	texture_rect.self_modulate.v = 1
	texture_rect.material = FAUX_HIGHLIGHT 


func _on_mouse_exited() -> void:
	if !isSelect:
		texture_rect.self_modulate.v = 0.5
	texture_rect.material = null
	
