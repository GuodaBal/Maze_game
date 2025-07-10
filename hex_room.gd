extends Node3D

#Walls and floor
@onready var north_wall = $NorthWall
@onready var south_wall = $SouthWall
@onready var north_east_wall = $NorthEastWall
@onready var north_west_wall = $NorthWestWall
@onready var south_east_wall = $SouthEastWall
@onready var south_west_wall = $SouthWestWall
@onready var floor = $Floor

#Whether room has been visited by the maze generator
var is_visited = false

#Wall removal
func RemoveNorthWall():
	if north_wall:
		north_wall.queue_free()
func RemoveSouthWall():
	if south_wall:
		south_wall.queue_free()
func RemoveNorthEastWall():
	if north_east_wall:
		north_east_wall.queue_free()
func RemoveNorthWestWall():
	if north_west_wall:
		north_west_wall.queue_free()
func RemoveSouthWestWall():
	if south_west_wall:
		south_west_wall.queue_free()
func RemoveSouthEastWall():
	if south_east_wall:
		south_east_wall.queue_free()
func RemoveFloor():
	if floor:
		print_debug("removing")
		floor.queue_free()
	else:
		print_debug("already removed")

#Visit state change
func Visit():
	is_visited = true

#Decor and interactable object addition
func AddVines():
	var walls = [north_wall, south_wall, north_east_wall, north_west_wall, south_east_wall, south_west_wall]
	walls.shuffle()
	for wall in walls:
		if wall:
			var vines = preload("res://interactable_objects/climable_vines.tscn").instantiate()
			vines.rotation = wall.rotation * 4
			vines.position.y = -1
			add_child(vines)
			break

func AddKey():
	var key = preload("res://interactable_objects/key.tscn").instantiate()
	add_child(key)
	key.position += Vector3(randf(), 0, randf()).normalized() * 0.5

func AddFlowers():
	if floor:
		var flowers = preload("res://interactable_objects/pickable_flowers.tscn").instantiate()
		add_child(flowers)
		flowers.position += Vector3(randf(), 0, randf()).normalized() * 0.5

func AddBush():
	var walls = [north_wall, south_wall, north_east_wall, north_west_wall, south_east_wall, south_west_wall]
	walls.shuffle()
	for wall in walls:
		if wall:
			var bush = preload("res://3d_models/hedge.tscn").instantiate()
			bush.position.x = wall.position.x * 0.8
			bush.position.z = wall.position.z * 0.8
			bush.rotation = wall.rotation * 4
			add_child(bush)
			break

func AddFireflies():
	var fireflies = preload("res://fireflies.tscn").instantiate()
	add_child(fireflies)

func AddMap(floor, fragment):
	var map = preload("res://interactable_objects/map_fragment.tscn").instantiate()
	add_child(map)
	map.position.y += 0.02
	map.Generate(floor, fragment)

func AddDoor():
	var door = preload("res://interactable_objects/locked_door.tscn").instantiate()
	add_child(door)
	door.position.x = north_wall.position.x
	door.position.z = north_wall.position.z
	RemoveNorthWall()

#Returns amount of walls still up
func GetWallCount():
	var count = 0
	var walls = [north_wall, south_wall, north_east_wall, north_west_wall, south_east_wall, south_west_wall]
	for wall in walls:
		if wall:
			count += 1
	return count
