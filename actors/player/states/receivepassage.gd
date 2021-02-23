extends "res://scripts/state.gd"

func initialize(player):
	pass
		
func terminate(player):
	pass

func run(player, delta ):
	if player.has_ball or player.controlled or game.m.get_ball().get_player()!=null:
		player.fsm.state_nxt = player.fsm.STATES.ingame
	else:
		player.target = game.m.get_ball_position()
		player.move_to_target()
		player.anim_direction()
