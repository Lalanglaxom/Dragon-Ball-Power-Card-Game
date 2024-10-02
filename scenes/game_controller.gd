extends Node
class_name GameController

@onready var info: TextureRect = $Ground/Info
@onready var full_pile: FullPile = $FullPile
@onready var debugger = $Panel/Debugger

@onready var player = get_tree().get_nodes_in_group("player")

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
@onready var battle_zone_1 = $BattleZoneCollection/BattleZone1
@onready var battle_zone_2 = $BattleZoneCollection/BattleZone2
@onready var battle_zone_3 = $BattleZoneCollection/BattleZone3
@onready var power_1 = $BattleZoneCollection/BattleZone1/Power1
@onready var power_2 = $BattleZoneCollection/BattleZone2/Power2
@onready var power_3 = $BattleZoneCollection/BattleZone3/Power3


## Card On Battle Control
@onready var card_on_battle_box = $ButtonControl/CardOnBattle
var current_battle_card : CardUI
@onready var p1_combine_power_label = $Player1/CombinePower
@export var p1_power_label: Array[Control]
var p1_base_power = [0,0,0]
var p1_curent_power = [0,0,0]

# lerp power variables
var p1_combine_value: float = 0
var p1_current_combine_power: float = 0
var p1_combine_power : float = 0

## General
# lerp text 
var time = 0
var duration = 1.5

func _ready():
	#card_on_battle_box.hide()
	pass
	

func _process(delta):
	battle_power_process(delta)
	pass


func _input(event):
	if event.is_action_pressed("space"):
		#_text.rpc()
		#full_pile.shuffle_deck.rpc_id(1)
		full_pile.draw(5)

@rpc("authority", "call_local")
func _text():
	#print("Debugger text:", debugger.text)
	print("Debugger ID:", multiplayer.get_unique_id())
	
	#if multiplayer.is_server():
		#print("This is server")
		
	#for i in GlobalManager.Players:
		##if i == multiplayer.get_unique_id():
			##debugger.text = "Name: " + GlobalManager.Players[i].name
		#print(GlobalManager.Players[i])	
	
	#print(full_pile._hand_pile.size())
	
	#for card in full_pile._draw_pile:
		#print(card.card_data.nice_name)
	
	for i in GlobalManager.full_pile:
		print(i.card_data.nice_name)
		
func _update_power_label(i,power):
	match i:
		0:
			power_1.text = str(power)
		1:
			power_2.text = str(power)
		2:
			power_3.text = str(power)
		_:
			power_1.text = str(power)
			power_2.text = str(power)
			power_3.text = str(power)
	
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
			var card = p1_cards_is_choosing[i]
			card.get_node('ChosenBox').hide()
			match i:
				0:
					full_pile.set_card_dropzone(card, battle_zone_1)
				1:
					full_pile.set_card_dropzone(card, battle_zone_2)
				2:
					full_pile.set_card_dropzone(card, battle_zone_3)
				_:
					print("There are errors in Move to Dropzone Script")
			#_update_power_label(i,card.card_data.power)
			card.set_states()
		#p1_cards_is_choosing.clear()
		#p1_number_is_chosen = 0
		#GlobalSignal.emit_signal("ready_button_pressed", self)


func _on_battle_card_clicked(card):
	current_battle_card = card

	card_on_battle_box.show()
	card_on_battle_box.position = card.position
	card_on_battle_box.position.y += card.size.y/2
	card_on_battle_box.position.x += card.size.x/4


func _on_flip_button_up():
	if current_battle_card:
		current_battle_card.flipable = true # enable card flipping 
	card_on_battle_box.hide()
	

func battle_power_process(delta):
	if p1_cards_is_choosing.size() > 0:
		for i in range(p1_cards_is_choosing.size()):
			var card = p1_cards_is_choosing[i]
			
			# set current and base power
			p1_base_power[i] = card.card_data.power
			p1_curent_power[i] = p1_base_power[i]

			# set text logic
			if card.is_face_up and card.current_state == card.States.on_battle:
				p1_power_label[i].text = str(p1_curent_power[i])
			else: 
				p1_power_label[i].text = ''

		# combine power logic
		if p1_combine_power < p1_current_combine_power:
			time += delta
			p1_combine_value = lerpf(p1_combine_power,p1_current_combine_power, time/duration)
			p1_combine_power_label.text = str(round(p1_combine_value))
			if time >= 1:	
				p1_combine_power = p1_current_combine_power
				p1_combine_power_label.text = str(round(p1_combine_power))
		else:
			time = 0
			p1_combine_value = 0


func _on_card_flipped_up(card_ui):
	for i in range(p1_cards_is_choosing.size()):
		if card_ui == p1_cards_is_choosing[i]:
			p1_current_combine_power += p1_curent_power[i]


func _on_card_flipped_down(card_ui):
	for i in range(p1_cards_is_choosing.size()):
		if card_ui == p1_cards_is_choosing[i]:
			p1_current_combine_power -= p1_curent_power[i]
