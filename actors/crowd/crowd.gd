extends Node2D

export (int) var pos = 0	# 0 = up, 1 = right, 2 = left, 3 = down

# Called when the node enters the scene tree for the first time.
func _ready():
	var animations = ["crowd_up", "crowd_right", "crowd_left", "crowd_down"]
	$anim.play(animations[pos])
