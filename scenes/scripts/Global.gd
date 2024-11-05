extends Node

## Signal Bus
# Card Signal
# The arguments is for separating, not functioning
signal card_hover(Card2D)
signal card_unhover(Card2D)
signal card_chosen()
signal card_returned(Card2D)
signal return_chosen(Card2D)
signal faux_chosen

signal card2d_button_needed
signal card2d_button_unneeded
signal card3d_button_needed
signal card3d_button_unneeded

signal card_3d_hover(Card3D)
signal card_3d_unhover(Card3D)
signal card_3d_flip(Card3D)


# Pile Signal
signal draw_pile_updated
signal on_draw_pressed(amount: int)
signal card_drew(Card2D)


# Game Signal
signal finished_set_turn
signal end_turn_pressed
signal game_round_end


var Players = {}

const card_scene = preload("res://scenes/card_2d.tscn")
const CARD_3D = preload("res://scenes/3d/card_3d.tscn")

# Faux Card
var faux_database := [] # an array of JSON `Card` data
var faux_collection := [] # an array of JSON `Card` data

var faux_cards: Array[Card2D]
var faux_cards_chosen: Array[Card2D]
var faux_id_chosen: Array[int]

# Battle Card
var battle_database := [] # an array of JSON `Card` data
var battle_collection := [] # an array of JSON `Card` data

# Effect Card
var effect_database := [] # an array of JSON `Card` data
var effect_collection := [] # an array of JSON `Card` data

# Game round
enum State {OTHER_TURN, YOUR_TURN, WAIT_TURN}
var state: State

enum Phase {STANDOFF, BATTLE, DAMAGE} 
var current_phase: Phase    

var round_turn: int = 0
var start_hand_amount : int = 15


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


func create_card_3d(card_name: String, id: int):
	var card_3d = CARD_3D.instantiate()
	
	card_3d.card_data = ResourceLoader.load('res://card/battle/data/' + card_name + '.tres')
	
	if card_3d.card_data == null:
		card_3d.card_data = ResourceLoader.load('res://card/effect/data/' + card_name + '.tres')
		
	if card_3d.card_data == null:
		card_3d.card_data = ResourceLoader.load('res://card/faux/data/' + card_name + '.tres')
	
	card_3d.frontface_texture = card_3d.card_data.front_image_path
	card_3d.backface_texture = card_3d.card_data.back_image_path
			
	card_3d.set_multiplayer_authority(id)
	
	return card_3d
	
	
func get_faux_data_by_id(id : int):
	for json_data in faux_database:
		if int(json_data.id) == id:
			return json_data
	Global.print_multi("Null 3D Data")
	return null


func create_faux_ui(card_name):
	var card_ui = card_scene.instantiate()
	
	card_ui.card_data = ResourceLoader.load('res://card/faux/data/' + card_name + '.tres')
	
	card_ui.frontface_texture = card_ui.card_data.front_mini_path
	card_ui.backface_texture = card_ui.card_data.back_mini_path
	
	return card_ui


func get_card_data_by_nice_name(nice_name : String):
	for json_data in battle_database:
		if json_data.nice_name == nice_name:
			return json_data
			
	for json_data in faux_database:
		if json_data.nice_name == nice_name:
			return json_data
			
	for json_data in effect_database:
		if json_data.nice_name == nice_name:
			return json_data
	
	print_debug("No Card Found")
	return null


func create_effect_resource(json_data : Dictionary):
	var card_ui = Effect.new()
	
	card_ui.front_image_path = json_data.front_image_path
	card_ui.back_image_path = json_data.back_image_path
	card_ui.front_mini_path = json_data.front_mini_path
	card_ui.back_mini_path = json_data.back_mini_path
	card_ui.id = json_data.id
	card_ui.nice_name = json_data.nice_name
	card_ui.effect = json_data.effect
	
	var save_result = ResourceSaver.save(card_ui, 'res://card/effect/data/' + json_data.nice_name + '.tres')
	
	if save_result != OK:
		print(save_result)


func create_faux_resource(json_data : Dictionary):
	var card_ui = Faux.new()
	
	card_ui.front_image_path = json_data.front_image_path
	card_ui.back_image_path = json_data.back_image_path
	card_ui.front_mini_path = json_data.front_mini_path
	card_ui.back_mini_path = json_data.back_mini_path
	card_ui.id = json_data.id
	card_ui.nice_name = json_data.nice_name
	card_ui.effect = json_data.effect
	
	var save_result = ResourceSaver.save(card_ui, 'res://card/faux/data/' + json_data.nice_name + '.tres')
	
	if save_result != OK:
		print(save_result)


func create_card_ui(card_name: String, id: int):
	var card_ui = card_scene.instantiate()
	
	card_ui.card_data = ResourceLoader.load('res://card/battle/data/' + card_name + '.tres')
	if card_ui.card_data == null:
		card_ui.card_data = ResourceLoader.load('res://card/effect/data/' + card_name + '.tres')
	if card_ui.card_data == null:
		card_ui.card_data = ResourceLoader.load('res://card/faux/data/' + card_name + '.tres')
	
	card_ui.frontface_texture = card_ui.card_data.front_mini_path
	card_ui.backface_texture = card_ui.card_data.back_mini_path
	
	card_ui.set_multiplayer_authority(id)
	
	return card_ui


func give_card(nice_name: String):
	var card = create_card_ui(nice_name, 1)
	return card
