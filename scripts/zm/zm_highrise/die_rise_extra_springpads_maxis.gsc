#include common_scripts\utility;
#include maps\mp\zm_highrise_sq_pts;
#include maps\mp\zombies\_zm_equip_springpad;
#include maps\mp\zombies\_zm_utility;

main()
{
	replaceFunc( ::cleanupoldspringpad, ::custom_cleanupoldspringpad );
	replaceFunc( ::pts_springpad_waittill_removed, ::custom_pts_springpad_waittill_removed );
}

init()
{
	level thread custom_ignore_springpads_during_pts_2();
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread display_mod_message();
		player thread equipment_placed_listen();
		player thread onPlayerDisconnect();
	}
}

display_mod_message()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iPrintLn( "^3Any Player EE Mod ^5Die Rise Maxis Extra Trample Steams" );
}

onPlayerDisconnect()
{
	level endon( "end_game" );
	self waittill( "disconnect" );
	level thread refresh_players_springpads();
}

//makes zombies ignore Trample Steams placed during Maxis Trample Steam step if number of players was less than 4 when the Ballistic Knife step was completed
custom_ignore_springpads_during_pts_2()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );

	if ( flag( "sq_branch_complete" ) || is_true( level.maxcompleted ) )
		return;

	level waittill( "sq_2_ssp_2_over" );

	if ( getPlayers().size < 4 )
		maps\mp\zombies\_zm_equipment::enemies_ignore_equipment( level.springpad_name );

	level waittill( "sq_2_pts_2_over" );
	arrayRemoveValue( level.equipment_ignored_by_zombies, level.springpad_name );
}

equipment_placed_listen()
{
	level endon( "end_game" );
	self endon( "disconnect" );

	while ( !flag( "sq_branch_complete" ) )
	{
		self waittill( "equipment_placed", weapon, weapname );

		if ( weapname == level.springpad_name )
			self custom_quick_release();
	}
}

//after the player places down a Trample Steam during the Maxis Trample Steam step while there are less than 4 players and depending on if not enough Trample Steams were on symbols and in inventories, gives the player the ability to pick up a new Trample Steam
custom_quick_release()
{
	if ( getPlayers().size >= 4 || flag( "sq_branch_complete" ) || is_true( level.maxcompleted ) || !is_true( level._zombie_sidequests[ "sq_2" ].stages[ "ssp_2" ].completed ) || is_true( level._zombie_sidequests[ "sq_2" ].stages[ "pts_2" ].completed ) )
		return;

	wait 0.05;
	a_spots = getstructarray( "pts_lion", "targetname" );
	n_deployed_springpads_on_symbols = 0;

	foreach ( s_spot in a_spots )
	{
		if ( isdefined( s_spot.springpad ) )
			n_deployed_springpads_on_symbols++;
	}

	n_springpads_in_inventory = 0;

	foreach ( player in getPlayers() )
	{
		equipment = player get_player_equipment();

		if ( isdefined( equipment ) && equipment == level.springpad_name )
			n_springpads_in_inventory++;
	}

	n_total_springpads_ready_for_symbols = n_deployed_springpads_on_symbols + n_springpads_in_inventory;

	if ( n_total_springpads_ready_for_symbols < 4 )
		self equipment_take( level.springpad_name );
}


//after a player disconnects during the Maxis Trample Steam step making the number of players be less than 4 or if it already was less than 4 and depending on if not enough Trample Steams were on symbols and in inventories, gives the players not carrying Trample Steams the ability to pick up new Trample Steams
refresh_players_springpads()
{
	if ( flag( "sq_branch_complete" ) || is_true( level.maxcompleted ) || !is_true( level._zombie_sidequests[ "sq_2" ].stages[ "ssp_2" ].completed ) || is_true( level._zombie_sidequests[ "sq_2" ].stages[ "pts_2" ].completed ) )
		return;

	wait 0.05;
	a_spots = getstructarray( "pts_lion", "targetname" );
	n_deployed_springpads_on_symbols = 0;

	foreach ( s_spot in a_spots )
	{
		if ( isdefined( s_spot.springpad ) )
			n_deployed_springpads_on_symbols++;
	}

	n_springpads_in_inventory = 0;

	foreach ( player in getPlayers() )
	{
		equipment = player get_player_equipment();

		if ( isdefined( equipment ) && equipment == level.springpad_name )
			n_springpads_in_inventory++;
	}

	n_total_springpads_ready_for_symbols = n_deployed_springpads_on_symbols + n_springpads_in_inventory;

	if ( getPlayers().size < 4 && n_total_springpads_ready_for_symbols < 4 )
	{
		foreach ( player in getPlayers() )
		{
			equipment = player get_player_equipment();

			if ( !isdefined( equipment ) || equipment != level.springpad_name )
			{
				if ( n_total_springpads_ready_for_symbols < 4 )
				{
					n_total_springpads_ready_for_symbols++;
					player equipment_take( level.springpad_name );
				}
				else
					break;
			}
		}
	}
}

//keeps old Trample Steam(s) in place during Maxis balls step if number of players is less than 4
custom_cleanupoldspringpad()
{
	if ( getPlayers().size >= 4 || !is_true( level._zombie_sidequests[ "sq_2" ].stages[ "ssp_2" ].completed ) || is_true( level._zombie_sidequests[ "sq_2" ].stages[ "pts_2" ].completed ) )
	{
		if ( isdefined( self.buildablespringpad ) )
		{
			if ( isdefined( self.buildablespringpad.stub ) )
			{
				thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.buildablespringpad.stub );
				self.buildablespringpad.stub = undefined;
			}

			self.buildablespringpad delete();
			self.springpad_kills = undefined;
		}
	}

	if ( isdefined( level.springpad_sound_ent ) )
	{
		level.springpad_sound_ent delete();
		level.springpad_sound_ent = undefined;
	}
}

//if the number of players is less than 4 and a player picks up a Trample Steam, doesn't undefine the players' Trample Steams that are on lion symbols for the Maxis Trample Steam step
custom_pts_springpad_waittill_removed( m_springpad )
{
	while ( !is_true( level._zombie_sidequests[ "sq_2" ].stages[ "pts_2" ].completed ) )
	{
		if ( ( getPlayers().size >= 4 || !is_true( level._zombie_sidequests[ "sq_2" ].stages[ "ssp_2" ].completed ) ) && !is_true( endons_set ) )
		{
			m_springpad endon( "delete" );
			m_springpad endon( "death" );
			endons_set = 1;
		}

		msg = self waittill_any_return( "death", "disconnect", "equip_springpad_zm_taken", "equip_springpad_zm_pickup" );

		if ( getPlayers().size >= 4 || !is_true( level._zombie_sidequests[ "sq_2" ].stages[ "ssp_2" ].completed ) || ( msg != "equip_springpad_zm_taken" && msg != "equip_springpad_zm_pickup" ) )
			break;
	}
}
