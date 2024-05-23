extends Node

@onready var backface = $Backface
@onready var frontface = $Frontface

@export var rotation_speed = 1.0  # Adjust this for desired oscillation speed (radians per second)
var time_offset = 0.0  # Optional: Add initial phase shift (radians)
var duration = 0.5
var flipped = false;
var back_y_rot = 0
var front_y_rot = 0

func _input(event):
	if event.is_action_pressed("flip"):
		flipped = true
		
func _process(delta):
	if flipped == true:
		flip_down(delta)
		
	
func flip_down(delta):
	if front_y_rot > -180:
		time_offset -= delta * rotation_speed
		
		front_y_rot = lerp(0,-180, time_offset/duration)
		back_y_rot = front_y_rot + 180

		if front_y_rot < -180:
			front_y_rot = -180
		
		backface.material.set_shader_parameter("y_rot", back_y_rot)
		frontface.material.set_shader_parameter("y_rot", front_y_rot)
	else:
		flipped = false
		
func flip_up(delta):
	if back_y_rot < 180:
		time_offset += delta * rotation_speed
		
		back_y_rot = lerp(0,180, time_offset/duration)
		front_y_rot = back_y_rot - 180

		if back_y_rot > 180:
			back_y_rot = 180
			front_y_rot = 0
		
		backface.material.set_shader_parameter("y_rot", back_y_rot)
		frontface.material.set_shader_parameter("y_rot", front_y_rot)
	else:
		flipped = false
	
