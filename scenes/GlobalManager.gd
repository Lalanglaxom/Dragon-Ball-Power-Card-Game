extends Node

signal ready_button_pressed
signal card_flipped_up(card_ui)
signal card_flipped_down(card_ui)

var Players = {}
var full_pile := []
var hand_pile := []
var hand_pile_p2 := []
