@tool
class_name CardUI extends Control


signal card_hovered(card: CardUI)
signal card_unhovered(card: CardUI)

signal hand_card_clicked(card: CardUI)
signal hand_card_unclicked(card: CardUI)

signal battle_card_clicked(card:CardUI)
signal card_flipped_down(card:CardUI)
signal card_flipped_up(card:CardUI)

signal card_dropped(card: CardUI)


@onready var frontface = $Frontface
@onready var backface = $Backface

@export var card_data : CardUIData

enum States{
	on_hand,
	on_battle,
	on_effect,
	on_environment,
	in_grave
}
var current_state = States.on_hand

var frontface_texture : String
var backface_texture : String
var is_clicked := false
var can_be_chosen := true
var mouse_is_hovering := false
var target_position := Vector2.ZERO
var return_speed := 0.2
var hover_distance := 10
var drag_when_clicked := true

## Flip related variables
var rotation_speed = 1.0  # Adjust this for desired oscillation speed (radians per second)
var time_offset = 0.0  # Optional: Add initial phase shift (radians)
var duration = 0.5
var flipable = false;
var back_y_rot = 0
var front_y_rot = 0
var is_face_up = true

func get_class(): return "CardUI"
func is_class(name): return name == "CardUI"


func set_direction(card_is_facing : Vector2):
	if card_is_facing == Vector2.DOWN:
		is_face_up = false
		frontface.visible = false
		backface.visible = true
		
	elif card_is_facing == Vector2.UP:
		is_face_up = true
		frontface.visible = true
		backface.visible = false
		
	
func set_disabled(val : bool):
	if val:
		mouse_is_hovering = false
		is_clicked = false
		rotation = 0
		var parent = get_parent()
		if parent is CardPileUI:
			parent.reset_card_ui_z_index()
			
func _ready():
	if Engine.is_editor_hint():
		set_disabled(true)
		update_configuration_warnings()
		return
	connect("mouse_entered", _on_mouse_enter)
	connect("mouse_exited", _on_mouse_exited)
	connect("gui_input", _on_gui_input)
	
	if frontface_texture:
		frontface.texture = load(frontface_texture)
		backface.texture = load(backface_texture)
		custom_minimum_size = frontface.texture.get_size()
		pivot_offset = frontface.texture.get_size() / 2
		mouse_filter = Control.MOUSE_FILTER_PASS
		
		# set shader material fake 3d
		frontface.material = frontface.material.duplicate()
		backface.material = backface.material.duplicate()
		backface.material.set_shader_parameter("y_rot", 0)
		frontface.material.set_shader_parameter("y_rot", 0)
	
	set_states()


func _card_can_be_interacted_with():
	var parent = get_parent()
	var valid = false
	if parent is CardPileUI:
		# check for cards in hand
		if parent.is_card_ui_in_hand(self):
			valid = parent.is_hand_enabled() and not is_clicked 
		# check for cards in dropzone
		var dropzone = parent.get_card_dropzone(self)
		if dropzone:
			valid = dropzone.get_top_card() == self
	return valid
			


func _on_mouse_enter():
	#check if is hovering should be turned on
	if _card_can_be_interacted_with():
		mouse_is_hovering = true
		target_position.y -= hover_distance
		var parent = get_parent()
		parent.reset_card_ui_z_index()
	emit_signal("card_hovered", self)


func _on_mouse_exited():
	if is_clicked:
		return
		
	if mouse_is_hovering:
		mouse_is_hovering = false
		target_position.y += hover_distance
		var parent = get_parent()
		if parent is CardPileUI:
			parent.reset_card_ui_z_index()
		emit_signal("card_unhovered", self)
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var y_add_amount = 100
		
		if current_state == States.on_hand:
			if event.pressed and GameController.p1_number_is_chosen <= 2 and is_clicked == false:
				var parent = get_parent()
				if _card_can_be_interacted_with():
					is_clicked = true
					rotation = 0
					target_position.y -= y_add_amount
					mouse_is_hovering = false
					parent.reset_card_ui_z_index()
					emit_signal("hand_card_clicked", self)
					
				if parent is CardPileUI and parent.get_card_pile_size(CardPileUI.Piles.draw_pile) > 0 \
				and parent.is_hand_enabled() and parent.get_cards_in_pile(CardPileUI.Piles.draw_pile).find(self) != -1 \
				and not parent.is_any_card_ui_clicked() and parent.click_draw_pile_to_draw:
					parent.draw(1)
				return
			
			if event.pressed and is_clicked == true:
				is_clicked = false
				target_position.y += y_add_amount
				var parent = get_parent()
				if parent is CardPileUI and parent.is_card_ui_in_hand(self):
					parent.call_deferred("reset_target_positions")
					emit_signal("hand_card_unclicked", self)
				
		if current_state == States.on_battle:
			if event.pressed:
				emit_signal("battle_card_clicked", self)

