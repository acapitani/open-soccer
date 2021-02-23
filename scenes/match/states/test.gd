extends "res://scripts/state.gd"

func initialize(scene):
	
	var v = Vector2(0,0)
	for i in range(1, scene.TEAM_PLAYERS):
		var p = scene.get_player(scene.TEAM_A, i)
		p.visible = true
		p.controlled = false
		p.has_ball = false
		p.position = game.m.get_player_startpos(p.team, p.id)
		p.target = game.m.get_player_targetpos(p.team, p.id, v)
		p.fsm.state_nxt = p.fsm.STATES.ingame
		
		p = scene.get_player(scene.TEAM_B, i)
		#p.visible = true
		#p.position = game.m.get_player_startpos(p.team, p.id)
		p.fsm.state_nxt = p.fsm.STATES.outofgame
		#p.target = game.m.get_player_targetpos(p.team, p.id, v)
		
	#scene.get_ball().reset(Vector2(0,0), true)
	
	var player = scene.get_player(scene.TEAM_A, 1)
	scene.set_controlled_player(scene.TEAM_A, 1)
	
	var ball = scene.get_ball()
	#ball.reset(Vector2(0,0), true)
	ball.attach_player(player)
	
func terminate(scene):
	pass

func run(scene, delta ):
	# todo!!! verifico lo stato della palla
	# se la palla esce dal campo va in stato idle (transizione)
	if not scene.get_ball().is_ingame():
		print("CHANGE STATE")
		scene.fsm.state_nxt = scene.fsm.STATES.idle
		scene.idle_state_nxt = scene.fsm.STATES.test
	else:
		var ball = scene.get_ball()
		if ball.status==ball.INGAME and ball.get_player()==null:
			#setta il controller al giocatore più vicino al pallone
			var dist = 1000.0
			var id = 1
			var old_id = -1
			for i in range(1, scene.TEAM_PLAYERS):
				if scene.get_player(scene.TEAM_A, i).controlled:
					old_id = i
					break
					
					
			if old_id==-1:
				var b = 0
			
			for i in range(1, scene.TEAM_PLAYERS):
				var d = scene.get_player(scene.TEAM_A, i).position.distance_to(ball.position)
				if d<dist:
					dist = d
					id = i
			if id!=old_id:
				#scene.set_controlled_player(scene.TEAM_A, id)
				pass
		pass
