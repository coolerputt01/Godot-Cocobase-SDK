extends Node

class_name Cocobase

var apiUrl := "https://api.cocobase.buzz";
var apiKey := "";

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

func updateCollection(collectionId:String,newCollectionName:String):
	var validUrl = "/collection/" + collectionId;
	var data_body = {
		"name":newCollectionName
	};
	return send_request(validUrl,HTTPClient.METHOD_PUT,data_body);

func deleteCollection(collectionId:String):
	var validUrl = "/collection/" + collectionId;
	return send_request(validUrl,HTTPClient.METHOD_DELETE);

func create_document(collectionName:String,data: Dictionary):
	print("create_document data:", data)
	var validUrl = "/collections/documents?collection=" + collectionName;
	var data_body = {
		"data":data
	};
	return send_request(validUrl,HTTPClient.METHOD_POST,data_body);

func get_all_documents(collectionId: String):
	var validUrl = "/collections/" + collectionId + "/documents?limit=50&offset=0";
	return send_request(validUrl,HTTPClient.METHOD_GET);

func getDocument(collectionId:String,documentId:String):
	var validUrl = "/collections/" + collectionId + '/' + documentId;
	return send_request(validUrl,HTTPClient.METHOD_GET);

func updateDocument(collectionId:String,documentId:String,data: Dictionary):
	var validUrl = "/collections/" + collectionId + '/' + documentId;
	var data_body = {
		"data":data
	};
	return send_request(validUrl,HTTPClient.METHOD_PUT,data_body);

func deleteDocument(collectionId:String,documentId:String,data: Dictionary):
	var validUrl = "/collections/" + collectionId + '/' + documentId;
	return send_request(validUrl,HTTPClient.METHOD_DELETE);

func countDocument(collectionId:String):
	var validUrl = "/collections/" + collectionId + '/query/documents/count' ;
	return send_request(validUrl,HTTPClient.METHOD_GET);

func exportCollection(collectionId:String):
	var validUrl = "/collections/" + collectionId + "/export";
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
	var validUrl = "/auth(-collections/verify-email/resend";
	return send_request(validUrl,HTTPClient.METHOD_POST,{});

