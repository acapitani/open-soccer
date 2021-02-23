extends "res://scripts/state.gd"

func initialize(scene):
	var player
	for i in range(1, scene.TEAM_PLAYERS):
		#team A
		player = scene.get_player(scene.TEAM_A, i) 
		if player!=null:
			player.fsm.state_nxt = player.fsm.STATES.leavepitch
		#team B
		player = scene.get_player(scene.TEAM_B, i) 
		if player!=null:
			player.fsm.state_nxt = player.fsm.STATES.leavepitch
		

func terminate(scene):
	pass

func run(scene, delta ):
	pass
