init()
{
	thread onPlayerConnect();
	thread richtofen_sidequest_c();
	thread screecher_light_on_sq();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread msg();
	}
}

msg()
{
	self endon( "disconnect" );
	common_scripts\utility::flag_wait( "initial_players_connected" );
	self iPrintLn( "^3Any Player EE Mod ^5TranZit Richtofen Solo" );
}

richtofen_sidequest_c()
{
	for (;;)
	{
		level waittill( "safety_light_power_off" );
		thread safety_light_power_off();
	}
}

screecher_light_on_sq()
{
	for (;;)
	{
		level waittill( "safety_light_power_on" );
		thread safety_light_power_on();
	}
}

safety_light_power_off()
{
	waittillframeend;

	if ( getPlayers().size == 1 && level.sq_progress["rich"]["C_screecher_light"] == 1 )
		level.sq_progress["rich"]["C_screecher_light"] += 2;
}

safety_light_power_on()
{
	waittillframeend;

	if ( getPlayers().size == 1 && level.sq_progress["rich"]["C_screecher_light"] == 1 )
		level.sq_progress["rich"]["C_screecher_light"]++;
}
