extends Node
class_name GameController

@onready var info = $CanvasLayer/Info
@onready var full_pile = $CanvasLayer/FullPile

## Hand Control
const CHOSEN_BOX_01 = preload("res://card/properties/chosen_box_01.png")
const CHOSEN_BOX_02 = preload("res://card/properties/chosen_box_02.png")
const CHOSEN_BOX_03 = preload("res://card/properties/chosen_box_03.png")

static var p1_number_is_chosen := 0
static var p2_number_is_chosen := 0
static var p3_number_is_chosen := 0

var p1_cards_is_choosing = [] 
var p2_cards_is_choosing = [] 
var p3_cards_is_choosing = [] 

## Card Zone Control
# Player Zone
@onready var battle_zone_1 = $CanvasLayer/BattleZoneCollection/BattleZone1
@onready var battle_zone_2 = $CanvasLayer/BattleZoneCollection/BattleZone2
@onready var battle_zone_3 = $CanvasLayer/BattleZoneCollection/BattleZone3


## Card On Battle Control
@onready var card_on_battle_box = $CanvasLayer/ButtonControl/CardOnBattle
var current_battle_card : CardUI




func _ready():
	full_pile.draw(18)
	card_on_battle_box.hide()

func _on_card_unhovered(card):
	info.texture = null


func _on_card_hovered(card):
	info.texture = load(card.card_data.big_image)


func _on_hand_card_clicked(card):
	p1_number_is_chosen += 1
	p1_cards_is_choosing.append(card)
	if p1_number_is_chosen <= 3:
		set_chosen_box()

	if card.current_state == card.States.on_battle:
		print(card.card_data.nice_name)
	
	
func _on_hand_card_unclicked(card):
	p1_number_is_chosen -= 1
	card.get_node('ChosenBox').hide()
	p1_cards_is_choosing.erase(card)
	set_chosen_box()


func set_chosen_box():
	for i in range(p1_cards_is_choosing.size()):
		var child = p1_cards_is_choosing[i].get_node('ChosenBox')  # Get the chosen box node
		child.show()  # Make the child visible
		
		match i:
			0:
				child.texture = CHOSEN_BOX_01
			1:
				child.texture = CHOSEN_BOX_02
			2:
				child.texture = CHOSEN_BOX_03
				
			_:
				print("There are errors in ChosenBox Script")
										


func _on_ready_button_up():
	if p1_cards_is_choosing: # if cards_is_choosing have elements
		for i in range(p1_cards_is_choosing.size()):
			var child = p1_cards_is_choosing[i]
			child.get_node('ChosenBox').hide()
			match i:
				0:
					full_pile.set_card_dropzone(child, battle_zone_1)
				1:
					full_pile.set_card_dropzone(child, battle_zone_2)
				2:
					full_pile.set_card_dropzone(child, battle_zone_3)
				_:
					print("There are errors in Move to Dropzone Script")
			
			child.set_states()
		p1_cards_is_choosing.clear()
		p1_number_is_chosen = 0
		#GlobalSignal.emit_signal("ready_button_pressed", self)


func _on_battle_card_clicked(card):
	current_battle_card = card

	card_on_battle_box.show()
	card_on_battle_box.position = card.position
	card_on_battle_box.position.y += card.size.y/2
	card_on_battle_box.position.x += card.size.x/4


func _on_flip_button_up():
	if current_battle_card:
		current_battle_card.flipable = true
	card_on_battle_box.hide()
	
