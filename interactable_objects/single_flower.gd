extends Node3D

@onready var prompt = $Prompt

#Prompt visibility control
func Prompt():
	prompt.visible = true

func RemovePrompt():
	prompt.visible = false

#Picks up flower and adds it to counter
func Interact():
	GlobalVariables.flower_amount += 1
	SignalBus.flower_count_changed.emit()
	queue_free()
