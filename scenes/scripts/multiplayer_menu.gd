extends Control

const PORT = 7000
var server_ip = "" # IPv4 localhost
const MAX_CONNECTIONS = 3

@onready var main_menu = $"."
@onready var host_button: Button = $Host
@onready var ip_box: LineEdit = $IPBox
@onready var hand_amount: LineEdit = $"Hand Amount"

var players = {}
var player_info = {
	"id": "id",
	"name": "Name"}
	
@onready var faux_card_select: Control = $"Faux Card Select"

func _ready():
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


func peer_connected(id):
	print("Player Connected: ", id)
	add_player_info.rpc_id(id, player_info)

	start_game.call_deferred()
	
func peer_disconnected(id):
	print("Disconnected to Server: ", id)

func connected_to_server():
	print("Connected to Server")
	add_player_info.rpc_id(1, "Goku", multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed: ")


func _on_host_button_pressed():
	set_start_hand_amount(int(hand_amount.text))
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	add_player_info("Goku", multiplayer.get_unique_id())
	
	print("Waiting for player")


func _on_join_button_pressed():
	server_ip = ip_box.text
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_ip, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	

@rpc("any_peer","reliable")
func add_player_info(name, id):
	if !Global.Players.has(id):
		Global.Players[id] = {
			"name" : name,
			"id" : id,
		}

	if multiplayer.is_server():
		for i in Global.Players:
			add_player_info.rpc(Global.Players[i].name, i)


@rpc("any_peer","call_local","reliable")
func start_game():
	faux_card_select.start_set_faux_card()
	
	var game_scene = load("res://scenes/3d/playground.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	main_menu.hide()


func set_start_hand_amount(num: int):
	Global.start_hand_amount = num


func _on_start_button_pressed():
	start_game.rpc()


func _on_screen_button_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		return
		
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_hand_amount_text_changed(new_text: String) -> void:
	if new_text.is_valid_int() and int(new_text) <= 30:
		host_button.disabled = false
	else:
		host_button.disabled = true
