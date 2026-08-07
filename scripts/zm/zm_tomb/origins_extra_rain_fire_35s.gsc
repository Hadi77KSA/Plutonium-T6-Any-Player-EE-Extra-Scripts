#include common_scripts\utility;

main()
{
	func = getFunction( "maps/mp/zm_tomb_ee_main_step_3", "fire_link_cooldown" );

	if ( isdefined( func ) )
	{
		replaceFunc( func, ::fire_link_cooldown );
	}
}

fire_link_cooldown( t_button )
{
	level notify( "fire_link_cooldown" );
	level endon( "fire_link_cooldown" );
	flag_set( "fire_link_enabled" );

	if ( isdefined( t_button ) )
		t_button playsound( "vox_maxi_robot_activated_0" );

	wait 35;

	if ( isdefined( t_button ) )
		t_button playsound( "vox_maxi_robot_deactivated_0" );

	flag_clear( "fire_link_enabled" );
}
