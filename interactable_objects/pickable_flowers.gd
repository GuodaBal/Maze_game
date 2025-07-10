extends Node3D

@onready var picked = $Picked
@onready var unpicked = $Unpicked
@onready var prompt = $Prompt
@onready var area := $Area3D as Area3D

var is_picked = false

#Shows unpicked version
func _ready() -> void:
	picked.visible = false
	unpicked.visible = true
	prompt.visible = false

#Prompt visibility control
func Prompt():
	if !is_picked:
		prompt.visible = true

func RemovePrompt():
	prompt.visible = false

#Picks flowers and adds them to inventory
func Interact():
	if !is_picked:
		picked.visible = true
		unpicked.visible = false
		is_picked = true
		prompt.visible = false
		GlobalVariables.flower_amount += 7
		SignalBus.flower_count_changed.emit()
		#If player hasn't picked flowers before, shows tutorial
		if !GlobalVariables.have_picked_flowers:
			var tut = preload("res://ui/flower_pick_prompt.tscn").instantiate()
			add_child(tut)
			GlobalVariables.have_picked_flowers = true
