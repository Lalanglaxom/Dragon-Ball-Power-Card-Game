class_name Card3D
extends Area3D

signal state_updated

@export var card_data : CardData

@onready var frontface: Sprite3D = $Front
@onready var backface: Sprite3D = $Back
var frontface_texture: String
var backface_texture: String

const HOVER_MATERIAL = preload("res://card/properties/hover_material.tres")

# Properties
var health := 2

var base_y_pos: float
var target_position: Vector3
var target_rotation: float 

var direction: Vector2
var card_belong_to_id: int = -1

# State
enum State {ON_HAND, ON_FIELD, ON_GRAVE}
var state: State
var is_all_visible: bool
var is_on_hand: bool
var is_hover: bool = false


func _ready() -> void:
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		backface.texture = load(backface_texture)
	
	base_y_pos = position.y
	appear()


func _process(delta: float) -> void:
	pass


func set_state(new_state: State):
	state = new_state

	if new_state == State.ON_FIELD:
		backface.show()
	
	elif new_state == State.ON_GRAVE:
		backface.show()
		set_direction(Vector2.UP)
	
func appear():
	direction = Vector2.DOWN
	set_direction(direction)
	move_in()


func move_in():
	var base_z_pos = position.z
	position.z += 30
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0,0,base_z_pos), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)


func move_out():
	var new_z_pos = position.z + 20
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0,0,new_z_pos), 0.5) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	queue_free()


func move_to(new_pos: Vector3, time: float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, time) \
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)


func flip():
	var tween = get_tree().create_tween()
	if direction == Vector2.DOWN:
		direction = Vector2.UP
		
		tween.tween_property(self, "position", Vector3(0, position.y + 3, 0), 0.1)
		
		tween.tween_property(self, "rotation", Vector3(0,0,deg_to_rad(0)), 0.2) \
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(self, "position", Vector3(0, base_y_pos, 0), 0.1) 
	
		await tween.finished
		
	else:
		direction = Vector2.DOWN
		
		tween.tween_property(self, "position", Vector3(0, position.y + 3, 0), 0.1)
		
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
			if multiplayer.get_unique_id() != card_belong_to_id: return 
			if Global.state != Global.State.YOUR_TURN: return
			
			
			if Global.current_phase == Global.Phase.BATTLE:
				Global.card_3d_button.emit(self, card_data.id, card_belong_to_id)
			
			elif Global.current_phase == Global.Phase.STANDOFF and direction == Vector2.DOWN:
				Global.card_return.emit(self, card_data.id, card_belong_to_id)


func _on_mouse_entered() -> void:
	if direction == Vector2.UP or card_belong_to_id == multiplayer.get_unique_id():
		Global.card_3d_hover.emit(self)


func _on_mouse_exited() -> void:
	Global.card_3d_unhover.emit(self)
