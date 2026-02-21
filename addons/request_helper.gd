extends Node

class_name Cocobase

var apiUrl := "https://api.cocobase.buzz";
var ws_url = "";
const BASE_WS_URL := "wss://cloud.cocobase.buzz"
var apiKey := "";
var projectId = "";

var ws := WebSocketClient.new()

var reconnect_delay = 1.0
var max_reconnect_delay = 30.0
var should_reconnect = true
var connection_mode = ""

signal connected
signal message_received(data)
signal closed
signal document_created(data)
signal document_updated(data)
signal document_deleted(data)
signal error(data)
signal room_created(data)
signal user_joined(data)
signal user_left(data)


var auth_data = {}
var current_collection = ""
var filters = {}

var ping_timer : Timer


func init(_apikey,_projectId):
	apiKey = _apikey;
	projectId = _projectId;

func load_env(path:String="res://.env"):
	var env = {}
	var file = File.new()

	if not file.file_exists(path):
		print("No .env file found")
		return env

	file.open(path, File.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue

		var parts = line.split("=")

		if parts.size() >= 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()
			env[key] = value
	file.close()
	return env

func send_request(path: String, method := HTTPClient.METHOD_GET, body : Dictionary = {}):
	var url = apiUrl + path;
	var request = HTTPRequest.new();
	add_child(request);
	print(body)
	request.connect("request_completed", self, "_on_request_completed",[request],CONNECT_ONESHOT);

	var headers = [
		"Content-Type: application/json",
		"x-api-key: " + apiKey
	]

	var json = ""
	if body != null:
		json = to_json(body)
		var body_bytes = json.to_utf8()
		request.request(url, headers, true, method, json)
	else:
		request.request(url, headers, true, method)
	return request

func _on_request_completed(result, response_code, headers, body,request_node):
	var text = body.get_string_from_utf8()

	if text == "":
		request_node.queue_free()
		return

	var parse = JSON.parse(text)
	if parse.error != OK:
		emit_signal("error", {"error": "Invalid JSON response"})
		request_node.queue_free()
		return

	var data = parse.result
	print(data)
	request_node.queue_free();

func create_collection(collectionName: String):
	var validUrl = "/collections/";
	var data_body = {
		"name":collectionName
	};
	return send_request(validUrl,HTTPClient.METHOD_POST,data_body);

func updateCollection(collectionName:String,newCollectionName:String):
	var validUrl = "/collection/" + collectionName;
	var data_body = {
		"name":newCollectionName
	};
	return send_request(validUrl,HTTPClient.METHOD_PUT,data_body);

func deleteCollection(collectionName:String):
	var validUrl = "/collection/" + collectionName;
	return send_request(validUrl,HTTPClient.METHOD_DELETE);

func create_document(collectionName:String,data: Dictionary):
	print("create_document data:", data)
	var validUrl = "/collections/documents?collection=" + collectionName;
	var data_body = {
		"data":data
	};
	return send_request(validUrl,HTTPClient.METHOD_POST,data_body);

func get_all_documents(collectionName: String):
	var validUrl = "/collections/" + collectionName + "/documents?limit=50&offset=0";
	return send_request(validUrl,HTTPClient.METHOD_GET);

func getDocument(collectionName:String,documentId:String):
	var validUrl = "/collections/" + collectionName + '/' + documentId;
	return send_request(validUrl,HTTPClient.METHOD_GET);

func updateDocument(collectionName:String,documentId:String,data: Dictionary):
	var validUrl = "/collections/" + collectionName + '/' + documentId;
	var data_body = {
		"data":data
	};
	return send_request(validUrl,HTTPClient.METHOD_PUT,data_body);

func deleteDocument(collectionName:String,documentId:String,data: Dictionary):
	var validUrl = "/collections/" + collectionName + '/' + documentId;
	return send_request(validUrl,HTTPClient.METHOD_DELETE);

func countDocument(collectionName:String):
	var validUrl = "/collections/" + collectionName + '/query/documents/count' ;
	return send_request(validUrl,HTTPClient.METHOD_GET);

func exportCollection(collectionName:String):
	var validUrl = "/collections/" + collectionName + "/export";
	return send_request(validUrl,HTTPClient.METHOD_GET);


# Users amd User-Endpoint.

func loginUser(data:Dictionary):
	var validUrl = "/auth-collections/login";
	return send_request(validUrl,HTTPClient.METHOD_POST,data);

func createUser(data:Dictionary):
	var validUrl = "/auth-collections/login";
	return send_request(validUrl,HTTPClient.METHOD_POST,data);

func getAllUsers(authId: String):
	var validUrl = "/auth-collections/users/" + authId;
	return send_request(validUrl,HTTPClient.METHOD_GET);

func getCurrentUser():
	var validUrl = "/auth-collections/user/";
	return send_request(validUrl,HTTPClient.METHOD_GET);

func updateCurrentUser():
	var validUrl = "/auth-collections/user/";
	return send_request(validUrl,HTTPClient.METHOD_PATCH);

func sendVerificationEmail():
	var validUrl = "/auth-collections/verify-email/send";
	return send_request(validUrl,HTTPClient.METHOD_POST,{});

func verifyEmail(token: String):
	var validUrl = "/auth-collections/verify-email/verify";
	var data_body = {
		"token":token
	}
	return send_request(validUrl,HTTPClient.METHOD_POST,data_body);

func resendVerificationEmail():
	var validUrl = "/auth-collections/verify-email/resend";
	return send_request(validUrl,HTTPClient.METHOD_POST,{});


func _process(delta):
	if ws and (
		ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTING or
		ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED
	):
		ws.poll()



func _start_websocket():

	if ping_timer:
		ping_timer.stop()
		ping_timer.queue_free()
		ping_timer = null

	if ws:
		ws.disconnect_from_host()
		ws = null


	# Always recreate socket
	ws = WebSocketClient.new()

	ws.connect("connection_established", self, "_on_connected")
	ws.connect("connection_closed", self, "_on_closed")
	ws.connect("connection_error", self, "_on_closed")
	ws.connect("data_received", self, "_on_data")

	ping_timer = Timer.new()
	ping_timer.wait_time = 30
	ping_timer.autostart = true
	ping_timer.one_shot = false
	add_child(ping_timer)
	ping_timer.connect("timeout", self, "_send_ping")


	var err = ws.connect_to_url(ws_url)
	if err != OK:
		emit_signal("error", {"error": "Connection failed"})

	set_process(true)


func _on_connected(protocol):
	reconnect_delay = 1.0
	if auth_data != {}:
		send(auth_data)
	emit_signal("connected")

func _on_closed():
	print("⚡Connection closed!")
	emit_signal("closed")

	if should_reconnect and connection_mode != "":
		yield(get_tree().create_timer(reconnect_delay), "timeout")
		reconnect_delay = min(reconnect_delay * 2, max_reconnect_delay)
		_start_websocket()

func _on_data():
	if not ws:
		return

	var peer = ws.get_peer(1)
	if not peer:
		return

	if peer.get_available_packet_count() == 0:
		return

	var pkt = peer.get_packet().get_string_from_utf8()
	print("Received raw data:", pkt)

	var parsed = JSON.parse(pkt)
	if parsed.error != OK:
		emit_signal("error", {"error": "Invalid JSON", "data": pkt})
		return


	var data = parsed.result
	var event_type = data.get("event", "")

	emit_signal("message_received", data)

	match event_type:
		"connected":
			emit_signal("connected", data)
		"create":
			emit_signal("document_created", data)
		"update":
			emit_signal("document_updated", data)
		"delete":
			emit_signal("document_deleted", data)
		"room_created":
			emit_signal("room_created", data)
		"user_joined":
			emit_signal("user_joined", data)
		"user_left":
			emit_signal("user_left", data)
		_:
			print("Unknown event:", event_type)



func send(data):
		if ws and  ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
			var json = JSON.print(data)
			ws.get_peer(1).put_packet(json.to_utf8())

func _send_ping():
	send({"type": "ping"})

func send_room_message(content):
	send({
		"type": "message",
		"content": content
	})

# wss://cloud.cocobase.buzz/ws/3dc34222-9472-4cce-8712-125efa250bd8/websockets

func connect_broadcast(func_name):
	should_reconnect = true
	current_collection = ""
	connection_mode = "broadcast"

	#ws_url = "wss://cloud.cocobase.buzz/ws/"+projectId+"/"+func_name
	ws_url = "wss://api.cocobase.buzz/realtime/broadcast";
	auth_data = {
		"api_key": apiKey
	}
	_start_websocket()


func close():
	should_reconnect = false

	if ping_timer:
		ping_timer.stop()
		ping_timer.queue_free()
		ping_timer = null

	if ws:
		ws.disconnect_from_host()

	set_process(false)

func create_room(room_id:String, room_title:String = ""):
	should_reconnect = true
	current_collection = ""
	connection_mode = "room"

	ws_url = "wss://api.cocobase.buzz/realtime/rooms/" + room_id

	auth_data = {
		"api_key": apiKey,
		"action": "create",
		"room_title": room_title,
		"user_id": "0",
		"user_name": "gamer002"
	}

	_start_websocket()


func join_room(room_id:String,room_title: String):
	should_reconnect = true
	current_collection = ""
	connection_mode = "room"

	print("hi")

	ws_url = "wss://api.cocobase.buzz/realtime/rooms/" + room_id

	auth_data = {
		"api_key": apiKey,
		"action": "join",
		"room_title": room_title,
		"user_id": "0",
		"user_name": "gamer002"
	}
	_start_websocket()



func watch_collection(collection_name:String, _filters:Dictionary = {}):

	should_reconnect = true
	connection_mode = "collection"
	current_collection = collection_name
	filters = _filters

	ws_url = BASE_WS_URL + "/realtime/collections/" + collection_name

	auth_data = {
		"api_key": apiKey,
		"filters": filters
	}

	_start_websocket()
