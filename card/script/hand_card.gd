extends Control

var base_y_pos: int

func _ready() -> void:
	base_y_pos = position.y


func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, base_y_pos - 40) , 0.15)


func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x, base_y_pos) , 0.15)
