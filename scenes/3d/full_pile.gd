class_name FullPile
extends Node


@export_file("*.json") var json_battle_database_path : String
@export_file("*.json") var json_battle_collection_path : String
@export_file("*.json") var json_effect_database_path : String
@export_file("*.json") var json_effect_collection_path : String

const card_scene = preload("res://scenes/card_2d.tscn")

@onready var hand_container_p_2: Control = $"../HandContainerP2"
@onready var hand_container_p_1: Control = $"../HandContainerP1"

@onready var draw_pile_3d: Area3D = $"../DrawPile"

enum Piles {
	draw_pile,
}

var battle_database := [] # an array of JSON `Card` data
var battle_collection := [] # an array of JSON `Card` data

var effect_database := [] # an array of JSON `Card` data
var effect_collection := [] # an array of JSON `Card` data

var draw_pile_battle := [] # an array of `Card2D`s
var draw_pile_effect := [] # an array of `Card2D`s

var name_pile_battle := []
var name_pile_effect := []


func _ready() -> void:
	Global.battle_collection = _load_json_cards_from_path(json_battle_collection_path)
	Global.effect_collection = _load_json_cards_from_path(json_effect_collection_path)
	
	if multiplayer.is_server():
		reset_battle_collection()
		for card in get_children():
			if card.card_data is Battle:
				draw_pile_battle.append(card)
			else:
				draw_pile_effect.append(card)
				
		draw_pile_battle.shuffle()
		draw_pile_effect.shuffle()
			
		for card in draw_pile_battle:
			name_pile_battle.append(card.card_data.nice_name)
		for card in draw_pile_effect:
			name_pile_effect.append(card.card_data.nice_name)
		
		sync_draw_pile.rpc(name_pile_battle, name_pile_effect)


func start():
	pass


@rpc("any_peer", "call_remote", "reliable")
func sync_draw_pile(battle_pile, effect_pile):
	name_pile_battle = battle_pile
	name_pile_effect = effect_pile
	
	for card_name in name_pile_battle:
		var card = Global.create_card_ui(card_name, 0)
		draw_pile_battle.append(card)
		add_child(card)
	
	for card_name in name_pile_effect:
		var card = Global.create_card_ui(card_name, 0)
		draw_pile_effect.append(card)
		add_child(card)
	
	Global.emit_signal("draw_pile_updated")


func load_json_path():
	battle_database = _load_json_cards_from_path(json_battle_database_path)
	battle_collection = _load_json_cards_from_path(json_battle_collection_path)
	# TODO: FIX THE NAME IN JSON PYTHON
	Global.battle_database = battle_database
	Global.battle_collection = battle_collection


func _load_json_cards_from_path(path : String):
	var found = []
	if path:
		var json_as_text = FileAccess.get_file_as_string(path)
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict:
			for c in json_as_dict:
				found.push_back(c)
	return found


func reset_battle_collection():
	for nice_name in Global.battle_collection:
		var card_ui = Global.create_card_ui(nice_name, 0)
		add_child(card_ui)
	
	for nice_name in Global.effect_collection:
		var card_ui = Global.create_card_ui(nice_name, 0)
		add_child(card_ui)


func get_card_data_by_id(id : int):
	for json_data in battle_database:
		if int(json_data.id) == id:
			return json_data
	return null
	
	
func get_card_data_by_nice_name(nice_name : String):
	for json_data in battle_database:
		if json_data.nice_name == nice_name:
			return json_data
	return null


#func create_card_ui(json_data : Dictionary):
	#var card_ui = card_scene.instantiate()
	#card_ui.frontface_texture = json_data.front_mini_path
	#card_ui.backface_texture = json_data.back_mini_path
	#
	#card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	#for key in json_data.keys():
		#if key != "front_mini_path" and key != "back_mini_path" and key != "resource_script_path":
			#card_ui.card_data[key] = json_data[key]
	#
	#add_child(card_ui)
	#return card_ui


func create_card_ui(card_name: String):
	var card_ui = card_scene.instantiate()
	
	card_ui.card_data = ResourceLoader.load('res://card/battle/data/' + card_name + '.tres')
	
	card_ui.frontface_texture = card_ui.card_data.front_mini_path
	card_ui.backface_texture = card_ui.card_data.back_mini_path
	
	return card_ui


#func set_card_pile(card : Card2D, pile : Piles):
	#if pile == Piles.draw_pile:
		##draw_pile.push_back(card)
		#Global.draw_pile_updated.emit()
