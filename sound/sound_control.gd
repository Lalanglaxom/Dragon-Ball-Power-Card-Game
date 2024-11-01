extends Node


@onready var switch_turn_sound: AudioStreamPlayer = $SwitchTurnSound

func _ready() -> void:
	Global.end_turn_pressed.connect(play_switch_turn)


func play_switch_turn():
	switch_turn_sound.play()
