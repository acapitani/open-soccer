extends "res://scripts/state.gd"

func initialize(player):
	player.has_ball = false
	player.controlled = false
	player.visible = false
	player.position = Vector2(300,0)
	
func terminate(player):
	pass

func run(player, delta):
	pass
	