extends Control

const PORT = 7000
var server_ip = "" # IPv4 localhost
const MAX_CONNECTIONS = 3

@onready var main_menu = $"."
@onready var name_box_2: LineEdit = $NameBox2

var players = {}
var player_info = {
	"id": "id",
	"name": "Name"}
	
@onready var faux_card_select: Control = $"Faux Card Select"

func _ready():
	server_ip = name_box_2.text
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


func connect_upnp():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()

	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var map_result_udp = upnp.add_port_mapping(9999, 9999, "godot_udp", "UDP", 0)
			var map_result_tcp = upnp.add_port_mapping(9999, 9999, "godot_tcp", "TCP", 0)

			if map_result_udp != UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999, 9999, "", "UDP")
			if map_result_tcp != UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(9999, 9999, "", "TCP")

	var external_adress = upnp.query_external_address()
	print(external_adress)
	print("A")
	upnp.delete_port_mapping(9999, "UDP")
	upnp.delete_port_mapping(9999, "TCP")

func peer_connected(id):
	print("Player Connected: ", id)
	add_player_info.rpc_id(id, player_info)
	
func peer_disconnected(id):
	print("Disconnected to Server: ", id)

func connected_to_server():
	print("Connected to Server")
	add_player_info.rpc_id(1, $NameBox.text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed: ")


func _on_host_button_pressed():

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	add_player_info($NameBox.text, multiplayer.get_unique_id())
	print("Waiting for player")


func _on_join_button_pressed():
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

@rpc("any_peer","call_local")
func start_game():
	faux_card_select.start_set_faux_card()
	
	var game_scene = load("res://scenes/3d/playground.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	main_menu.hide()
	
	
func _on_start_button_pressed():
	start_game.rpc()
