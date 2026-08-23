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


        // ================================================================
        // TEMPORARY ENEMY TEST CONTROLS
        // ================================================================

		if (keyboard_check_pressed(ord("Q")))
			room_restart();

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

        if (keyboard_check_pressed(ord("L")))
            scr_enemy_spawn_edge("enemy_splitter");
			
			if (keyboard_check_pressed(ord("A")))
{
    scr_hud_alert_push(
        HudAlertType.INFO,
        "SYSTEM MESSAGE",
        "VECTOR ALERT SYSTEM OPERATIONAL",
        4
    );
}
			
	

        // Direct CPU damage test.

        if (keyboard_check_pressed(ord("K")))
        {
            var _cpu = global.vtd_level.entities.cpu;

            if (instance_exists(_cpu))
                scr_cpu_damage(_cpu, 100);
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