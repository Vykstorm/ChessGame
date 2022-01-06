extends Node

func play(sound_name: String):
	var sound: AudioStreamPlayer  = get_node(sound_name)
	var stream: AudioStreamOGGVorbis = sound.stream
	stream.loop = false
	sound.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

