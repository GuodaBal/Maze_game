extends Control

@onready var text := $RichTextLabel as RichTextLabel

#Starts display
func _ready() -> void:
	SignalBus.flower_count_changed.connect(Update)
	Update()

#Updates counter
func Update():
	text.text = "Flowers: " + str(GlobalVariables.flower_amount)
