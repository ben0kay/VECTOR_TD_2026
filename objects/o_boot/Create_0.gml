/// @description Initializes the commander-profile boot flow.

if (!variable_global_exists("vtd") || !is_struct(global.vtd)){
    show_debug_message( "BOOT ERROR - game runtime was not initialized.");
	instance_destroy();
    exit;
}

display_set_gui_size( global.vtd.settings.view_width, global.vtd.settings.view_height );
global.GameState = GameState.BOOT;
boot = scr_boot_create();