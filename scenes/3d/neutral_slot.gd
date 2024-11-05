extends Node3D
class_name NeutralSlot

signal set_array_finished

var card_array := []
var name_array := []

func _ready() -> void:
	pass


func set_array(array):
	card_array = array

func move_to_center():
	for child in get_children():
		card_array.append(child)
		
		var tween = get_tree().create_tween()
		tween.tween_property(child, "position", Vector3.ZERO, 0.3) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
		
		await tween.finished


func make_name_array():
	for card in card_array:
		name_array.append(card.card_data.nice_name)


@rpc("any_peer","call_remote","reliable")
func set_name_array(array):
	name_array = array
	
	set_array_finished.emit()
