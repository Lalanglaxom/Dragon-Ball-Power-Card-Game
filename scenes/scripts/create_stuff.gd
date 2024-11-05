extends Node3D

@export_file("*.json") var json_battle_database_path : String
@export_file("*.json") var json_battle_collection_path : String
@export_file("*.json") var json_effect_database_path : String
@export_file("*.json") var json_effect_collection_path : String
@export_file("*.json") var json_faux_database_path : String
@export_file("*.json") var json_faux_collection_path : String

# Faux Card
var faux_database := [] # an array of JSON `Card` data
var faux_collection := [] # an array of JSON `Card` data

# Battle Card
var battle_database := [] # an array of JSON `Card` data
var battle_collection := [] # an array of JSON `Card` data

# Effect Card
var effect_database := [] # an array of JSON `Card` data
var effect_collection := [] # an array of JSON `Card` data



func _ready() -> void:
	load_json_path()
	#for json in battle_database:
		#create_battle_resource(json)
	
	for json in effect_database:
		create_effect_resource(json)
		
	#for json in faux_database:
		#create_battle_resource(json)



func load_json_path():
	battle_database = _load_json_cards_from_path(json_battle_database_path)
	battle_collection = _load_json_cards_from_path(json_battle_collection_path)
	effect_database = _load_json_cards_from_path(json_effect_database_path)
	effect_collection = _load_json_cards_from_path(json_effect_collection_path)
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

func create_effect_resource(json_data : Dictionary):
	var card_ui = Effect.new()
	
	if json_data.nice_name == "Mr Satan":
		card_ui = MrSatan.new()
	if json_data.nice_name == "Beerus":
		card_ui = Beerus.new()
	if json_data.nice_name == "Shinobu Kochou":
		card_ui = ShinobuKochou.new()
	if json_data.nice_name == "Belmod":
		card_ui = Belmod.new()
	if json_data.nice_name == "Fortuneteller Baba":
		card_ui = FortunetellerBaba.new()
	
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
	card_ui.beauty = json_data.beauty
	
	var save_result = ResourceSaver.save(card_ui, 'res://card/faux/data/' + json_data.nice_name + '.tres')
	
	if save_result != OK:
		print(save_result)


func create_battle_resource(json_data : Dictionary):
	var card_ui = Battle.new()
	
	card_ui.front_image_path = json_data.front_image_path
	card_ui.back_image_path = json_data.back_image_path
	card_ui.front_mini_path = json_data.front_mini_path
	card_ui.back_mini_path = json_data.back_mini_path
	card_ui.id = json_data.id
	card_ui.nice_name = json_data.nice_name
	card_ui.power = json_data.power
	
	var save_result = ResourceSaver.save(card_ui, 'res://card/battle/data/' + json_data.nice_name + '.tres')
	
	if save_result != OK:
		print(save_result)
