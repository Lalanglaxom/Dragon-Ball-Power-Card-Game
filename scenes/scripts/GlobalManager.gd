extends Node

## Signal Bus
# Card Signal
# The arguments is for separating, not functioning
signal card_hover(Card2D)
signal card_unhover(Card2D)
signal card_chosen(Card2D)
signal card_return(Card2D)

signal card_3d_hover(Card3D)
signal card_3d_unhover(Card3D)
signal card_3d_button(Card3D)
signal card_3d_flip(Card3D)


# Pile Signal
signal draw_pile_updated()
signal on_draw_pressed(amount: int)
signal card_drew(Card2D)


# Game Siganl
signal end_turn_pressed()

var Players = {}

var faux_cards: Array[Card2D]

enum State {OTHER_TURN, YOUR_TURN}
var state: State

enum Phase {STANDOFF, BATTLE} 
var current_phase: Phase    

func print_multi(thing):
	print(str(multiplayer.get_unique_id()) + ": " + str(thing))
