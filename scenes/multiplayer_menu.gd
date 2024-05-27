extends Control

const PORT = 7000
const SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 3
@onready var main_menu = $"."

var player_info = {
	"id": "id",
	"name": "Name"}

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	
func peer_connected(id):
	print("Player Connected: ", id)
	
func peer_disconnected(id):
	print("Disconnected to Server: ", id)

func connected_to_server():
	print("Connected to Server")
	send_player_info.rpc_id(1,multiplayer.get_unique_id(),$LineEdit.text)
	
func connection_failed():
	print("Connection failed: ")

@rpc("any_peer")
func send_player_info(id,name):
	if !GlobalManager.Players.has(id):
		GlobalManager.Players[id] = {
			"id": id,
			"name": name
		}
	
	if multiplayer.is_server():
		for i in GlobalManager.Players:
			send_player_info.rpc()
	
func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	send_player_info(multiplayer.get_unique_id(),name)
	print("Waiting for player")


func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(SERVER_IP, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

@rpc("any_peer","call_local")
func start_game():
	var game_scene = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	main_menu.hide()
	
	
func _on_start_button_pressed():
	start_game.rpc()
