extends Node

## Signal Bus
# Card Signal
signal card_hover(Card2D)
signal card_unhover(Card2D)
signal card_3d_hover(Card3D)
signal card_3d_unhover(Card3D)

signal card_chosen(Card3D)

# Pile Signal
signal draw_pile_updated()
signal on_draw_pressed()
signal card_drew(Card2D)

var Players = {}
