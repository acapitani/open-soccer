extends "res://scripts/state.gd"

var targets = []
var current_target = 0

func initialize(player):
	player.velocity = Vector2()
	var p1 = game.m.get_pitch_position("enterpitch")
	var p2 = game.m.get_pitch_position("start")
	if player.team==game.m.team_up:
		targets.append(Vector2(p1.x, p1.y-4))
		targets.append(Vector2(p2.x, p2.y-4))
		targets.append(Vector2(p2.x+24*player.id, p2.y-4))
	else:
		targets.append(Vector2(p1.x, p1.y+3))
		targets.append(Vector2(p2.x, p2.y+3))
		targets.append(Vector2(p2.x+24*player.id, p2.y+3))
	player.target = targets[current_target]
	player.move_timing_set(randf()*4)
	
func terminate(player):
	pass

func run(player, delta):
	if player.move_timing_elapsed():
		if player.move_to_target():
			current_target += 1
			if current_target>=len(targets):
				player.fsm.state_nxt = player.fsm.STATES.idle
			else:
				player.target = targets[current_target]
	player.anim_direction()
