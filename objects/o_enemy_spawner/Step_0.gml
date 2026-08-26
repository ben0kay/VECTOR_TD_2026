/// @description Processes level enemy pressure.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


scr_enemy_spawner_update(id);

scr_enemy_transport_release_queue_update();