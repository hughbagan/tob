class_name EnemyBullet extends CharacterBody2D


const speed:float = 90.0
var creator:Node2D
var direction:Vector2
var damage:float


static func construct(_creator:Node2D, _position:Vector2, _direction:Vector2, _damage:float) -> EnemyBullet:
	var bullet_scene:Resource = load("res://scenes/entities/EnemyBullet.tscn")
	var new_bullet = bullet_scene.instantiate()
	new_bullet.creator = _creator
	new_bullet.global_position = _position
	new_bullet.direction = _direction # radians
	new_bullet.damage = _damage
	return new_bullet


func _physics_process(_delta:float) -> void:
	set_velocity(direction.normalized() * speed)
	move_and_slide()
	var cols = get_slide_collision_count()
	if cols > 0:
		for i in range(cols):
			var col = get_slide_collision(i).get_collider()
			if col is Player:
				col.hit(damage)
				queue_free()
			if col is TileMap:
				queue_free()
