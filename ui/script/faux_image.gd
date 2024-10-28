extends Control

@onready var color_rect: ColorRect = $TextureRect/ColorRect
@onready var texture_rect: TextureRect = $TextureRect

const FAUX_MATERIAL = preload("res://card/faux/faux_image.tres")
const FAUX_HIGHLIGHT = preload("res://card/faux/faux_highlight.tres")

func _ready() -> void:
	texture_rect.self_modulate.v = 0.5
	texture_rect.material = null

func _process(delta: float) -> void:
	pass

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("A")


func _on_mouse_entered() -> void:
	texture_rect.self_modulate.v = 1
	texture_rect.material = FAUX_HIGHLIGHT 


func _on_mouse_exited() -> void:
	texture_rect.self_modulate.v = 0.5
	texture_rect.material = null
	
