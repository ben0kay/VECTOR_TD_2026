/// @description Updates the current gameplay level.

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


        // Enemy spawning, CPU damage and room-reset testing now belong
        // to the F1 debug interface.
        //
        // FUTURE:
        // victory-condition checks
        // objective updates
        // scripted level events
    }
    break;


    case LevelState.COMPLETE:
    {
        // FUTURE:
        // victory handling
        // rewards
        // return to level selection
    }
    break;


    case LevelState.FAILED:
    {
        // FUTURE:
        // defeat handling
        // retry
        // return to level selection
    }
    break;


    case LevelState.EXITING:
    {
        // Cleanup belongs to the Clean Up Event.
    }
    break;
}