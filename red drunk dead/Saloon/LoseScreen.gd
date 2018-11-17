extends Node2D
func _ready():
	get_node("lose"+str(randi()%2+1)).play()