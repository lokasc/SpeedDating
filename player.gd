extends CharacterBody3D

@export var acceleration : float = 15
@export var max_speed : float = 10
@export var deceleration : float = 20 # what happens when you let go... 

@export var start_turn_speed : float = 0.5
@export var max_turn_speed : float = 3
@export var turn_accel : float = 0.5

var current_turn_angle : float = 0
var current_speed : float = 0
var current_turn_speed : float = 0

const SPEED = 5.0



var turn_dir : float = 0 # -1 is left, 1 is right. 
var is_accelerate : bool
var is_break : bool

func _physics_process(delta: float) -> void:
	update_input()
	
	if is_accelerate: # acceleration
		current_speed += acceleration * delta
		current_speed = clampf(current_speed, 0, max_speed)
	elif is_break: # breaking!
		current_speed -= deceleration * delta
	else: # go to 0
		current_speed = lerp(current_speed, 0.0, deceleration * delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# turning
	if turn_dir != 0:
		current_turn_speed += turn_accel * delta
		clampf(current_turn_speed, start_turn_speed, max_turn_speed)
		current_turn_angle = -turn_dir * delta * current_turn_speed
		# clampf(current_turn_angle, -max_turn_angle, max_turn_angle)
		rotate_y(current_turn_angle)
			
		pass
	else:
		current_turn_speed = 0
	

	# apply speed.
	var forward_dir = global_transform.basis.z
	velocity = forward_dir * current_speed
	move_and_slide()

func update_input():
	turn_dir = Input.get_axis("left", "right")
	is_accelerate = Input.is_action_pressed("accelerate")
	is_break = Input.is_action_pressed("break")
