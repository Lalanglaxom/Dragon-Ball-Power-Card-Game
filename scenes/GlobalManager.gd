extends Node

## Signal Bus
signal draw_pile_updated
signal hand_pile_p1_updated(card: CardUI)
signal hand_pile_p2_updated(card: CardUI)
signal hand_pile_p3_updated(card: CardUI)
signal discard_pile_updated
signal card_removed_from_dropzone(dropzone : CardDropzone, card: CardUI)
signal card_added_to_dropzone(dropzone : CardDropzone, card: CardUI)

var Players = {}
