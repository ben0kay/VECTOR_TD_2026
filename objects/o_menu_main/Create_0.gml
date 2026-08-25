/// @description Initializes the Vector TD main menu.

if (!variable_global_exists("vtd"))
{
    show_debug_message(
        "MAIN MENU ERROR - permanent runtime not initialized."
    );

    instance_destroy();
    exit;
}


global.GameState =
    GameState.MENU;

global.LevelState =
    LevelState.EXITING;


display_set_gui_size(
    global.vtd.settings.view_width,
    global.vtd.settings.view_height
);


menu =
    scr_menu_main_create();