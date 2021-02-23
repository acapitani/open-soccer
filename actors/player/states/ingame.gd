extends "res://scripts/state.gd"

var to_target = false

func initialize(player):
	player.anim_nxt = "idle"
	player.target = game.m.get_player_targetpos(player.team, player.id, game.m.get_ball().get_position())
	to_target = false
	
func terminate(player):
	pass

func run(player, delta ):
	if player.controlled:
		player.get_input()
		#get_joy()
		player.velocity = player.velocity.normalized() * player.speed
		player.velocity = player.move_and_slide(player.velocity)
		if player.has_ball:
			if player.actionA:
				player.do_shoot()
			elif player.actionB:
				player.do_pass()
		else:
			pass
	else:
		if player.move_to_target():
			if not to_target:
				to_target = true
				player.move_timing_set(0.5)
			elif player.move_timing_elapsed():
				to_target = false
				var newtarget = game.m.get_player_targetpos(player.team, player.id, game.m.get_ball().get_position())
				if game.m.get_sector(newtarget)!=game.m.get_sector(player.target):
					#if newtarget.distance_to(target)>32:
					player.target = newtarget
		if player.velocity.length()==0:
			player.direction_from_ball()
	player.anim_direction()
