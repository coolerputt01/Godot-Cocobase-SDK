extends Node2D


var cocobase = Cocobase.new();
func _ready() -> void:
	var env = cocobase.load_env();
	print(env);
	add_child(cocobase);
	cocobase.init(env["COCOBASE_KEY"],env["COCOBASE_PROJECT_ID"]);

	# Cocobase Basic signals.
	cocobase.connect("connected", self, "_on_connected")
	cocobase.connect("message_received", self, "_on_message")
	cocobase.connect("error", self, "_on_error")
	cocobase.connect("closed", self, "_on_closed")
	cocobase.connect("room_created", self, "_on_room_created")
	cocobase.connect("user_joined", self, "_on_user_joined")
	cocobase.connect("user_left", self, "_on_user_left")

	cocobase.create_room("room1","Lobby-1")
	#cocobase._process()


# Signal callbacks.
func _on_connected(data = {}):
	print("‚úÖConnected to WebSocket!", data)

func _on_message(data):
	print("Ì†ΩÌ≥®Message received:", data)

func _on_error(data):
	print("‚ùåWebSocket error:", data)

func _on_closed():
	print("‚ö°Connection closed!")

func _on_room_created(data):
	print("Ì†ºÌæâRoom created:", data)
	var auth_data = {
		"api_key": cocobase.apiKey,
		"action": "join",
		"room_title": "Lobby-1",
		"user_id": "0",
		"user_name": "gamer002"
	}
	cocobase.send(auth_data)

func _on_user_joined(data):
	print("Ì†ΩÌ±§User joined:", data)

func _on_user_left(data):
	print("Ì†ΩÌ±§User left:", data)
