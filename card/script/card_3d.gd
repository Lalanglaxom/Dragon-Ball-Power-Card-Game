class_name Card3D
extends Area3D

signal moved_to_grave

@export var card_data : CardData

@onready var frontface: Sprite3D = $Front
@onready var backface: Sprite3D = $Back
var frontface_texture: String
var backface_texture: String

const HOVER_MATERIAL = preload("res://card/properties/hover_material.tres")

# Properties
var properties: CardProperties = CardProperties.new()

var base_y_pos: float
var target_position: Vector3
var target_rotation: float 

var direction: Vector2


func _ready() -> void:
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		#backface.texture = load(backface_texture)
	
	if card_data is not Effect:
		direction = Vector2.DOWN	
		set_direction(direction)
	else:
		direction = Vector2.UP
		set_direction(direction)
		
	if card_data is Battle:
		properties.power = card_data.power
		properties.health = 2
	
	base_y_pos = position.y
	move_in()


func _process(delta: float) -> void:
	pass


func move_in():
	var base_z_pos = position.z
	position.z += 5
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0,0,base_z_pos), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)


func move_out():
	var new_z_pos = position.z + 5
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0,0,new_z_pos), 0.8) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	queue_free()


func move_to_grave(new_pos: Vector3, time: float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, time) \
	.set_trans(Tween.TRANS_QUART)\
	.set_ease(Tween.EASE_OUT)
	await tween.finished
	
	moved_to_grave.emit()


func move_to(new_pos: Vector3, time: float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, time) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)


func flip():
	var tween = get_tree().create_tween()
	if direction == Vector2.DOWN:
		direction = Vector2.UP
		
		tween.tween_property(self, "position", Vector3(0, position.y + 0.5, 0), 0.1)
		
		tween.tween_property(self, "rotation", Vector3(0,0,deg_to_rad(0)), 0.2) \
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(self, "position", Vector3(0, base_y_pos, 0), 0.1) 
	
		await tween.finished
		
	else:
		direction = Vector2.DOWN
		
		tween.tween_property(self, "position", Vector3(0, position.y + 0.5, 0), 0.1)
		
		tween.tween_property(self, "rotation", Vector3(0,0,deg_to_rad(180)), 0.2) \
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(self, "position", Vector3(0, base_y_pos, 0), 0.1) 
	
		await tween.finished
		
	
	
func set_direction(new_direction: Vector2):
	direction = new_direction
	if direction == Vector2.DOWN:
		rotation.z = deg_to_rad(180)
	else:
		rotation.z = 0


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if !is_multiplayer_authority(): return 
			
			if Global.state != Global.State.YOUR_TURN: return
			
			if Global.current_phase == Global.Phase.BATTLE:
				Global.card3d_button_needed.emit(self, card_data.id)
			
			elif Global.current_phase == Global.Phase.STANDOFF and direction == Vector2.DOWN:
				Global.return_chosen.emit(self, card_data.nice_name, get_multiplayer_authority())


func _on_mouse_entered() -> void:
	if direction == Vector2.UP or is_multiplayer_authority():
		Global.card_3d_hover.emit(self)


func _on_mouse_exited() -> void:
	Global.card_3d_unhover.emit(self)
