extends Camera2D

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(0.1, 0.1) # Zoom In
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(0.1, 0.1) # Zoom Out
			
	# Prevent zooming out too far or becoming negative
	zoom = zoom.clamp(Vector2(0.5, 0.5), Vector2(5.0, 5.0))
