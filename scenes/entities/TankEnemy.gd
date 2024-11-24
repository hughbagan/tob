class_name TankEnemy extends Enemy

@onready var shield:StaticBody2D = $Node2D/Shield
var shield_tween:Tween
var sheild_armlength:int = 5
var shield_targetpos:Vector2 = Vector2(0, sheild_armlength)


func _ready():
	# Override parent variables
	hp = 2
	blood = 6.0
	speed = 15.0
	sprite_shaded = $Node2D/SpriteShaded


func _on_ShieldTimer_timeout():
	# Put the shield in front of us so it blocks the Player's raycast attack
	shield_targetpos = direction * sheild_armlength
	if shield_tween:
		shield_tween.kill()
	shield_tween = self.create_tween()
	shield_tween.tween_property(shield, "position", shield_targetpos, 0.5)
