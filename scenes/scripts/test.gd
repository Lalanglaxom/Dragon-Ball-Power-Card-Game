extends Node3D

@export var card: Card3D

func _ready() -> void:
	if multiplayer.is_server():
		var dict = inst_to_dict(card)
		test.rpc(dict)

@rpc("any_peer","call_remote","reliable")
func test(card):
	var inst = dict_to_inst(card)
	print(inst.name)
