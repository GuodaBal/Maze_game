extends Control

var current_page = 1
var max_pages = 0

#Possible fragment textures
@onready var fragment1 := $Fragment1 as TextureRect
@onready var fragment2 := $Fragment2 as TextureRect
@onready var fragment3 := $Fragment3 as TextureRect

#Displays which floor the map is for
@onready var floor_label := $RichTextLabel2 as RichTextLabel

#Pauses game and shows map
func _ready() -> void:
	get_tree().root.process_mode = Node.PROCESS_MODE_DISABLED
	GlobalVariables.map_open = true
	load_map()

#Loads map texture from the maps the player has collected
func load_map():
	floor_label.text = "Floor: " + str(current_page)
	fragment1.texture = null
	fragment2.texture = null
	fragment3.texture = null
	for fragment in GlobalVariables.map_fragments:
		#Makes sure the correct floor map is given
		var floor = int(fragment.get_slice("-", 0))
		if floor > max_pages:
			max_pages = floor
		if floor == current_page:
			var file_path = "user://maps/map"+str(current_page)+".png"
			var map_texture = ImageTexture.create_from_image(Image.load_from_file(file_path))
			#Chooses correct fragment texture
			if int(fragment.get_slice("-", 1)) == 1:
				fragment1.texture = map_texture
			if int(fragment.get_slice("-", 1)) == 2:
				fragment2.texture = map_texture
			if int(fragment.get_slice("-", 1)) == 3:
				fragment3.texture = map_texture
			Image.load_from_file(file_path)

func _input(event: InputEvent) -> void:
	#Switches floors/map pages
	if Input.is_action_just_pressed("next_page"):
		if current_page < max_pages:
			current_page += 1
			load_map()
	if Input.is_action_just_pressed("previous_page"):
		if current_page >= 2:
			current_page -= 1
			load_map()
	if Input.is_action_just_pressed("open_close_map"):
		#Needed so map can't be immediately opened when closed
		await get_tree().process_frame
		GlobalVariables.map_open = false
		get_tree().root.process_mode = Node.PROCESS_MODE_ALWAYS
		queue_free()
