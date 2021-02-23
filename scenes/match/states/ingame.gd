extends "res://scripts/state.gd"

func initialize(scene):
	
	var v = Vector2(0,0)
	for i in range(1, scene.TEAM_PLAYERS):
		var p = scene.get_player(scene.TEAM_A, i)
		if p.fsm.state_cur!=p.fsm.STATES.kickoff:
			p.fsm.state_nxt = p.fsm.STATES.ingame
		
		p = scene.get_player(scene.TEAM_B, i)
		if p.fsm.state_cur!=p.fsm.STATES.kickoff:
			p.fsm.state_nxt = p.fsm.STATES.ingame
	
func terminate(scene):
	pass

func run(scene, delta ):
	# todo!!! verifico lo stato della palla
	# se la palla esce dal campo va in stato idle (transizione)
	if not scene.get_ball().is_ingame():
		print("CHANGE STATE")
		scene.fsm.state_nxt = scene.fsm.STATES.idle
		scene.idle_state_nxt = scene.fsm.STATES.kickoff
	else:
		var ball = scene.get_ball()
		if ball.status==ball.INGAME and ball.get_player()==null:
			var controlled_id = -1
			var p1 = scene.get_controlled_player(scene.TEAM_A)
			if p1!=null:
				controlled_id = p1.id
			var p2 = scene.get_nearest_player(scene.TEAM_A, ball.position)
			if p2.id!=p1.id:
				scene.set_controlled_player(scene.TEAM_A, p2.id)
			
			if false:
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
