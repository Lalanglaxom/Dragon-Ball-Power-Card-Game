extends Node
class_name GameController

@onready var info = $CanvasLayer/Info
@onready var full_pile = $CanvasLayer/FullPile

# Hand Control
const CHOSEN_BOX_01 = preload("res://card/properties/chosen_box_01.png")
const CHOSEN_BOX_02 = preload("res://card/properties/chosen_box_02.png")
const CHOSEN_BOX_03 = preload("res://card/properties/chosen_box_03.png")

static var number_is_chosen := 0
var cards_is_choosing = [] 

func _ready():
	full_pile.draw(18)
	print(number_is_chosen)

func _on_card_unhovered(card):
	info.texture = null


func _on_card_hovered(card):
	info.texture = load(card.card_data.big_image)


func _on_hand_card_clicked(card):
	number_is_chosen += 1
	cards_is_choosing.append(card)
	if number_is_chosen <= 3:
		print(number_is_chosen)
		set_chosen_box()

func _on_card_unclicked(card):
	number_is_chosen -= 1
	card.get_node('ChosenBox').hide()
	cards_is_choosing.erase(card)
	set_chosen_box()
	
func set_chosen_box():
	for i in range(cards_is_choosing.size()):
		var child = cards_is_choosing[i].get_node('ChosenBox')  # Get the chosen box node
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
										

	
