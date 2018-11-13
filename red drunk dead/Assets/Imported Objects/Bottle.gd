extends Spatial

func _on_Area_body_entered(body):
	if body.get("TYPE") == "PLAYER":
		body.Drunkeness += 10
		body.Health += 10
		queue_free()