extends AudioStreamPlayer2D

const TRACK_LIST : Array[String] = [
	"res://assets/audio/music/ObservingTheStar.ogg",
	"res://assets/audio/music/through space.ogg",
]

enum Tracks {
	MainMenu = 0,
	Gameplay = 1,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus = "Music"
	play_track(Tracks.Gameplay)

func play_track(track : Tracks) -> void:
	self.stop()
	self.stream = load(TRACK_LIST[track])
	self.play()

func fade(track : Tracks) -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", -60, 2.0)
	tween.finished.connect(func(): 
		self.stop()
		volume_db = 0.0	
		play_track(track)
	)
