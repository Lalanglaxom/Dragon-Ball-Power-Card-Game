class_name Card2D
extends Control

@export var card_data : CardData
@export var return_speed := 0.2

var frontface_texture : String
var backface_texture : String
@onready var backface: TextureRect = $Backface
@onready var frontface: TextureRect = $Frontface

const CARD_3D = preload("res://scenes/3d/card_3d.tscn")
const HOVER_MATERIAL = preload("res://card/properties/hover_material.tres")

var target_position: Vector2 
var target_rotation: float 

var is_hover: bool = false
@export var hover_amount: float = 60

var card_belong_to_id: int = -1
var can_be_interact: bool = true

func _ready() -> void:
	get_node("Frontface").material = null
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		backface.texture = load(backface_texture)


func _process(delta: float) -> void:
	handle_card_transform()


func handle_card_transform():
	if is_hover:
		return
	
	position = lerp(position, target_position, return_speed)
	rotation = target_rotation


func set_direction(direction: Vector2):
	if direction == Vector2.UP:
		backface.hide()
		frontface.show()
	else:
		backface.show()
		frontface.hide()


func _on_mouse_entered() -> void:
	if !can_be_interact:
		return
		
	var parent = get_parent()
	if parent.name == "FullPile": return
	
	if card_belong_to_id == multiplayer.get_unique_id():
		GlobalManager.card_hover.emit(self)
	
	is_hover = true
	get_node("Frontface").material = HOVER_MATERIAL
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(target_position.x - hover_amount/3.5, target_position.y - hover_amount) , 0.15)



func _on_mouse_exited() -> void:
	if !can_be_interact: return
		
	GlobalManager.card_unhover.emit(self)
	is_hover = false
	get_node("Frontface").material = null

	
func _on_gui_input(event: InputEvent) -> void:
	if !can_be_interact:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var parent = get_parent()
			if parent.name == "FullPile":
				GlobalManager.on_draw_pressed.emit() 
				
			if card_belong_to_id != multiplayer.get_unique_id():
				return
			
			if is_hover:
				create_card_3d()

		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			#print_debug(self.card_data.nice_name)
			pass


func create_card_3d():
	var card_3d = CARD_3D.instantiate()
	card_3d.frontface_texture = card_data.front_image_path
	card_3d.backface_texture = card_data.back_image_path
	card_3d.card_data = self.card_data
	card_3d.card_belong_to_id = multiplayer.get_unique_id()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, position.y + 150), 0.15)
	await tween.finished
	
	GlobalManager.card_chosen.emit(card_3d, self)
