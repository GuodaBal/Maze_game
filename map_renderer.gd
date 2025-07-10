extends Node3D

#All floors of the maze
@export var room_spawners: Array[Node3D]

#Needed to render an image of the maze
@onready var camera := $SubViewport/Camera3D as Camera3D
@onready var viewport := $SubViewport as SubViewport

#Is a layer currently being captured
var capturing = false

#Current layer being captured
var count = 0

func _ready() -> void:
	#Going through each layer of the maze
	for spawner in room_spawners:
		
		#Waiting until other layers are done being captured
		while capturing:
			await get_tree().process_frame
		
		#Starts generating a maze layer
		spawner.Start()
		count+=1
		
		#Waiting for generation to finish
		await spawner.done
		
		#Image of the maze is captured
		Capture(spawner)
		
		#Maps made with the captured images are added
		spawner.AddMaps(count)
		spawner.AddKey()
		if spawner == room_spawners[-1]:
			spawner.ReplaceLastWithDoor()

#Captures image of maze and saves it
func Capture(spawner):
	
	#Making sure only one layer is captured at a time
	capturing = true
	
	#Camera parameters based on maze size
	var width = spawner.size_x * 2
	var height = spawner.size_z * 2
	camera.size = max(width, height)
	camera.position.x = position.x + spawner.size_x/1.5
	camera.position.z = position.z + spawner.size_z/1.2
	camera.position.y += 5 * count
	
	#Viewport is updated to capture image
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	#Making sure viewport has time to capture 
	await get_tree().process_frame
	
	#Taking image from viewport and saving it
	var new_texture = ImageTexture.create_from_image(viewport.get_texture().get_image())
	var date = Time.get_date_string_from_system()
	var time = Time.get_time_string_from_system().replace(":", "_")
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("maps"):
		dir.make_dir("maps")
	var file_path = "user://maps/map"+str(count)+".png"
	viewport.get_texture().get_image().save_png(file_path)
	
	#Done capturing, next layer can proceed
	capturing = false
