class_name Card3D
extends Node3D

@export var card_data : CardData

@onready var frontface = $Front
@onready var backface = $Back
var frontface_texture: String
var backface_texture: String

func _ready() -> void:
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		backface.texture = load(backface_texture)
	
	appear()

func appear():
	var base_z_pos = position.z
	position.z += 20
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0,0,base_z_pos), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)
