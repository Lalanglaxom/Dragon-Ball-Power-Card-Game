class_name FullPileData
extends Control

enum Piles {
	draw_pile,
	hand_pile_p1,
	hand_pile_p2,
	hand_pile_p3,
	grave_pile_p1,
	grave_pile_p2,
	grave_pile_p3,
	discard_pile
}

enum PilesCardLayouts {
	up,
	left,
	right,
	down
}

@export_file("*.json") var json_card_database_path : String
@export_file("*.json") var json_card_collection_path : String

var card_database := [] # an array of JSON `Card` data
var card_collection := [] # an array of JSON `Card` data

var _draw_pile := []
var hand_pile_p1 := [] 
var hand_pile_p2 := [] 
var hand_pile_p3 := [] 
var grave_pile_p1 := [] 
var grave_pile_p2 := [] 
var grave_pile_p3 := [] 
var _discard_pile := [] 


func _ready():
	load_json_path()
	_reset_card_collection()

# this is really the only way we should move cards between piles
func set_card_pile(card : CardUI, pile : Piles):
	_maybe_remove_card_from_any_piles(card)
	_maybe_remove_card_from_any_dropzones(card)
	if pile == Piles.discard_pile:
		_discard_pile.push_back(card)
		emit_signal("discard_pile_updated")
	if pile == Piles.hand_pile_p1:
		hand_pile_p1.push_back(card)
		GlobalManager.emit_signal("hand_pile_p1_updated", card)
	if pile == Piles.hand_pile_p2:
		hand_pile_p2.push_back(card)
		GlobalManager.emit_signal("hand_pile_p2_updated", card)
	if pile == Piles.hand_pile_p3:
		hand_pile_p3.push_back(card)
		GlobalManager.emit_signal("hand_pile_p3_updated", card)
	if pile == Piles.draw_pile:
		_draw_pile.push_back(card)
		emit_signal("draw_pile_updated")

	
func set_card_dropzone(card : CardUI, dropzone : CardDropzone):
	_maybe_remove_card_from_any_piles(card)
	_maybe_remove_card_from_any_dropzones(card)
	dropzone.add_card(card)
	emit_signal("card_added_to_dropzone", dropzone, card)
	
func remove_card_from_game(card : CardUI):
	_maybe_remove_card_from_any_piles(card)
	_maybe_remove_card_from_any_dropzones(card)
	emit_signal("card_removed_from_game", card)
	card.queue_free()
	

func get_cards_in_pile(pile : Piles):
	if pile == Piles.discard_pile:
		return _discard_pile.duplicate() # duplicating these so the end user can manipulate the returned array without touching the originals (like doing a forEach remove)
	elif pile == Piles.hand_pile_p1:
		return hand_pile_p1.duplicate()
	elif pile == Piles.hand_pile_p2:
		return hand_pile_p2.duplicate()
	elif pile == Piles.hand_pile_p3:
		return hand_pile_p3.duplicate()
	elif pile == Piles.draw_pile:
		return _draw_pile.duplicate()
	return []
	
func get_card_in_pile_at(pile : Piles, index : int):
	if pile == Piles.discard_pile and _discard_pile.size() > index:
		return _discard_pile[index]
	elif pile == Piles.draw_pile and _draw_pile.size() > index:
		return _draw_pile[index]
	elif pile == Piles.hand_pile_p1 and hand_pile_p1.size() > index:
		return hand_pile_p1[index]
	return null
		
func get_card_pile_size(pile : Piles):
	if pile == Piles.discard_pile:
		return _discard_pile.size()
	elif pile == Piles.hand_pile_p1:
		return hand_pile_p1.size()
	elif pile == Piles.hand_pile_p2:
		return hand_pile_p2.size()
	elif pile == Piles.hand_pile_p3:
		return hand_pile_p3.size()
	elif pile == Piles.draw_pile:
		return _draw_pile.size()
	return 0
	


func _maybe_remove_card_from_any_piles(card : CardUI):
	if hand_pile_p1.find(card) != -1:
		hand_pile_p1.erase(card)
		emit_signal("hand_pile_p1_updated")
	if hand_pile_p2.find(card) != -1:
		hand_pile_p2.erase(card)
		emit_signal("hand_pile_p2_updated")		
	if hand_pile_p3.find(card) != -1:
		hand_pile_p3.erase(card)
		emit_signal("hand_pile_p3_updated")
	elif _draw_pile.find(card) != -1:
		_draw_pile.erase(card)
		emit_signal("draw_pile_updated")
	elif _discard_pile.find(card) != -1:
		_discard_pile.erase(card)
		emit_signal("discard_pile_updated")


#func create_card_in_dropzone(nice_name : String, dropzone : CardDropzone):
	#var card_ui = _create_card_ui(_get_card_data_by_nice_name(nice_name))
	#set_card_dropzone(card_ui, dropzone)
			
#func create_card_in_pile(nice_name : String, pile_to_add_to : Piles):
	#var card_ui = _create_card_ui(_get_card_data_by_nice_name(nice_name))
	#set_card_pile(card_ui, pile_to_add_to)


func _maybe_remove_card_from_any_dropzones(card : CardUI):
	var all_dropzones := []
	_get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
	for dropzone in all_dropzones:
		if dropzone.is_holding(card):
			dropzone.remove_card(card)
			emit_signal("card_removed_from_dropzone", dropzone, card)

func get_card_dropzone(card : CardUI):
	var all_dropzones := []
	_get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
	for dropzone in all_dropzones:
		if dropzone.is_holding(card):
			return dropzone
	return null

			
func _get_dropzones(node: Node, className : String, result : Array) -> void:
	if node is CardDropzone:
		result.push_back(node)
	for child in node.get_children():
		_get_dropzones(child, className, result)
	

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

func reset():
	_reset_card_collection()

func _reset_card_collection():
	for child in get_children():
		_maybe_remove_card_from_any_piles(child)
		_maybe_remove_card_from_any_dropzones(child)
		remove_card_from_game(child)
	for nice_name in card_collection:
		var card_data = _get_card_data_by_nice_name(nice_name)
		_draw_pile.push_back(card_data)
		_draw_pile.shuffle()
	emit_signal("draw_pile_updated")
	emit_signal("hand_pile_p1_updated")
	emit_signal("hand_pile_p2_updated")
	emit_signal("hand_pile_p3_updated")
	emit_signal("discard_pile_updated")


func draw(num_cards := 1):
	_draw_pile.shuffle()
	for i in num_cards:
		if _draw_pile.size():
			set_card_pile(_draw_pile[_draw_pile.size() - 1], Piles.hand_pile_p1)
			set_card_pile(_draw_pile[_draw_pile.size() - 1], Piles.hand_pile_p2)


func _get_card_data_by_nice_name(nice_name : String):
	for json_data in card_database:
		if json_data.nice_name == nice_name:
			return json_data
	return null
