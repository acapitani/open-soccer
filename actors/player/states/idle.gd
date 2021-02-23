extends "res://scripts/state.gd"

func initialize(player):
	var r = randi()%3
	match r:
		0:
			player.anim_nxt = "idle"
		1: 
			player.anim_nxt = "idle2"
		2:
			player.anim_nxt = "idle3"
	player.controlled = false
	player.has_ball = false
	
func terminate(player):
	pass

func run(player, delta):
	pass
