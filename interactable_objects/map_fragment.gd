extends MeshInstance3D

#Prompt shown when player looks at map
@onready var prompt = $Prompt

@onready var area := $Area3D as Area3D

#Potential map fragment textures
@export var fragment_image_1 : CompressedTexture2D
@export var fragment_image_2 : CompressedTexture2D
@export var fragment_image_3 : CompressedTexture2D

#The floor of the maze, and which fragment piece it is
var floor = 0
var fragment = 0

func _ready() -> void:
	#Prompt not visible by default
	prompt.visible = false

#Changes the map texture according to the floor and fragment number
func Generate(new_floor, new_fragment):
	
	floor = new_floor
	fragment = new_fragment
	
	mesh = mesh.duplicate()
	var new_material = mesh.surface_get_material(0).duplicate()
	
	#Choosing correct fragment texture
	if fragment == 1:
		new_material.set_shader_parameter("fragment_image", fragment_image_1)
	if fragment == 2:
		new_material.set_shader_parameter("fragment_image", fragment_image_2)
	if fragment == 3:
		new_material.set_shader_parameter("fragment_image", fragment_image_3)
	
	#Adding maze texture
	var file_path = "user://maps/map"+str(floor)+".png"
	var map_texture = ImageTexture.create_from_image(Image.load_from_file(file_path))
	new_material.set_shader_parameter("map_image", map_texture)
	mesh.surface_set_material(0, new_material)
	

#Shows prompt
func Prompt():
	prompt.visible = true

#Hides prompt
func RemovePrompt():
	prompt.visible = false

#Picks up map and adds it to the inventory
func Interact():
	prompt.visible = false
	#If it's the first time picking up a fragment, shows a tutorial window
	if GlobalVariables.map_fragments.size() == 0:
		var tut = preload("res://ui/map_pick_prompt.tscn").instantiate()
		get_parent().add_child(tut)
	GlobalVariables.map_fragments.append(str(floor) + "-" + str(fragment))
	queue_free()
