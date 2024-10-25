class_name Card3D
extends Node3D

@export var card_data : CardData

@onready var frontface = $Front
@onready var backface = $Back
var frontface_texture: String
var backface_texture: String

var base_y_pos: float
var direction: Vector2

var card_belong_to_id: int = -1

func _ready() -> void:
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		backface.texture = load(backface_texture)
	
	base_y_pos = position.y
	appear()


func appear():
	direction = Vector2.DOWN
	set_direction(direction)
	
	var base_z_pos = position.z
	position.z += 20
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0,0,base_z_pos), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)


func flip():
	
	
	var tween = get_tree().create_tween()
	
	if direction == Vector2.DOWN:
		tween.tween_property(self, "position", Vector3(0, position.y + 3, 0), 0.1)
		
		tween.tween_property(self, "rotation", Vector3(0,0,deg_to_rad(0)), 0.2) \
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(self, "position", Vector3(0, base_y_pos, 0), 0.1) 
	
		await tween.finished
		
		direction = Vector2.UP
		set_direction(direction)
	else:
		tween.tween_property(self, "position", Vector3(0, position.y + 3, 0), 0.1)
		
		tween.tween_property(self, "rotation", Vector3(0,0,deg_to_rad(180)), 0.2) \
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(self, "position", Vector3(0, base_y_pos, 0), 0.1) 
	
		await tween.finished
		
		direction = Vector2.DOWN
		set_direction(direction)
	
	
func set_direction(direction: Vector2):
	if direction == Vector2.DOWN:
		rotation.z = deg_to_rad(180)
	else:
		rotation.z = 0


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			flip()


func _on_mouse_entered() -> void:
	if direction == Vector2.UP or card_belong_to_id == multiplayer.get_unique_id():
		GlobalManager.card_3d_hover.emit(self)


func _on_mouse_exited() -> void:
	GlobalManager.card_3d_unhover.emit(self)
