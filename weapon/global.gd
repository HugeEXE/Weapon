extends Node

# Stores the currently equipped BulletData resource profile
var active_bullet_profile: BulletData

func _ready():
	# If your file is in the main directory:
	active_bullet_profile = load("res://default_bullet.tres")
	
	# Verify it loaded successfully so it doesn't silent crash later
	if active_bullet_profile:
		print("Global AutoLoad: Default bullet profile initialized successfully!")
	else:
		print("Global AutoLoad ERROR: Could not find default bullet asset path!")
