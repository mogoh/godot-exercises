extends Node2D


const DEFAULT_PORT: int = 50_000
const LOCALHOST: String = "127.0.0.1"

@onready var gui_console = %console
@onready var chat = %chat


func host(port: int = DEFAULT_PORT) -> Error:
	var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = enet_peer.create_server(port)
	if error != OK:
		message_output("Error code: " + str(error))
		return error
	enet_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.server_disconnected.connect(server_disconnected)
	if multiplayer.is_server():
		message_output("Listening for connections.")
	return OK


func join(host_ip_address: String = LOCALHOST, port: int = DEFAULT_PORT) -> Error:
	var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = enet_peer.create_client(host_ip_address, port)
	if error != OK:
		message_output("Error code: " + str(error))
		return error
	enet_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.server_disconnected.connect(server_disconnected)
	return OK


func message_output(message: String):
	gui_console.append_text(message + "\n")
	print(message)


@rpc("any_peer", "reliable")
func send_message(message: String):
	message_output("Recived: " + message)

# this get called on the server and clients
func peer_connected(peer_id):
	message_output("Peer connected with id: " + str(peer_id))


# this get called on the server and clients
func peer_disconnected(peer_id):
	message_output("Peer disconnected id: " + str(peer_id))


# only on clients
func connected_to_server():
	message_output("Connected to server.")


# only on clients
func connection_failed():
	message_output("Could not connect.")


# only on clients
func server_disconnected():
	message_output("Server disconnected.")


func _on_host_pressed():
	host()


func _on_join_pressed():
	join()


func _on_quit_pressed():
	get_tree().quit()


func _on_terminate_server_pressed():
	if multiplayer.is_server():
		multiplayer.multiplayer_peer = null
		message_output("Self (server) Terminated.")


func _on_disconnect_client_pressed():
	if multiplayer.multiplayer_peer != null && !multiplayer.is_server():
		multiplayer.multiplayer_peer = null
		message_output("Self (client) disconnected.")


func _on_send_pressed():
	send_message.rpc(chat.text)
	message_output("Send: " + chat.text)
	chat.text = ""
