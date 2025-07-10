extends Control

#Stops game
func _ready() -> void:
	get_tree().root.process_mode = Node.PROCESS_MODE_DISABLED

#Removes screen and starts game
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().root.process_mode = Node.PROCESS_MODE_ALWAYS
		queue_free()
