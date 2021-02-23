extends "res://scripts/state.gd"

func initialize(scene):
	#team A
	var player
	for i in range(1, scene.TEAM_PLAYERS):
		#team A
		player = scene.get_player(scene.TEAM_A, i) 
		if player!=null:
			player.fsm.state_nxt = player.fsm.STATES.enterpitch
		#team B
		player = scene.get_player(scene.TEAM_B, i) 
		if player!=null:
			player.fsm.state_nxt = player.fsm.STATES.enterpitch
		

# warning-ignore:unused_argument
func terminate(scene):
	pass

var allidle = false
var wait_timer = 0

func run(scene, delta ):
	#todo!!! cambia stato (kickoff) se tutti i giocatori sono in stato idle da 2 secondi
	if allidle:
		wait_timer += delta
		if wait_timer>2.0:
			#scene.fsm.state_nxt = scene.fsm.STATES.leavepitch
			scene.fsm.state_nxt = scene.fsm.STATES.idle
			scene.idle_state_nxt = scene.fsm.STATES.kickoff
			scene.kickoff_team = scene.team_down
	else:
		allidle = true
		for i in range(1, scene.TEAM_PLAYERS):
			var player = scene.get_player(scene.TEAM_A, i)
			if player.fsm.state_cur!=player.fsm.STATES.idle:
				allidle = false
				break
			player = scene.get_player(scene.TEAM_B, i)
			if player.fsm.state_cur!=player.fsm.STATES.idle:
				allidle = false
				break
