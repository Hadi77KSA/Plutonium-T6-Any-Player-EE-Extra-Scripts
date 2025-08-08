#include common_scripts\utility;
#include maps\mp\zm_buried_sq_ip;

main()
{
	replaceFunc( maps\mp\zm_buried_sq_ip::sq_ml_puzzle_logic, ::sq_ml_puzzle_logic );
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
	self iPrintLn( "^3Any Player EE Mod ^5Buried Richtofen Maze Lever Sparks" );
}

sq_ml_puzzle_logic()
{
	a_levers = getentarray( "sq_ml_lever", "targetname" );
	level.sq_ml_curr_lever = 0;
	a_levers = array_randomize( a_levers );

	for ( i = 0; i < a_levers.size; i++ )
		a_levers[i].n_lever_order = i;

	while ( true )
	{
		level.sq_ml_curr_lever = 0;
		sq_ml_puzzle_wait_for_levers();
		n_correct = 0;

		foreach ( m_lever in a_levers )
		{
			lever_flipped_in_position = m_lever.n_flip_number + 1;

			if ( m_lever.n_flip_number == m_lever.n_lever_order )
			{
				playfxontag( level._effect["sq_spark"], m_lever, "tag_origin" );
				n_correct++;
				m_lever playsound( "zmb_sq_maze_correct_spark" );
				AllClientsPrint( "Lever flipped in position " + lever_flipped_in_position + ": ^3Spark" );
			}
			else
				AllClientsPrint( "Lever flipped in position " + lever_flipped_in_position + ": No Spark" );
		}

/#
		iprintlnbold( "Levers Correct: " + n_correct );
#/

		if ( n_correct == a_levers.size )
			flag_set( "sq_ip_puzzle_complete" );

		level waittill( "zm_buried_maze_changed" );
		level notify( "sq_ml_reset_levers" );
		wait 1;
	}
}
