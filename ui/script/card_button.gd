extends Control

signal flip_button_pressed
signal use_effect_pressed

@onready var hand_container_p1: Player1 = $"../../../HandContainerP1"

@onready var flip: Button = $Flip
@onready var effect: Button = $Effect

@export var offset_3d: Vector3 = Vector3(-0.6,0,-0.4) # Test manually
@export var offset_2d: Vector2 = Vector2(-0.6 ,-0.4) # Test manually

var card
var card_id: int
var card_name: String
var player_id: int


func _ready() -> void:
	Global.card3d_button_needed.connect(show_button_3d)
	Global.card2d_button_needed.connect(show_button_2d)
	Global.card2d_button_unneeded.connect(self.hide)
	Global.card3d_button_unneeded.connect(self.hide)
	Global.end_turn_pressed.connect(self.hide)
	Global.card_chosen.connect(hide_button) # HACK: SUPER DUPER HACKED FUCK


func show_button_3d(card, card_id):
	if Global.state != Global.State.YOUR_TURN: return
	if card.direction == Vector2.UP: return
	
	self.show()
	
	if card.card_data is Effect:
		effect.show()
		flip.hide()
	else:
		effect.hide()
		flip.show()
	
	
	self.card = card
	self.card_id = card_id
	
	position = get_viewport().get_camera_3d().unproject_position(card.global_transform.origin + offset_3d)



func show_button_2d(card, card_id):
	if Global.state != Global.State.YOUR_TURN: return
	
	self.show()
	
	if card.card_data is Effect:
		effect.show()
		flip.hide()
	
	
	self.card = card
	self.card_name = card.card_data.nice_name

	position = card.global_position + offset_2d


func hide_button(card: Card2D, name: String):
	self.hide()


func _on_flip_pressed() -> void:
	flip_button_pressed.emit(self.card, self.card_id, card.get_multiplayer_authority())
	self.hide()


func _on_activate_effect_pressed() -> void:
	use_effect_pressed.emit(self.card, self.card_name, card.get_multiplayer_authority())
	self.hide()
