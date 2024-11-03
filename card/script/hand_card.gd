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

## Properties
var properties: CardObject = CardObject.new()

func _ready() -> void:
	get_node("Frontface").material = null
	
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		backface.texture = load(backface_texture)
	
	if card_data is Battle:
		properties.power = card_data.power
	
	properties.health = 2
	properties.belong_to_id = -1
	properties.can_be_chosen = true
	
	
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
	if is_multiplayer_authority():
		Global.card_hover.emit(self)
	
	#Global.card_hover.emit(self)
	
		is_hover = true
		get_node("Frontface").material = HOVER_MATERIAL

		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", \
							Vector2(target_position.x - hover_amount/3.5, target_position.y - hover_amount) , 0.15)


func _on_mouse_exited() -> void:
	Global.card_unhover.emit(self)
	is_hover = false
	get_node("Frontface").material = null

	
func _on_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var parent = get_parent()
			if parent.name == "FullPile":
				Global.on_draw_pressed.emit() 
			
			if Global.state != Global.State.YOUR_TURN:
				return
				
			if Global.current_phase == Global.Phase.DAMAGE:
				return
			
			if !is_multiplayer_authority():
				return
			
			if is_hover:
				choose_card()



func choose_card():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, position.y + 150), 0.15)
	await tween.finished
	
	Global.card_chosen.emit(self, card_data.nice_name)
