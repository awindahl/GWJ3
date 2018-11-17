extends Node2D
func _ready():
	get_node("win"+str(randi()%2+1)).play()