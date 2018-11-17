extends Spatial

var playing = false

func _ready():
	randomize()

func _physics_process(delta):
	if $drink1.is_playing() || $drink2.is_playing():
		playing = true
	if !$drink1.is_playing() && !$drink2.is_playing() && playing:
		$glug.play()
		playing = !playing
func drink():
	var num = randi() % 2 + 1
	get_node("drink"+str(num)).play()