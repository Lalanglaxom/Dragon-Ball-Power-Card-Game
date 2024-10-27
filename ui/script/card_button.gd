extends Control

@onready var full_pile: FullPile = $"../../FullPile"
@onready var hand_container_p_1: Control = $"../../../HandContainerP1"

@export var offset: Vector3 = Vector3(-6,0,3) # Test manually

var card3d: Card3D
var card_id: int
var player_id: int


func _ready() -> void:
	GlobalManager.card_3d_button.connect(show_button)


func show_button(card3d, card_id, player_id):
	self.show()
	self.card3d = card3d
	self.card_id = card_id
	self.player_id = player_id
	
	#offset = Vector3(-4.5, 0, 0)
	position = get_viewport().get_camera_3d().unproject_position(card3d.global_transform.origin + offset)
	
func _on_flip_pressed() -> void:
	GlobalManager.card_3d_flip.emit(self.card3d, self.card_id, self.player_id)


func _on_return_pressed() -> void:
	GlobalManager.print_multi("Return Pressed")
