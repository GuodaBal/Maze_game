extends CharacterBody3D

#Movement parameters
@export var speed = 3
@export var jump_strength = 3
@export var climb_speed = 2
@export var gravity = 9.8
var target_velocity = Vector3.ZERO

#Camera and neck so the player can look around
@onready var neck = $Neck as Node3D
@onready var camera = $Neck/Camera3D as Camera3D

#Raycast to check what the player is looking at
@onready var interactable_detection = $Neck/Camera3D/RayCast3D as RayCast3D
#Interactable item player is currently looking at
var current_interactable = null

#Whether player is climbing vines 
var is_climbing = false

func _physics_process(delta: float) -> void:
	#Input direction binding
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Horizontal movement
	if direction:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	else:
		target_velocity.x = move_toward(velocity.x, 0, speed)
		target_velocity.z = move_toward(velocity.z, 0, speed)

	# Vertical movement
	if is_climbing:
		target_velocity.y = 0
		if Input.is_action_pressed("jump"):
			target_velocity.y += climb_speed
		elif Input.is_action_pressed("move_down"):
			target_velocity.y -= climb_speed
	else:
		if is_on_floor():
			target_velocity.y = 0
			if Input.is_action_just_pressed("jump"):
				target_velocity.y = jump_strength
		else:
			target_velocity.y -= gravity * delta
	
	#Movement applied
	velocity = target_velocity
	move_and_slide()
	
	#Checking if player is looking at interactable object
	if interactable_detection.is_colliding():
		var collider = interactable_detection.get_collider()
		if collider:
			var object = interactable_detection.get_collider().owner
			#If player is looking at a new object, the last prompt is removed
			if current_interactable && current_interactable != object && current_interactable.has_method("RemovePrompt"):
					current_interactable.RemovePrompt()
			#If player is looking at an interactable object, the objects prompt is shown
			if object.is_in_group("interactable") && object.has_method("Prompt"):
				current_interactable = object
				object.Prompt()
	#If player is looking at nothing, the last prompt is removed
	elif current_interactable:
		if current_interactable.has_method("RemovePrompt"):
			current_interactable.RemovePrompt()
	

func _input(event: InputEvent) -> void:
	
	#Switching mouse capture mode
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#Moving camera with mouse
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_y(-event.relative.x * 0.01)
		camera.rotate_x(-event.relative.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	#If mouse is clicked, checks if player is looking at an interactable object and interacts
	if Input.is_action_just_pressed("click"):
		if current_interactable && current_interactable.has_method("Interact"):
				current_interactable.Interact()
	
	#If player is looking at a surface and has flowers, they can place a flower
	if Input.is_action_just_pressed("place_flower") && GlobalVariables.flower_amount > 0:
		if interactable_detection.is_colliding():
			if !interactable_detection.get_collider().owner.is_in_group("interactable"):
				var location = interactable_detection.get_collision_point()
				var flower = preload("res://interactable_objects/single_flower.tscn").instantiate()
				get_parent().add_child(flower)
				flower.global_position = location
				flower.look_at(position)
				GlobalVariables.flower_amount -= 1
				SignalBus.flower_count_changed.emit()
	#Opening map
	if Input.is_action_just_pressed("open_close_map") && !GlobalVariables.map_open:
		var map = preload("res://ui/maps.tscn").instantiate()
		get_parent().add_child(map)

#Change climbing state
func CanClimb(state):
	is_climbing = state
