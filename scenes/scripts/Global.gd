extends Node

## Signal Bus
# Card Signal
# The arguments is for separating, not functioning
signal card_hover(Card2D)
signal card_unhover(Card2D)
signal card_chosen(Card2D)
signal card_return(Card2D)
signal faux_chosen()

signal card_3d_hover(Card3D)
signal card_3d_unhover(Card3D)
signal card_3d_button(Card3D)
signal card_3d_flip(Card3D)


# Pile Signal
signal draw_pile_updated()
signal on_draw_pressed(amount: int)
signal card_drew(Card2D)


# Game Siganl
signal end_turn_pressed()

var Players = {}

# Faux Card
var faux_database := [] # an array of JSON `Card` data
var faux_collection := [] # an array of JSON `Card` data

const card_scene = preload("res://scenes/card_2d.tscn")

var faux_cards: Array[Card2D]
var faux_cards_chosen: Array[Card2D]
var faux_id_chosen: Array[int]

enum State {OTHER_TURN, YOUR_TURN}
var state: State

enum Phase {STANDOFF, BATTLE} 
var current_phase: Phase    

func print_multi(thing):
	print(str(multiplayer.get_unique_id()) + ": " + str(thing))


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
