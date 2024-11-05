extends Control

@export_file("*.json") var json_faux_collection_path : String
@export_file("*.json") var json_faux_database_path : String
@export_file("*.json") var json_effect_collection_path : String
@export_file("*.json") var json_effect_database_path : String

const FAUX_IMAGE = preload("res://scenes/faux_image.tscn")
const card_scene = preload("res://scenes/card_2d.tscn")

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer
var faux_chosen := []

func _ready() -> void:
	load_json_path()
	reset_faux_collection()
	
	Global.faux_cards_chosen.append(Global.faux_cards[0])
	Global.faux_cards_chosen.append(Global.faux_cards[1])
	Global.faux_id_chosen.append(Global.faux_cards[0].card_data.id)
	Global.faux_id_chosen.append(Global.faux_cards[1].card_data.id)
	
	Global.faux_chosen.connect(set_color)
	

func load_json_path():
	Global.faux_database = _load_json_cards_from_path(json_faux_database_path)
	Global.faux_collection = _load_json_cards_from_path(json_faux_collection_path)


func _load_json_cards_from_path(path : String):
	var found = []
	if path:
		var json_as_text = FileAccess.get_file_as_string(path)
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict:
			for c in json_as_dict:
				found.push_back(c)
	return found


func reset_faux_collection():
	Global.faux_collection.shuffle()
	
	for nice_name in Global.faux_collection:
		var card_ui = create_card_ui(nice_name)
		
		
func get_card_data_by_nice_name(nice_name : String):
	for json_data in Global.faux_database:
		if json_data.nice_name == nice_name:
			return json_data
	return null


func create_card_ui(card_name: String):
	var card_ui = card_scene.instantiate()
	
	card_ui.card_data = ResourceLoader.load('res://card/faux/data/' + card_name + '.tres')
	
	card_ui.frontface_texture = card_ui.card_data.front_mini_path
	card_ui.backface_texture = card_ui.card_data.back_mini_path

	Global.faux_cards.append(card_ui)
	
	var faux_image = FAUX_IMAGE.instantiate()
	faux_image.get_node("TextureRect").texture = load(card_ui.card_data.front_mini_path)
	grid_container.add_child(faux_image)
	faux_image.card2d = card_ui
	
	return card_ui


func set_color(image: Control):
	if image.isSelect == false:
		faux_chosen.append(image)
		image.isSelect = true
		
		if faux_chosen.size() > 2:
			faux_chosen[0].isSelect = false
			faux_chosen[0].get_child(0).self_modulate.v = 0.5
			faux_chosen.erase(faux_chosen[0])
	
		image.get_child(0).self_modulate.v = 1
		
	else:
		faux_chosen.erase(image)
		image.get_child(0).self_modulate.v = 0.5
		image.isSelect = false


func start_set_faux_card():
	if Global.faux_cards_chosen.size() == 0:
		Global.faux_cards_chosen.append(Global.faux_cards[0])
		Global.faux_cards_chosen.append(Global.faux_cards[1])
		
	if Global.faux_cards_chosen.size() == 1:
		for card in Global.faux_cards:
			if card != Global.faux_cards_chosen[0]:
				Global.faux_cards_chosen.append(card)


func _on_faux_button_pressed() -> void:
	self.show()
