extends Node3D

@onready var power_label: Label3D = $PowerLabel

@export var target_power: int = 0
var current_power: int = 0
var increase_speed = 2
var scale_speed = 1

func _ready() -> void:
	#set_target_power(7000)
	pass


func _process(delta: float) -> void:

	pass


func set_target_power(power: int):
	target_power = power
	power_label.scale = Vector3.ZERO
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	#tween.set_ease(Tween.EASE_)
	tween.tween_property(power_label, "scale", Vector3.ONE, scale_speed)
	power_label.text = str(target_power)
	
	#tween.set_trans(Tween.TRANS_CIRC)
	#tween.set_ease(Tween.EASE_OUT)
	#tween.tween_method(set_power_label, current_power, target_power, increase_speed)

func set_power_label(power: int):
	power_label.text = str(power)


func power_appear():
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_OUT)
	
