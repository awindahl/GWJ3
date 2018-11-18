extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Page1_pressed():
	transition.fade_to("res://Saloon/Creditspage.tscn")


func _on_Page2_pressed():
	transition.fade_to("res://Saloon/Creditspage2.tscn")


func _on_Saloon_pressed():
	transition.fade_to("res://Saloon/SaloonGame.tscn")

