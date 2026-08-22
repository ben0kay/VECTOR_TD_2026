/// @description Updates persistent game state.

global.vtd.tick++;


switch (global.vtd.GameState)
{
    case GameState.BOOT:
    {
        // Initialization is currently completed in the Create event.
    }
    break;


    case GameState.MENU:
    {
        // FUTURE:
        // menu navigation
        // persistent upgrade management
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
        // results and return-to-menu handling
    }
    break;
}