extends Node3D

#Maze size
@export var size_x = 10
@export var size_z = 10

#Room used as a cell
@onready var room = preload("res://hex_room.tscn")

#All rooms with their coordinates
var all_rooms := {} as Dictionary

#Spawn chance of different events
@export var remove_floor_chance = 0.1
@export var flower_spawn_chance = 0.1
@export var bush_spawn_chance = 0.3
@export var fireflies_spawn_chance = 0.3

#Signal that's released when maze is done generating
signal done

#Executes the flow of the generation
func Start() -> void:
	#Adding a grid of rooms
	for x in size_x:
		for z in size_z:
			var instance = room.instantiate()
			if x % 2 == 0:
				instance.position = Vector3(x * 1.5, 0, z * 1.75)
			else:
				instance.position = Vector3(x * 1.5, 0, z * 1.75 + 0.875)
			add_child(instance)
			all_rooms[Vector2i(x,z)] = instance
	
	#Starts recursive maze path generation
	GenerateMaze(null, all_rooms[Vector2i(0,0)])
	
	#Making sure all walls in queue_free are removed before items are added (some are on walls)
	await get_tree().process_frame
	
	#Adding items randomly
	for x in size_x:
		for z in size_z:
			if randf() < remove_floor_chance:
				all_rooms[Vector2i(x,z)].RemoveFloor()
				all_rooms[Vector2i(x,z)].AddVines()
			elif randf() < flower_spawn_chance:
				all_rooms[Vector2i(x,z)].AddFlowers()
			if randf() < bush_spawn_chance:
				all_rooms[Vector2i(x,z)].AddBush()
			if randf() < fireflies_spawn_chance:
				all_rooms[Vector2i(x,z)].AddFireflies()
	
	#Once generation is finished, signal is emitted
	print_debug("done")
	done.emit()

#Maze is generated with a recursive method using depth-first search
func GenerateMaze(last_room, current_room):
	
	current_room.Visit()
	
	ClearWallInbetween(last_room, current_room)
	
	var neighbors = GetUnvisitedNeighbors(current_room)
	neighbors.shuffle()
	
	#Recursively visiting every unvisited neighbour in a random order
	for next_room in neighbors:
		if !next_room.is_visited:
			GenerateMaze(current_room, next_room)

# Gets all unvisited neighbors of the current room
func GetUnvisitedNeighbors(current_room):
	var current_pos = all_rooms.find_key(current_room)
	var neighbors = []
	
	#All possible directions in which a room could be, depending on column offset
	var directions
	if current_pos.x % 2 == 0:
		directions = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0), Vector2i(1,-1), Vector2i(-1,-1)]
	else:
		directions = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,1), Vector2i(-1,0), Vector2i(1,0)]
	for direction in directions:
		var pos = current_pos + direction
		if all_rooms.has(pos) && !all_rooms[pos].is_visited:
			neighbors.append(all_rooms[pos])
	return neighbors

# Removes a wall inbetween two rooms
func ClearWallInbetween(room1, room2):
	# If a room doesn't exist, return
	if not room1 or not room2:
		return
	
	#Depending on position of the rooms, the wall inbetween them is found and removed
	var diff = room2.position - room1.position
	
	if diff.x > 0.5 && diff.z > 0.5:
		room1.RemoveNorthWestWall()
		room2.RemoveSouthEastWall()
	elif diff.x > 0.5 && diff.z < -0.5:
		room1.RemoveSouthWestWall()
		room2.RemoveNorthEastWall()
	elif diff.x < -0.5 && diff.z > 0.5:
		room1.RemoveNorthEastWall()
		room2.RemoveSouthWestWall()
	elif diff.x < -0.5 && diff.z < -0.5:
		room1.RemoveSouthEastWall()
		room2.RemoveNorthWestWall()
	elif diff.z > 0.5:
		room1.RemoveNorthWall()
		room2.RemoveSouthWall()
	elif diff.z < -0.5:
		room1.RemoveSouthWall()
		room2.RemoveNorthWall()

#Adds map fragments throughout the maze
func AddMaps(floor):
	
	var dead_ends = []
	var corridors = []
	
	#Making sure queue is freed so needed floors are removed
	await get_tree().process_frame
	#Finding dead ends and corridors
	for room in get_children():
		if room.has_method("GetWallCount"):
			if room.GetWallCount() == 5 && room.floor:
				dead_ends.append(room)
			elif room.GetWallCount() == 4 && room.floor:
				corridors.append(room)
	
	dead_ends.shuffle()
	corridors.shuffle()
	
	#Making 3 fragments in total
	var maps = 3
	while maps > 0:
		#Looking for a room to place in
		#Dead ends are prioritized, and if there's not enough, corridors are used
		var room
		if dead_ends.size() > 0:
			room = dead_ends[0]
			dead_ends.pop_front()
		else:
			room = corridors[0]
			corridors.pop_front()
		room.AddMap(floor, maps)
		maps-=1

#Places a key at a random dead end
func AddKey():
	var dead_ends = []
	var all = []
	
	#Making sure queue is freed so needed floors are removed
	await get_tree().process_frame
	
	#Finding dead ends
	for room in get_children():
		if room.has_method("GetWallCount"):
			if room.GetWallCount() == 5 && room.floor:
				dead_ends.append(room)
			elif room.floor:
				all.append(room)
	
	if dead_ends.size() > 0:
		dead_ends.pick_random().AddKey()
	else:
		all.pick_random().AddKey()
	
func ReplaceLastWithDoor():
	all_rooms[Vector2i(size_x-1, size_z-1)].AddDoor()

#Floor rotation test - was not implemented
#func rotate_grid_around_center():
	#var maze_size = Vector3((size_x - 1) * 1.5, 0, (size_z - 1) * 1.75 + 0.875)
#
	##for child in get_children():
		##if child is Node2D:
			##child.position -= pivot_point
#
	##position -= pivot_point
	#var current_tween : Tween
	#if current_tween and current_tween.is_valid():
		#current_tween.kill()
#
	#current_tween = create_tween()
	#current_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	#current_tween.set_parallel(true)
#
	#if quaternion.y == 1:
		#var goal = Quaternion(0.0, 0.0, 0.0, 1.0)
		#current_tween.tween_property(
			#self,
			#"quaternion",
			#goal,
			#10.0 # Animation duration in seconds
		#)
	#else:
		#var goal = Quaternion(0.0, 1.0, 0.0, 0.0)
		#current_tween.tween_property(
			#self,
			#"quaternion",
			#goal,
			#10.0 # Animation duration in seconds
		#)
	#if position.x > 0:
		#current_tween.tween_property(
			#self,
			#"position",
			#position -maze_size,
			#5.0
		#)
	#else:
		#current_tween.tween_property(
			#self,
			#"position",
			#position + maze_size,
			#5.0
		#)
	#current_tween.play()
#
#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("jump") && position.y > 0:
		#rotate_grid_around_center()
