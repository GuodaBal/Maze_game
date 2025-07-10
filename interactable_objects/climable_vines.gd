extends Node3D

@onready var prompt = $Prompt

#Prompt visibility control
func _ready() -> void:
	prompt.visible = false

func Prompt():
	prompt.visible = true

func RemovePrompt():
	prompt.visible = false

#Changes whether player can climb
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.CanClimb(true)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.CanClimb(false)
