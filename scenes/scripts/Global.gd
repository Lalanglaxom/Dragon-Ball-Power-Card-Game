extends Node

## Signal Bus
# Card Signal
# The arguments is for separating, not functioning
signal card_hover(Card2D)
signal card_unhover(Card2D)
signal card_chosen(Card2D)
signal card_return(Card2D)
signal card_return_local
signal faux_chosen()

signal card_3d_hover(Card3D)
signal card_3d_unhover(Card3D)
signal card_3d_button(Card3D)
signal card_3d_flip(Card3D)


# Pile Signal
signal draw_pile_updated
signal on_draw_pressed(amount: int)
signal card_drew(Card2D)


# Game Signal
signal end_turn_pressed
signal game_round_end
signal damage_phase_enter

var Players = {}

# Faux Card
var faux_database := [] # an array of JSON `Card` data
var faux_collection := [] # an array of JSON `Card` data

const card_scene = preload("res://scenes/card_2d.tscn")
const CARD_3D = preload("res://scenes/3d/card_3d.tscn")

var faux_cards: Array[Card2D]
var faux_cards_chosen: Array[Card2D]
var faux_id_chosen: Array[int]

# Battle Card
var battle_database := [] # an array of JSON `Card` data
var battle_collection := [] # an array of JSON `Card` data

# Game round
enum State {OTHER_TURN, YOUR_TURN}
var state: State

enum Phase {STANDOFF, BATTLE, DAMAGE} 
var current_phase: Phase    

var round_turn: int = 0
var card_button_can_show: bool = false


func print_multi(thing):
	print(str(multiplayer.get_unique_id()) + ": " + str(thing))

func get_card3d_data_by_id(id : int):
	if id >= 2000:
		for json_data in faux_database:
			if int(json_data.id) == id:
				return json_data
		Global.print_multi("Null 3D Data")
		return null
	
	if id < 1000:
		for json_data in battle_database:
			if int(json_data.id) == id:
				return json_data
		Global.print_multi("Null 3D Data")
		return null


func create_card_3d(json_data: Dictionary, id: int):
	var card_3d = CARD_3D.instantiate()
	card_3d.frontface_texture = json_data.front_image_path
	card_3d.backface_texture = json_data.back_image_path
	card_3d.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "front_mini_path" and key != "back_mini_path" and key != "resource_script_path":
			card_3d.card_data[key] = json_data[key]
	card_3d.card_belong_to_id = id
	return card_3d
	
	
func get_faux_data_by_id(id : int):
	for json_data in faux_database:
		if int(json_data.id) == id:
			return json_data
	Global.print_multi("Null 3D Data")
	return null


func create_faux_ui(json_data : Dictionary):
	var card_ui = card_scene.instantiate()
	card_ui.frontface_texture = json_data.front_mini_path
	card_ui.backface_texture = json_data.back_mini_path
	
	card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "front_mini_path" and key != "back_mini_path" and key != "resource_script_path":
			card_ui.card_data[key] = json_data[key]

	return card_ui
