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


        // Spawn one data-driven test enemy.

        if (
            keyboard_check_pressed(
                ord("N")
            )
        )
        {
            scr_enemy_spawn_test();
        }


        // Direct CPU-damage test.

        if (
            keyboard_check_pressed(
                ord("K")
            )
        )
        {
            var _cpu =
                global.vtd_level.entities.cpu;


            if (instance_exists(_cpu))
            {
                scr_cpu_damage(
                    _cpu,
                    100
                );
            }
        }


        // FUTURE:
        // baseline enemy spawning
        // waves and clusters
        // resources
        // local power networks
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
        // The CPU remains visible at zero health for now.
        // FUTURE:
        // defeat screen
        // restart
        // return to menu
    }
    break;


    case LevelState.EXITING:
    {
        // Runtime cleanup belongs to the Clean Up event.
    }
    break;
}