extends Node3D


var grave_pile_3d := []
var pile_max_size := 30


@export var gap: float = 0.15


func _ready() -> void:
	pass


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					
			pass


func arrange_grave_card():
	for child in get_children():
		if child not in grave_pile_3d:
			grave_pile_3d.append(child)
		
	for i in grave_pile_3d.size():
		grave_pile_3d[i].position.y = 0
		grave_pile_3d[i].position.y += i * gap
		
