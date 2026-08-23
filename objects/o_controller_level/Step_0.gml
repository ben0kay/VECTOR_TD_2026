/// @description Processes the active level state and temporary test controls.

switch (global.LevelState)
{
    case LevelState.INITIALIZING:
    {
        // Level initialization is handled by the Create event.
    }
    break;


    case LevelState.PLAYING:
    {
        global.vtd_level.time.elapsed +=
            1 / max(1, game_get_speed(gamespeed_fps));


        if (keyboard_check_pressed(ord("N")))
            scr_enemy_spawn_edge("enemy_weak");

        if (keyboard_check_pressed(ord("J")))
            scr_enemy_spawn_edge("enemy_hunter");

        if (keyboard_check_pressed(ord("H")))
            scr_enemy_spawn_edge("enemy_phaser");

        if (keyboard_check_pressed(ord("U")))
            scr_enemy_spawn_edge("enemy_shooter_single");

        if (keyboard_check_pressed(ord("I")))
            scr_enemy_spawn_edge("enemy_shooter_triple");

        if (keyboard_check_pressed(ord("O")))
            scr_enemy_spawn_edge("enemy_kamikaze");


        if (keyboard_check_pressed(ord("K")))
        {
            var _cpu = global.vtd_level.entities.cpu;

            if (instance_exists(_cpu))
                scr_cpu_damage(_cpu, 25);
        }


        // FUTURE:
        // baseline spawning
        // clusters
        // waves
        // milestones
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
        // defeat handling
    }
    break;


    case LevelState.EXITING:
    {
        // Cleanup belongs to the Clean Up event.
    }
    break;
}