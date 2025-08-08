#include common_scripts\utility;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_utility;

main()
{
	replaceFunc( maps\mp\zombies\_zm_equip_springpad::cleanupoldspringpad, ::cleanupoldspringpad );
	replaceFunc( maps\mp\zm_highrise_sq_pts::pts_springpad_waittill_removed, ::pts_springpad_waittill_removed );
}

init()
{
	thread ignore_equipment();
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread msg();
		player thread watchspringpaduse();
		player thread onPlayerDisconnect();
	}
}

msg()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iPrintLn( "^3Any Player EE Mod ^5Die Rise Maxis Extra Trample Steams" );
}

//after a player disconnects during the Maxis Trample Steam step making the number of players be less than 4 or if it already was less than 4 and depending on if not enough Trample Steams were on symbols and in inventories, gives the players not carrying Trample Steams the ability to pick up new Trample Steams
onPlayerDisconnect()
{
	level endon( "end_game" );
	self waittill( "disconnect" );

	for ( i = 0; i < level.players.size; i++ )
	{
		equipment = level.players[i] get_player_equipment();

		if ( !isdefined( equipment ) || equipment != level.springpad_name )
		{
			level.players[i] thread dropspringpad();
		}
	}
}

//makes zombies ignore Trample Steams placed during Maxis Trample Steam step if number of players was less than 4 when the Ballistic Knife step was completed
ignore_equipment()
{
	level endon( "end_game" );
	flag_wait( "initial_blackscreen_passed" );

	if ( flag( "sq_branch_complete" ) || is_true( level.maxcompleted ) )
		return;

	level waittill( "sq_2_ssp_2_over" );

	if ( getPlayers().size < 4 )
		maps\mp\zombies\_zm_equipment::enemies_ignore_equipment( level.springpad_name );

	level waittill( "sq_2_pts_2_over" );
	arrayRemoveValue( level.equipment_ignored_by_zombies, level.springpad_name );
}

watchspringpaduse()
{
	level endon( "end_game" );
	self endon( "disconnect" );

	while ( !flag( "sq_branch_complete" ) )
	{
		self waittill( "equipment_placed", weapon, weapname );

		if ( weapname == level.springpad_name )
			self dropspringpad();
	}
}

//after the player places down a Trample Steam during the Maxis Trample Steam step while there are less than 4 players and depending on if not enough Trample Steams were on symbols and in inventories, gives the player the ability to pick up a new Trample Steam
dropspringpad()
{
	if ( getPlayers().size >= 4 || flag( "sq_branch_complete" ) || is_true( level.maxcompleted ) || !is_true( level._zombie_sidequests["sq_2"].stages["ssp_2"].completed ) || is_true( level._zombie_sidequests["sq_2"].stages["pts_2"].completed ) )
		return;

	self endon( "disconnect" );
	wait 0.05;
	is_springpad_in_place = 0;

	foreach ( s_spot in getstructarray( "pts_lion", "targetname" ) )
	{
		if ( isdefined( s_spot.springpad ) )
			is_springpad_in_place++;
	}

	is_player_equipment = 0;

	for ( i = 0; i < level.players.size; i++ )
	{
		equipment = level.players[i] get_player_equipment();

		if ( isdefined( equipment ) && equipment == level.springpad_name )
			is_player_equipment++;
	}

	is_clear = is_springpad_in_place + is_player_equipment;

	if ( is_clear < 4 )
		self equipment_take( level.springpad_name );
}

//keeps old Trample Steam(s) in place during Maxis balls step if number of players is less than 4
cleanupoldspringpad()
{
	if ( getPlayers().size >= 4 || !is_true( level._zombie_sidequests["sq_2"].stages["ssp_2"].completed ) || is_true( level._zombie_sidequests["sq_2"].stages["pts_2"].completed ) )
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
pts_springpad_waittill_removed( m_springpad )
{
	while ( !is_true( level._zombie_sidequests["sq_2"].stages["pts_2"].completed ) )
	{
		if ( ( getPlayers().size >= 4 || !is_true( level._zombie_sidequests["sq_2"].stages["ssp_2"].completed ) ) && !is_true( endons_set ) )
		{
			m_springpad endon( "delete" );
			m_springpad endon( "death" );
			endons_set = 1;
		}

		msg = self waittill_any_return( "death", "disconnect", "equip_springpad_zm_taken", "equip_springpad_zm_pickup" );

		if ( getPlayers().size >= 4 || !is_true( level._zombie_sidequests["sq_2"].stages["ssp_2"].completed ) || ( msg != "equip_springpad_zm_taken" && msg != "equip_springpad_zm_pickup" ) )
			break;
	}
}
