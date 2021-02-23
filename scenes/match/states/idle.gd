extends "res://scripts/state.gd"

func initialize(scene):
	scene.fade_out()
	
func terminate(scene):
	scene.fade_in()

func run(scene, delta ):
	pass
	