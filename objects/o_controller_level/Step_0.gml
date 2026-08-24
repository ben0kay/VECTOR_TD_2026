/// @description Updates gameplay time, victory checks and mission resolution.

switch (global.LevelState)
{
    case LevelState.INITIALIZING:
    {
        // Initialization currently completes in the Create Event.
    }
    break;


    case LevelState.PLAYING:
    {
        global.vtd_level.time.frames++;

        global.vtd_level.time.seconds =
            global.vtd_level.time.frames
            / max(
                1,
                game_get_speed(gamespeed_fps)
            );

        scr_level_result_update();
    }
    break;


    case LevelState.COMPLETE:
    case LevelState.FAILED:
    {
        // Gameplay systems stop through GAMEPLAY_ACTIVE, while the result
        // animation and interface continue updating.

        scr_level_result_update();
    }
    break;


    case LevelState.EXITING:
    {
        // Cleanup belongs to the Clean Up Event.
    }
    break;
}