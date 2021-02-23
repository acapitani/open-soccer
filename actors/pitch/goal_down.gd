extends Node2D

func _ready():
	pass # Replace with function body.

func interact_with_ball(ball, area):
	var net_bounce = 0.1
	var post_bounce = 0.9
	
	var ok = false
	var bp = ball.global_position
	var pos = area.global_position
	if ball.H<=2.7:
		ok = true
		if area==$post_sx or area==$post_dx:
			ball.reflect(Vector2(0,-1), post_bounce)
			print("post hit")
		elif area==$back:
			#print("$back")
			if round(bp.y)<=pos.y:
				ball.reflect(Vector2(0,-1), net_bounce)
			else:
				ball.reflect(Vector2(0,1), net_bounce)
		elif area==$left:
			if round(bp.x)>=pos.x:
				ball.reflect(Vector2(1,0), net_bounce)
			else:
				ball.reflect(Vector2(-1,0), net_bounce)
		elif area==$right:
			if round(bp.x)<=pos.x:
				ball.reflect(Vector2(-1,0), net_bounce)
			else:
				ball.reflect(Vector2(1,0), net_bounce)
		elif area==$crossbar and ball.H>=2.4 and ball.H<=2.7:
			print("crossbar hit")
			ball.reflect(Vector2(0,-1), post_bounce)
		elif area==$goal_area:
			ball.limit_H = 2.0
			if ball.status!=ball.INGOAL and ball.status!=ball.ISOUT:
				ball.status = ball.INGOAL
				print("GOAL: x "+ str(ball.global_position.x) + " y " + str(ball.global_position.y))
		else:
			ok = false
		return ok

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
