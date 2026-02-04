extends Node2D


var cocobase = Cocobase.new();
func _ready() -> void:
	add_child(cocobase);
	cocobase.init("npYdLh6y1363mC8hLiTlf94VL1dDO13TTjwdTL6N");
	cocobase.get_all_documents("989641d9-61b9-4bc5-a317-b0e347bb347b");


	cocobase.connect("connected", self, "_on_connected")
	cocobase.connect("document_created", self, "_on_created")
	cocobase.connect("document_updated", self, "_on_updated")
	cocobase.connect("document_deleted", self, "_on_deleted")
	cocobase.connect("closed", self, "_on_closed")

	cocobase.watch_collection("tasks")

	cocobase.create_document("tasks", {
		"title": "Realtime test",
		"done": false
	})

