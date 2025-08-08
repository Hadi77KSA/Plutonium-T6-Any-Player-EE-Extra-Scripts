#include common_scripts\utility;
#include maps\mp\zm_buried_sq_ows;

main()
{
	replaceFunc( maps\mp\zm_buried_sq_ows::ows_target_delete_timer, ::ows_target_delete_timer, 1 );
	replaceFunc( maps\mp\zm_buried_sq_ows::ows_targets_start, ::ows_targets_start, 1 );
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
	flag_wait( "initial_players_connected" );
	self iPrintLn( "^3Any Player EE Mod ^5Buried Sharpshooter 3P" );
}

zmb_sq_target_flip()
{
	switch ( getPlayers().size )
	{
		case 1:
			level.zmb_sq_target_flip = 64; // Total (84) - ( Candy Shop (20) )
			break;
		case 2:
			level.zmb_sq_target_flip = 45; // Total (84) - ( Candy Shop (20) + Saloon (19) )
			break;
		case 3:
			level.zmb_sq_target_flip = 23; // Total (84) - ( Candy Shop (20) + Saloon (19) + Barn (22) )
			break;
		default: //All 4 areas of the map
			level.zmb_sq_target_flip = 0;
			break;
	}
}

ows_target_delete_timer()
{
	self endon( "death" );
	wait 4;
	self notify( "ows_target_timeout" );
	level.zmb_sq_target_flip--;

	if ( level.zmb_sq_target_flip < 0 || ( getPlayers().size == 3 && level.zmb_sq_target_flip > 4 && level.zmb_sq_target_flip < 23 ) ) //makes the step on 3p be optional between 3 locations and all locations.
		flag_set( "sq_ows_target_missed" );
	else if ( getPlayers().size == 3 && level.zmb_sq_target_flip >= 0 && level.zmb_sq_target_flip <= 4 ) //clears the flag in the case that the players choose to only shoot the targets from 3 locations instead of all.
		flag_clear( "sq_ows_target_missed" );

/#
	iprintlnbold( "missed target! step failed. target @ " + self.origin );
#/
}

ows_targets_start()
{
	n_cur_second = 0;
	flag_clear( "sq_ows_target_missed" );
	zmb_sq_target_flip();
	level thread sndsidequestowsmusic();
	a_sign_spots = getstructarray( "otw_target_spot", "script_noteworthy" );

	while ( n_cur_second < 40 )
	{
		a_spawn_spots = ows_targets_get_cur_spots( n_cur_second );

		if ( isdefined( a_spawn_spots ) && a_spawn_spots.size > 0 )
			ows_targets_spawn( a_spawn_spots );

		wait 1;
		n_cur_second++;
	}

	if ( !flag( "sq_ows_target_missed" ) )
	{
		flag_set( "sq_ows_success" );
		playsoundatposition( "zmb_sq_target_success", ( 0, 0, 0 ) );
	}
	else
		playsoundatposition( "zmb_sq_target_fail", ( 0, 0, 0 ) );

	level notify( "sndEndOWSMusic" );
}
