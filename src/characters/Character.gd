extends CharacterBody2D

enum State { Idle , Run , Jump , Fall }

var current_state

var previous_pos: Vector2
var current_pos: Vector2

const SPEED = 400.0
const JUMP_VELOCITY = -400.0

var jump_count = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# When falling
	if not is_on_floor():
		velocity.y += gravity * delta
		previous_pos = current_pos
		current_pos = Vector2(position.x, position.y)
	
	# When jumping
	if Input.is_action_just_pressed("jump") && jump_count < 1:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	
	# Reset jump count
	if is_on_floor():
			jump_count = 0
	
	# Moving left and right
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		match direction:
			1.0:
				$AnimatedSprite2D.flip_h = false
			-1.0:
				$AnimatedSprite2D.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	# Running
	if (velocity.x > 0 || velocity.x < 0) && velocity.y == 0:
		current_state = State.Run
	elif (velocity.y < 0):
		current_state = State.Jump
	elif (velocity.y > 0):
		current_state = State.Fall
	else:
		current_state = State.Idle
	
	player_animations()

func player_animations() -> void:
		if current_state == State.Idle:
			$AnimatedSprite2D.animation = "idle"
		elif current_state == State.Run:
			$AnimatedSprite2D.animation = "running"
		elif current_state == State.Jump:
			if jump_count < 1:
				$AnimatedSprite2D.animation = "jumping"
			else:
				$AnimatedSprite2D.animation = "double_jumping"
		elif current_state == State.Fall:
			$AnimatedSprite2D.animation = "falling"