func get_dropzones(node: Node, className : String, result : Array) -> void:
	if node is CardDropzone:
		result.push_back(node)
	for child in node.get_children():
		get_dropzones(child, className, result)


func set_properties():
	if current_state != States.on_hand:
		is_clicked = false
		can_be_chosen = false
		
	if current_state == States.on_battle:
		#is_face_up = false
		pass

	if current_state == States.in_grave:
		is_face_up = true


# Set Card States
func set_states():
	var parent = get_parent()
	var dropzone = parent.get_card_dropzone(self)
	
	if parent is CardPileUI and parent.is_card_ui_in_hand(self):
		current_state = States.on_hand

	if dropzone:
		match dropzone.zone:
			dropzone.Zone.battle:
				current_state = States.on_battle
			dropzone.Zone.effect:
				current_state = States.on_effect
			dropzone.Zone.environment:
				current_state = States.on_environment
			dropzone.Zone.rip:
				current_state = States.in_grave
			_:
				current_state = null
	set_properties()
	

func flip(delta):
	if is_face_up:
		backface.visible = true
		if front_y_rot < 180:
			time_offset += delta * rotation_speed
			
			front_y_rot = lerpf(0,180, time_offset/duration)
			back_y_rot = front_y_rot - 180

			if front_y_rot > 180:
				front_y_rot = 180
			
			backface.material.set_shader_parameter("y_rot", back_y_rot)
			frontface.material.set_shader_parameter("y_rot", front_y_rot)
		else:
			backface.material.set_shader_parameter("y_rot", 0)
			frontface.material.set_shader_parameter("y_rot", 0)
			time_offset = 0
			set_direction(Vector2.DOWN)
			flipable = false
			card_flipped_down.emit(self)
			return
		
	else:
		frontface.visible = true
		if back_y_rot < 180:
			time_offset += delta * rotation_speed
			back_y_rot = lerpf(0,180, time_offset/duration)
			front_y_rot = back_y_rot - 180
			if back_y_rot > 180:
				back_y_rot = 180
				front_y_rot = 0
			
			backface.material.set_shader_parameter("y_rot", back_y_rot)
			frontface.material.set_shader_parameter("y_rot", front_y_rot)
		else:
			backface.material.set_shader_parameter("y_rot", 0)
			frontface.material.set_shader_parameter("y_rot", 0)
			set_direction(Vector2.UP)
			time_offset = 0
			flipable = false
			card_flipped_up.emit(self)
			return

func _process(_delta):
	#if is_clicked and drag_when_clicked:
		#target_position = get_global_mouse_position() - custom_minimum_size * 0.5
	#if is_clicked:
		#position = target_position #target_position 
	
	if position != target_position:
		position = lerp(position, target_position, return_speed)
	
	if flipable:
		flip(_delta)

	if Engine.is_editor_hint() and last_child_count != get_child_count():
		update_configuration_warnings()
		last_child_count = get_child_count()

var last_child_count = 0

func _get_configuration_warnings():
	if get_child_count() != 3:
		return [ "This node must have 3 TextureRect as children, one named `Frontface` and one named `Backface` and one named `ChosenBox`" ]
	for child in get_children():
		if not child is TextureRect or (child.name != "Frontface" and child.name != "Backface" and child.name != "ChosenBox"):
			return [ "This node must have 3 TextureRect as children, one named `Frontface` and one named `Backface` and one named `ChosenBox`." ]
	return []
