class_name Card2D
extends Control

@export var card_data : CardData
@export var return_speed := 0.2

const CARD_3D = preload("res://scenes/3d/card_3d.tscn")
const HOVER_MATERIAL = preload("res://card/properties/hover_material.tres")

var target_position: Vector2
var target_rotation: float

var is_hover: bool = false
@export var hover_amount: float = 60

func _ready() -> void:
	get_node("Frontface").material = null
	
func _process(delta: float) -> void:
	handle_card_transform()


func handle_card_transform():
	if is_hover:
		return
	
	position = lerp(position, target_position, return_speed)
	rotation = target_rotation

func _on_mouse_entered() -> void:
	GlobalManager.card_hover.emit(self)
	is_hover = true
	get_node("Frontface").material = HOVER_MATERIAL
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(target_position.x - hover_amount/3.5, target_position.y - hover_amount) , 0.15)

func _on_mouse_exited() -> void:
	GlobalManager.card_unhover.emit(self)
	is_hover = false
	get_node("Frontface").material = null

	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_hover:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				var new_card = CARD_3D.instantiate()
				new_card.frontface_texture = card_data.front_image_path
				new_card.backface_texture = card_data.back_image_path
				
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", Vector2(position.x, position.y + 150), 0.15)
				await tween.finished
				GlobalManager.card_chosen.emit(new_card)
				queue_free()
				
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
				print(self)
