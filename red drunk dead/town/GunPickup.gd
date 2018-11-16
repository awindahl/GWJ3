extends Spatial

func _on_Area_body_entered(body):
	if body.get("TYPE") == "PLAYER":
		print("you win!")