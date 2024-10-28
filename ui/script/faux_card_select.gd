extends Control

@export_file("*.json") var json_faux_database_path : String
@export_file("*.json") var json_faux_collection_path : String
@export var card_scene : PackedScene
const FAUX_IMAGE = preload("res://scenes/faux_image.tscn")

var faux_database := [] # an array of JSON `Card` data
var faux_collection := [] # an array of JSON `Card` data

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

func _ready() -> void:
	load_json_path()
	reset_faux_collection()

func load_json_path():
	faux_database = _load_json_cards_from_path(json_faux_database_path)
	faux_collection = _load_json_cards_from_path(json_faux_collection_path)


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
	for nice_name in faux_collection:
		var card_data = get_card_data_by_nice_name(nice_name)
		var card_ui = create_card_ui(card_data)
		
		
func get_card_data_by_nice_name(nice_name : String):
	for json_data in faux_database:
		if json_data.nice_name == nice_name:
			return json_data
	return null


func create_card_in_pile(nice_name : String):
	var card_ui = create_card_ui(get_card_data_by_nice_name(nice_name))


func create_card_ui(json_data : Dictionary):
	var card_ui = card_scene.instantiate()
	card_ui.frontface_texture = json_data.front_mini_path
	card_ui.backface_texture = json_data.back_mini_path
	
	card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "front_mini_path" and key != "back_mini_path" and key != "resource_script_path":
			card_ui.card_data[key] = json_data[key]
	
	var faux_image = FAUX_IMAGE.instantiate()
	faux_image.get_node("TextureRect").texture = load(json_data.front_mini_path)
	grid_container.add_child(faux_image)
	
	return card_ui


func hello():
	print("A")
