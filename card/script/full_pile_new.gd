#class_name FullPile
extends Node


@export_file("*.json") var json_battle_database_path : String
@export_file("*.json") var json_battle_collection_path : String
@export var card_scene : PackedScene

@onready var hand_container_p2: Control = $"../HandContainerP2"
@onready var hand_container_p1: Node3D = $"../HandContainerP1"

@onready var draw_pile_3d: Area3D = $"../DrawPile"

enum Piles {
	draw_pile,
}

var battle_database := [] # an array of JSON `Card` data
var battle_collection := [] # an array of JSON `Card` data

var draw_pile := [] # an array of `Card2D`s
var id_pile := []

func _ready() -> void:
	load_json_path()
	start()


func start():
	
	reset_battle_collection()
	var i = 0
	print(draw_pile.size())
	
	for card in draw_pile:
		#draw_pile.append(card)
		#draw_pile.shuffle()
		if i < 10:
			hand_container_p1.hand_pile_p1.append(card)
			card.reparent(hand_container_p1, true)
			print(card.card_data.nice_name)
		i += 1
	hand_container_p1.arrange_hand_card()
	Global.draw_pile_updated.emit()



@rpc("any_peer", "call_remote", "reliable")
func sync_draw_pile(pile):
	id_pile = pile
	for id in id_pile:
		var card_data = get_card_data_by_id(id)
		draw_pile.append(create_card_ui(card_data))
	Global.emit_signal("draw_pile_updated")


func draw():
	if draw_pile.size():
		var card = draw_pile[draw_pile.size() - 1]



func load_json_path():
	battle_database = _load_json_cards_from_path(json_battle_database_path)
	battle_collection = _load_json_cards_from_path(json_battle_collection_path)
	# FIXME: FIX THE NAME IN JSON PYTHON
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
	for nice_name in battle_collection:
		var card_data = get_card_data_by_nice_name(nice_name)
		var card_ui = create_card_ui(card_data)
		draw_pile.push_back(card_ui)

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


func create_card_in_pile(nice_name : String, pile_to_add_to : Piles):
	var card_ui = create_card_ui(get_card_data_by_nice_name(nice_name))
	#set_card_pile(card_ui, Piles.draw_pile)


func create_card_ui(json_data : Dictionary):
	var card_ui = card_scene.instantiate()
	card_ui.frontface_texture = json_data.front_image_path
	card_ui.backface_texture = json_data.back_image_path
	
	card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "front_image_path" and key != "back_image_path" and key != "resource_script_path":
			card_ui.card_data[key] = json_data[key]

	add_child(card_ui)
	return card_ui


func set_card_pile(card : Card3D, pile : Piles):
	if pile == Piles.draw_pile:
		draw_pile.push_back(card)
		Global.draw_pile_updated.emit()
