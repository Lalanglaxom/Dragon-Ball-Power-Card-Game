extends Area3D

@onready var full_pile: FullPile = $"../FullPile"

const STATIC_CARD_3D = preload("res://scenes/3d/static_card_3d.tscn")

var draw_pile_3d := []
var pile_max_size := 30


@export var gap: float = 1
@export var draw_amount: int = 3


func _ready() -> void:
	create_3d_draw_pile()


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if draw_pile_3d.size() == 0: return
			
			full_pile.draw(draw_amount)
			
			if draw_pile_3d.size() < draw_amount:
				draw_amount = draw_pile_3d.size()
			
			if full_pile.draw_pile.size() <= pile_max_size:
				while full_pile.draw_pile.size() < draw_pile_3d.size():
					var card = draw_pile_3d[draw_pile_3d.size() - 1]
					draw_pile_3d.erase(card)
					remove_child(card)
					
				for i in range(draw_amount):
					var card = draw_pile_3d[draw_pile_3d.size() - 1]
					draw_pile_3d.erase(card)
					remove_child(card)
					
				arrange_3d_card() 

func create_3d_draw_pile():
	while draw_pile_3d.size() < pile_max_size:
		var card_3d = STATIC_CARD_3D.instantiate()
		draw_pile_3d.append(card_3d)
		add_child(card_3d)
		
	arrange_3d_card() 


func arrange_3d_card():
	for i in draw_pile_3d.size():
		draw_pile_3d[i].position.y = 0
		draw_pile_3d[i].position.y += i * gap
		
