class_name ShootEnemy extends Enemy

@onready var shoot_timer:Timer = $ShootTimer
@onready var shapecast:Area2D = $ShapeCast
@onready var shapecast_col:CollisionShape2D = $ShapeCast/CollisionShape2D
@onready var col:CollisionShape2D = $CollisionShape2D


func _ready():
	# Override parent variables
	hp = 1
	blood = 2.0
	speed = 20.0
	damage = 5.0
	sight_distance = 5
	col.shape.radius = 4


func state_chase(delta:float) -> void:
	# Chase player in order to find a shot
	if shapecast_to(player):
		if shoot_timer.is_stopped():
			get_parent().add_child(EnemyBullet.construct(
				self,
				global_position,
				global_position.direction_to(player.global_position),
				damage))
			shoot_timer.start()
	else:
		agent.set_target_position(player.global_position)
		direction = position.direction_to(agent.get_next_path_position())
		velocity = direction * speed
		agent.set_velocity(velocity)
		if not agent.is_navigation_finished():
			set_velocity(velocity)
			move_and_slide()
			velocity = velocity
			if abs(velocity.x) > 10 or abs(velocity.y) > 10:
				enemy_footstep_counter(delta)


func shapecast_to(target:Node2D) -> bool:
	# Stretches an Area2D to a given target to see if a bullet can hit it
	shapecast.global_position = global_position + ((target.global_position - global_position)/2)
	shapecast.rotation = global_position.angle_to_point(target.global_position)
	shapecast_col.shape.extents = Vector2(
		global_position.distance_to(target.global_position)/2,
		shapecast_col.shape.extents.y)
	var target_found:bool = false
	for body in shapecast.get_overlapping_bodies():
		if body is TileMap:
			return false # a wall is in the way
		if body == target:
			target_found = true
	return target_found
