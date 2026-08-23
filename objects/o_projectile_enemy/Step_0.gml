/// @description Processes one hostile projectile.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


scr_projectile_enemy_update(id);