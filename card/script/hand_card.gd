class_name Card2D
extends Control




@export var return_speed := 0.2

var base_y_pos: int
var target_position: Vector2
var target_rotation: float

var is_hover: bool = false


func _ready() -> void:
	base_y_pos = position.y


func _process(delta: float) -> void:
	handle_card_transform()


func handle_card_transform():
	if is_hover:
		return
	
	position = lerp(position, target_position, return_speed)
	rotation = target_rotation

func _on_mouse_entered() -> void:
	
	is_hover = true
	base_y_pos = self.position.y
	rotation = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, base_y_pos - 40) , 0.15)\
	.set_trans(Tween.TRANS_LINEAR) \
	.set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, base_y_pos) , 0.15)\
	.set_trans(Tween.TRANS_LINEAR) \
	.set_ease(Tween.EASE_IN_OUT)
	is_hover = true
	rotation = target_rotation
