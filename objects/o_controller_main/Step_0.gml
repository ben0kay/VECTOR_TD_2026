/// @description Updates persistent game state.

global.vtd.tick++;


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