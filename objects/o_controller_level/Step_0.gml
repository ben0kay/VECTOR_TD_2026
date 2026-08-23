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
            / max(1, game_get_speed(gamespeed_fps));


        // Yellow enemy: heads directly toward the CPU.

        if (keyboard_check_pressed(ord("N")))
            scr_enemy_spawn_edge("enemy_weak");


        // Red enemy: finds and attacks the closest building.

        if (keyboard_check_pressed(ord("J")))
            scr_enemy_spawn_edge("enemy_hunter");


        // Cyan enemy: heads toward the CPU through buildings.

        if (keyboard_check_pressed(ord("H")))
            scr_enemy_spawn_edge("enemy_phaser");


        // Direct CPU-damage test.

        if (keyboard_check_pressed(ord("K")))
        {
            var _cpu = global.vtd_level.entities.cpu;

            if (instance_exists(_cpu))
                scr_cpu_damage(_cpu, 100);
        }


        // FUTURE:
        // baseline enemy spawning
        // clusters
        // major waves
        // level milestones
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