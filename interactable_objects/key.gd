extends Node3D

@onready var prompt = $Prompt
@onready var area := $Area3D as Area3D

#Controlling prompt visibility
func _ready() -> void:
	prompt.visible = false

func Prompt():
	prompt.visible = true

func RemovePrompt():
	prompt.visible = false

#Picks up the key and adds it to the count
func Interact():
	prompt.visible = false
	if GlobalVariables.key_amount == 0:
		var key_count = preload("res://ui/key_count.tscn").instantiate()
		get_parent().add_child(key_count)
	GlobalVariables.key_amount += 1
	SignalBus.key_count_changed.emit()
	queue_free()
