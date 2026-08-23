/// @description Updates persistent game state.

global.vtd.tick++;

if (keyboard_check_pressed(vk_f11))
{
    window_set_fullscreen(!window_get_fullscreen());
}


switch (global.GameState)
{
    case GameState.BOOT:
    {
        // Initialization currently completes in the Create event.
    }
    break;


    case GameState.MENU:
    {
        // FUTURE:
        // menu navigation
        // persistent upgrades
        // level selection
    }
    break;


    case GameState.PLAYING:
    {
        // Gameplay-specific work belongs to o_controller_level.
    }
    break;


    case GameState.PAUSED:
    {
        // FUTURE:
        // pause-menu input
    }
    break;


    case GameState.GAME_OVER:
    {
        // FUTURE:
        // results
        // restart
        // return to menu
    }
    break;
}