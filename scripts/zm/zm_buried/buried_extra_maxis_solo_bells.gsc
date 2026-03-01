#include common_scripts\utility;
#include maps\mp\zm_buried_sq_ip;

init()
{
	thread onPlayerConnect();
	thread sq_bp_start_puzzle_lights();
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
	flag_wait( "initial_players_connected" );
	self iPrintLn( "^3Any Player EE Mod ^5Buried Maxis Solo Bells Auto-Complete" );
}

sq_bp_start_puzzle_lights()
{
	level endon( "sq_ip_over" );
	level waittill( "sq" + "_" + "ip" + "_started" );

	if ( flag( "sq_is_max_tower_built" ) )
	{
		while ( !flag( "sq_ip_puzzle_complete" ) )
		{
			while ( !isdefined( level.t_start ) )
			{
				wait 0.05;
			}

			level.t_start waittill( "trigger" );
			wait 0.1;
			sq_bp_button_pressed();
		}
	}
}

sq_bp_button_pressed()
{
	level endon( "sq_ip_over" );
	level endon( "sq_bp_wrong_button" );
	level endon( "sq_bp_timeout" );

	if ( level.players.size == 1 )
	{
		for (;;)
		{
			wait 1;
			sq_bp_light_on( level.str_sq_bp_active_light, "green" );
			level notify( "sq_bp_correct_button" );
		}
	}
}
