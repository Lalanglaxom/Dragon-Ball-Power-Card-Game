class_name FullPile
extends Node


@export_file("*.json") var json_card_database_path : String
@export_file("*.json") var json_card_collection_path : String
@export var card_scene : PackedScene

@onready var hand_container_p_2: Control = $"../HandContainerP2"
@onready var hand_container_p_1: Control = $"../HandContainerP1"

@onready var draw_pile_3d: Area3D = $"../DrawPile"

enum Piles {
	draw_pile,
}

var card_database := [] # an array of JSON `Card` data
var card_collection := [] # an array of JSON `Card` data

var draw_pile := [] # an array of `Card2D`s
var id_pile := []

func _ready() -> void:
	start()


func start():
	load_json_path()
	
	if multiplayer.is_server():
		reset_card_collection()
		for card in get_children():
			draw_pile.append(card)
		draw_pile.shuffle()
			
		for card in draw_pile:
			id_pile.append(card.card_data.id)
			
			
	GlobalManager.on_draw_pressed.connect(draw)
	draw(12)
	
func draw(num_cards := 3):
	for i in num_cards:
		if draw_pile.size():
			var card = draw_pile[draw_pile.size() - 1]
			card.reparent(hand_container_p_1, true)
			
			draw_pile.erase(card)
			hand_container_p_1.arrange_hand_card()

@rpc("any_peer", "call_remote", "reliable")
func sync_draw_pile(pile):
	id_pile = pile
	for id in id_pile:
		var card_data = get_card_data_by_id(id)
		draw_pile.append(create_card_ui(card_data))
	
func shuffle_draw_pile():
	draw_pile.shuffle()


func load_json_path():
	card_database = _load_json_cards_from_path(json_card_database_path)
	card_collection = _load_json_cards_from_path(json_card_collection_path)


func _load_json_cards_from_path(path : String):
	var found = []
	if path:
		var json_as_text = FileAccess.get_file_as_string(path)
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict:
			for c in json_as_dict:
				found.push_back(c)
	return found


func reset_card_collection():
	for nice_name in card_collection:
		var card_data = get_card_data_by_nice_name(nice_name)
		var card_ui = create_card_ui(card_data)
		#draw_pile.push_back(card_ui)

func get_card_data_by_id(id : int):
	for json_data in card_database:
		if int(json_data.id) == id:
			return json_data
	return null
	
	
func get_card_data_by_nice_name(nice_name : String):
	for json_data in card_database:
		if json_data.nice_name == nice_name:
			return json_data
	return null


func create_card_in_pile(nice_name : String, pile_to_add_to : Piles):
	var card_ui = create_card_ui(get_card_data_by_nice_name(nice_name))
	#if pile_to_add_to == Piles.draw_pile:
		#card_ui.position = Vector2.ZERO
	set_card_pile(card_ui, pile_to_add_to)


func create_card_ui(json_data : Dictionary):
	var card_ui = card_scene.instantiate()
	card_ui.frontface_texture = json_data.front_mini_path
	card_ui.backface_texture = json_data.back_mini_path
	
	card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "front_mini_path" and key != "back_mini_path" and key != "resource_script_path":
			card_ui.card_data[key] = json_data[key]

	add_child(card_ui)
	return card_ui


func set_card_pile(card : Card2D, pile : Piles):
	if pile == Piles.draw_pile:
		draw_pile.push_back(card)
		GlobalManager.draw_pile_updated.emit()


func _on_gui_input(event: InputEvent) -> void:
	draw(3)
