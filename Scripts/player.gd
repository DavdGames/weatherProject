extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10

# : causes data type to be unchangable, whereat = is dynamic.
# hence it's more efficient to use : if not changing data types.
var xform : Transform3D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#vector3 direction taking into account the user arrow inputs and the arrow rotation
	var direction = ($camera_controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#rotat the character to align with the floor
	if is_on_floor() && input_dir != Vector2(0,0):
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.3)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
	#Updates velocity and moves the character
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	#make camera controller match the position of the player
	$camera_controller.position = lerp($camera_controller.position,position,0.05)
	
func align_with_floor(floor_normal):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
	
