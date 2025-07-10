extends Control

@onready var text := $RichTextLabel as RichTextLabel

#Connects to signal bus
func _ready() -> void:
	SignalBus.key_count_changed.connect(Update)
	Update()

#Updates counter
func Update():
	text.text = "Keys: " + str(GlobalVariables.key_amount)
