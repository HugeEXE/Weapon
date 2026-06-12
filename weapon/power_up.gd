extends Area2D
class_name PowerUpItem

# This lets you drop any custom BulletData resource profile here via the Inspector
@export var bullet_profile_to_give: BulletData

func _ready():
	# Connect the collision event to our handler function below
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Adjust "Player" to match the exact node name of your character scene
	if body.name == "Player" or body.has_method("is_player"):
		if bullet_profile_to_give:
			# Swap the global bullet renderer target instantly!
			Global.active_bullet_profile = bullet_profile_to_give
			print("Equipped Ammo Profile: ", bullet_profile_to_give.type_name)
		
		# Remove the item from the floor after pickup
		queue_free()
