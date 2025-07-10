extends Node3D

@onready var prompt = $Prompt
@onready var prompt_text := $Prompt/RichTextLabel as RichTextLabel
@onready var area := $Area3D as Area3D

@export var needed_keys = 3

#Changes prompt visibility
func _ready() -> void:
	prompt.visible = false
	prompt_text.text = "Need " + str(needed_keys) + " keys to unlock"

func Prompt():
	prompt.visible = true

func RemovePrompt():
	prompt.visible = false

#Unlocks door and shows the win screen
func Interact():
	if GlobalVariables.key_amount == needed_keys:
		prompt.visible = false
		var win_screen = preload("res://ui/win_screen.tscn").instantiate()
		get_parent().add_child(win_screen)
