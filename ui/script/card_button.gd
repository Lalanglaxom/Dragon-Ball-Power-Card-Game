class_name Player2
extends Control

@onready var full_pile: FullPile = $"../../FullPile"
@onready var hand_container_p_1: Control = $"../../../HandContainerP1"

@export var offset: Vector3 = Vector3(4,0,0) # Test manually

var card3d: Card3D
var card_id: int
var player_id: int


func _ready() -> void:
	Global.card_3d_button.connect(show_button)


func show_button(card3d, card_id):
	if Global.state != Global.State.YOUR_TURN: return
	if card3d.direction == Vector2.UP: return
	
	self.show()
	self.card3d = card3d
	self.card_id = card_id
	
	position = get_viewport().get_camera_3d().unproject_position(card3d.global_transform.origin + offset)
	
func _on_flip_pressed() -> void:
	Global.card_3d_flip.emit(self.card3d, self.card_id, card3d.get_multiplayer_authority())
	self.hide()
