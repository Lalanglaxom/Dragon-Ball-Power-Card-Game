extends Node

@onready var backface = $Backface
@onready var frontface = $Frontface

@export var rotation_speed = 2.0  # Adjust this for desired oscillation speed (radians per second)
var time_offset = 0.0  # Optional: Add initial phase shift (radians)


func _process(delta):
	pass
	#time_offset += delta * rotation_speed  # Update time offset for smooth oscillation
#
	## Calculate sine wave value between -180 and 180 degrees
	#var back_y_rot = sin(time_offset) * 180.0  # Convert sine value to degrees (-180 to 180)
	#var front_y_rot = sin(time_offset) * 180.0
	#
	##var x_rot = - abs(sin(time_offset)) * 45 + 45
	#
	#backface.material.set_shader_parameter("y_rot", back_y_rot - 180)
	#frontface.material.set_shader_parameter("y_rot", front_y_rot)
	
	#backface.material.set_shader_parameter("x_rot", x_rot)
	#frontface.material.set_shader_parameter("x_rot", x_rot)
