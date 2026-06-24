extends CharacterBody3D

@export var acceleration : float = 15
@export var max_speed : float = 10
@export var deceleration : float = 20 # what happens when you let go... 

@export var start_turn_speed : float = 0.5
@export var max_turn_speed : float = 3
@export var turn_accel : float = 0.5
@export var drift_thres: float = 1
@export var drift_force: float = 1.1
@export var drift_bias: float = 0.8
@export var drift_friction: float = 15

var current_turn_angle : float = 0
var current_speed : float = 0
var current_turn_speed : float = 0
var initial_drift_angle: Vector3 = Vector3.ZERO;

const SPEED = 5.0



var turn_dir : float = 0 # -1 is left, 1 is right. 
var is_accelerate : bool
var is_break : bool
var is_drifting: bool

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
	var dir: Vector3 = global_transform.basis.z;
	if abs(turn_dir) > 0.01 and is_accelerate:
		current_turn_speed += turn_accel * delta
		current_turn_speed = clampf(current_turn_speed, start_turn_speed, max_turn_speed)
		current_turn_angle = turn_accel * -turn_dir;
		if (is_drifting && current_speed > drift_thres):
			# && current_speed > drift_thres
			current_turn_speed *= drift_force
			current_turn_angle = -turn_dir * delta * current_turn_speed;
			var basis_z = global_transform.basis.z
			
			dir = (initial_drift_angle*(drift_bias) + basis_z*(1-drift_bias)).normalized()
			current_speed -= drift_friction * delta
			rotate_y(current_turn_angle)
			
			# sliding_velocity = Vector3(sin(current_turn_angle), 0, cos(current_turn_angle))
		else:
			current_turn_angle = -turn_dir * delta * current_turn_speed
			initial_drift_angle = dir
			rotate_y(current_turn_angle)
	else:
		current_turn_angle = 0
			
	# apply speed.
	
	
	velocity = dir*current_speed
	move_and_slide()

func update_input():
	turn_dir = Input.get_axis("left", "right")
	is_accelerate = Input.is_action_pressed("accelerate")
	is_break = Input.is_action_pressed("break")
	is_drifting = Input.is_action_pressed("drift")
