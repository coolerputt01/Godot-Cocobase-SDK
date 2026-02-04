extends Node

class_name Cocobase

var apiUrl := "https://api.cocobase.buzz";
var ws_url = ""
var apiKey := "";

var ws := WebSocketClient.new()

var reconnect_delay = 1.0
var max_reconnect_delay = 30.0
var should_reconnect = true

signal connected
signal message_received(data)
signal closed
signal document_created(data)
signal document_updated(data)
signal document_deleted(data)

var auth_data = {}
var current_collection = ""
var filters = {}


func init(_apikey):
	apiKey = _apikey;

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
	var data = {}
	if text != "":
		data = JSON.parse(text)
	print(data.result)
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
	if ws and ws.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
		ws.poll()


func _start_websocket():
	# Always recreate socket
	ws = WebSocketClient.new()

	ws.connect("connection_established", self, "_on_connected")
	ws.connect("connection_closed", self, "_on_closed")
	ws.connect("connection_error", self, "_on_closed")
	ws.connect("data_received", self, "_on_data")

	var err = ws.connect_to_url(ws_url)
	if err != OK:
		print("Watcher connection error")

	set_process(true)


func _on_connected(protocol):
	reconnect_delay = 1.0
	send(auth_data)
	emit_signal("connected")

func _on_closed(was_clean = false):
	emit_signal("closed")

	if should_reconnect and current_collection != "":
		yield(get_tree().create_timer(reconnect_delay), "timeout")
		reconnect_delay = min(reconnect_delay * 2, max_reconnect_delay)
		_start_websocket()

func _on_data():
	var peer = ws.get_peer(1)
	var pkt = peer.get_packet().get_string_from_utf8()

	var parsed = JSON.parse(pkt)
	if parsed.error != OK:
		print("Invalid JSON")
		return

	var data = parsed.result
	var event_type = data.get("event", "")

	match event_type:
		"connected":
			emit_signal("connected", data)
		"create":
			emit_signal("document_created", data)
		"update":
			emit_signal("document_updated", data)
		"delete":
			emit_signal("document_deleted", data)
		_:
			print("Unknown event:", event_type)


func send(data):
		if ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
			var json = JSON.print(data)
			ws.get_peer(1).put_packet(json.to_utf8())


func close():
	should_reconnect = false
	ws.disconnect_from_host()

func watch_collection(collection_name:String, _filters:Dictionary = {}):
	current_collection = collection_name
	filters = _filters

	ws_url = apiUrl.replace("https://", "wss://").replace("http://", "ws://")
	ws_url += "/realtime/collections/" + collection_name

	auth_data = {
		"api_key": apiKey,
		"filters": filters
	}

	_start_websocket()
