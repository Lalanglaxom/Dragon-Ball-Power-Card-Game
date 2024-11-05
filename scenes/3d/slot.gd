class_name BattleSlot
extends Node3D

@onready var power_label: Label3D = $PowerLabel

@export var target_power: int = 0
var current_power: int = 0
var increase_speed = 2
var scale_speed = 1


func _ready() -> void:
	Global.card_returned.connect(hide_label.rpc)
	pass

func _process(delta: float) -> void:

	pass


func set_target_power(power: int, card_direction: Vector2):
	if card_direction == Vector2.DOWN:
		power_label.hide()
		return

	power_label.show()
	
	target_power = power
	power_label.scale = Vector3.ZERO
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	#tween.set_ease(Tween.EASE_)
	tween.tween_property(power_label, "scale", Vector3.ONE, scale_speed)
	power_label.text = str(target_power)
	
	#tween.set_trans(Tween.TRANS_CIRC)
	#tween.set_ease(Tween.EASE_OUT)
	#tween.tween_method(set_power_label, current_power, target_power, increase_speed)

func set_power_label(power: int):
	power_label.text = str(power)


@rpc("any_peer","call_local","reliable")
func hide_label(card_3d: Card3D, card_id: int, player_id: int):
	if multiplayer.get_unique_id() == player_id:
		var card_slot = card_3d.get_parent()
		if card_slot == self:
			power_label.hide()
	else:
		for child in get_children():
			if child is  Card3D:
				if child.card_data.id == card_id:
					power_label.hide()
