shader_type canvas_item;

uniform vec4 team1_color1;
uniform vec4 team1_color2;
uniform vec4 team1_color3;

uniform vec4 team2_color1;
uniform vec4 team2_color2;
uniform vec4 team2_color3;

uniform vec4 goalkeeper_color1;
uniform vec4 goalkeeper_color2;

void fragment() 
{
    vec4 col = texture(TEXTURE, UV).rgba;
	// TEAM A
	if (team1_color1.a>0.0)
	{	
		if ((col.r>0.39&&col.r<0.41)&&(col.g==0.0)&&(col.b==0.0)&&(col.a==1.0))
		{
			col = team1_color1;
		}
	}
	if (team1_color2.a>0.0)
	{
		if ((col.r>0.58&&col.r<0.60)&&(col.g==0.0)&&(col.b==0.0)&&(col.a==1.0))
		{
			col = team1_color2;
		}
	}
	if (team1_color3.a>0.0)
	{
		if ((col.r>0.14&&col.r<0.15)&&(col.g>0.18&&col.g<0.19)&&(col.b>0.67&&col.r<0.68)&&(col.a==1.0))
		{
			col = team1_color3;
		}
	}
	// TEAM B
	if (team2_color1.a>0.0)
	{	
		if ((col.r==0.0)&&(col.g>0.29&&col.g<0.31)&&(col.b>0.53&&col.b<0.55)&&(col.a==1.0))
		{
			col = team2_color1;
		}
	}
	if (team2_color2.a>0.0)
	{
		if ((col.r==0.0)&&(col.g>0.37&&col.g<0.39)&&(col.b>0.67&&col.b<0.69)&&(col.a==1.0))
		{
			col = team2_color2;
		}
	}
	if (team2_color3.a>0.0)
	{
		if ((col.r>0.06&&col.r<0.08)&&(col.g==0.0)&&(col.b>0.57&&col.b<0.59)&&(col.a==1.0))
		{
			col = team2_color3;
		}
	}
	COLOR = col;
}