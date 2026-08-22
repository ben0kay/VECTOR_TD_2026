/// @description Updates the current gameplay level.

switch (global.LevelState)
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
        // baseline enemy spawning
        // waves and clusters
        // resources
        // local power networks
        // level victory and failure
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
        // CPU destroyed
        // defeat handling
    }
    break;


    case LevelState.EXITING:
    {
        // Runtime cleanup belongs to the Clean Up event.
    }
    break;
}