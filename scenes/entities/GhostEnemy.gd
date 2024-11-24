class_name GhostEnemy extends Enemy

var alpha_x:float = 0.0


func _ready():
	# Override parent variables here
	speed = 17
	sight_distance = 6 # in tiles
	sprite.modulate = Color(1, 1, 1, 0) # invisible


func state_sentry(_delta:float) -> void:
	# Can see through walls
	if current_tile_coords.distance_to(player.current_tile_coords) <= sight_distance \
	and sight_timer.is_stopped():
		state = STATES.CHASE


func state_chase(delta:float) -> void:
	# fluctuate transparency
	alpha_x += delta
	sprite.modulate = Color(1, 1, 1, cos(alpha_x+PI)+1)
	# approach player slowly, ignoring everything
	direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider == player:
			collider.hit(damage) # maybe put on a timer?


func handle_bloodvision() -> void:
	if Input.is_action_pressed("bloodvision"):
		sprite.hide() # OoOoOoOoO!!!
	else:
		sprite.show()
