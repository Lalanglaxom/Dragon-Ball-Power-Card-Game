extends Node


@export_file("*.json") var json_card_database_path : String
@export_file("*.json") var json_card_collection_path : String
@export var card_scene : PackedScene

@onready var hand_container_p_2: Control = $"../HandContainerP2"
@onready var hand_container_p_1: Control = $"../HandContainerP1"

enum Piles {
	draw_pile,
}

var card_database := [] # an array of JSON `Card` data
var card_collection := [] # an array of JSON `Card` data

var draw_pile := [] # an array of `Card2D`s


func _ready() -> void:
	load_json_path()
	_reset_card_collection()
	for card in get_children():
		draw_pile.append(card)
		
	GlobalManager.on_draw_pressed.connect(draw)

func draw(num_cards := 3):
	draw_pile.shuffle()
	for i in num_cards:
		if draw_pile.size():
			var card = draw_pile[draw_pile.size() - 1]
			card.reparent(hand_container_p_1, true)
			print_debug(card.card_data.nice_name)
			draw_pile.erase(card)
			hand_container_p_1.arrange_hand_card()
			
	

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


func _reset_card_collection():
	for nice_name in card_collection:
		var card_data = _get_card_data_by_nice_name(nice_name)
		var card_ui = _create_card_ui(card_data)
		#draw_pile.push_back(card_ui)


func _get_card_data_by_nice_name(nice_name : String):
	for json_data in card_database:
		if json_data.nice_name == nice_name:
			return json_data
	return null


func create_card_in_pile(nice_name : String, pile_to_add_to : Piles):
	var card_ui = _create_card_ui(_get_card_data_by_nice_name(nice_name))
	#if pile_to_add_to == Piles.draw_pile:
		#card_ui.position = Vector2.ZERO
	set_card_pile(card_ui, pile_to_add_to)


func _create_card_ui(json_data : Dictionary):
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