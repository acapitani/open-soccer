extends "res://scripts/state.gd"

var kicked = false

func initialize(player):
	kicked = false
	player.lastdir = Vector2(-1,0)
	player.direction = Vector2(-1,0)
		
	if game.m.get_team_mode(player.team)==game.PLAYER:
		player.controlled = true
	else:
		player.move_timing_set(2)
	player.anim_nxt = "run_left"
	
func terminate(player):
	pass

func run(player, delta):
	if kicked and player.move_timing_elapsed():
		player.fsm.state_nxt = player.fsm.STATES.ingame
	else:
		var kick = false
		if player.controlled:
			player.get_input()
			if player.actionB:
				kick = true
		elif player.move_timing_elapsed():
			kick = true
		if kick:
			# passa il pallone al compagno , alla sx
			# e cambia lo stato della scena in ingame
			player.do_kickoff()
			kicked = true
			player.move_timing_set(0.5)
	
