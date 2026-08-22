/// @description Updates the current gameplay level.

switch (global.vtd_level.state)
{
    case LevelState.INITIALIZING:
    {
        // Initialization currently completes in the Create event.
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


        // FUTURE:
        // spawning
        // waves
        // power networks
        // resources
        // level completion
    }
    break;


    case LevelState.COMPLETE:
    {
        // FUTURE:
        // victory handling
    }
    break;


    case LevelState.FAILED:
    {
        // FUTURE:
        // CPU destroyed / defeat handling
    }
    break;


    case LevelState.EXITING:
    {
        // Cleanup is handled by the Clean Up event.
    }
    break;
}