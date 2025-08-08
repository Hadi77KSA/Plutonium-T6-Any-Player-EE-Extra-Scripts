#include maps\mp\zm_buried_sq_ip;

main()
{
	replaceFunc( maps\mp\zm_buried_sq_ip::sq_bp_set_current_bulb, ::sq_bp_set_current_bulb, 1 );
}

init()
{
	thread onPlayerConnect();
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
	self iPrintLn( "^3Any Player EE Mod ^5Buried Maxis Solo Bells Auto-Complete" );
}

sq_bp_set_current_bulb( str_tag )
{
	level endon( "sq_bp_correct_button" );
	level endon( "sq_bp_wrong_button" );
	level endon( "sq_bp_timeout" );

	if ( isdefined( level.m_sq_bp_active_light ) )
		level.str_sq_bp_active_light = "";

	level.m_sq_bp_active_light = sq_bp_light_on( str_tag, "yellow" );
	level.str_sq_bp_active_light = str_tag;

	if ( getPlayers().size == 1 )
	{
		wait 1;
		sq_bp_light_on( str_tag, "green" );
		level notify( "sq_bp_correct_button" );
	}

	if ( getPlayers().size > 2 )
	{
		wait 10;
		level notify( "sq_bp_timeout" );
	}
}
