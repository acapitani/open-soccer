extends "res://scripts/state.gd"

var targets = []
var current_target = 0

func initialize(player):
	var p1 = game.m.get_pitch_position("start")
	var p2 = game.m.get_pitch_position("enterpitch")
	var p3 = game.m.get_pitch_position("middlefield")
	if player.team==game.m.team_up:
		player.position = Vector2(p1.x+8*player.id, p1.y-4)
		targets.append(Vector2(p1.x, p1.y-4))
		targets.append(Vector2(p2.x, p2.y-4))
		if game.m.match_time==game.m.FIRST_HALF:
			targets.append(Vector2(p3.x, p2.y+(-(player.id+1)*4)))
	else:
		player.position = Vector2(p1.x+8*player.id, p1.y+3)
		targets.append(Vector2(p1.x, p1.y+3))
		targets.append(Vector2(p2.x, p2.y+4))
		if game.m.match_time==game.m.FIRST_HALF:
			targets.append(Vector2(p3.x, p2.y+(player.id+1)*4))
	#targets.append(pp[player.id-1])
	if game.m.match_time!=game.m.FIRST_HALF:
		targets.append(game.m.get_player_startpos(player.team, player.id))
	player.target = targets[current_target]
	
func terminate(player):
	pass

func run(player, delta):
	if player.move_to_target():
		current_target += 1
		if current_target>=len(targets):
			player.fsm.state_nxt = player.fsm.STATES.idle
		else:
			player.target = targets[current_target]
	player.anim_direction()
