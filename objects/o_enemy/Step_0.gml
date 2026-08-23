/// @description Processes one generic enemy.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


// Native path movement occurs between Step events. Comparing the current
// position with the previous frame gives us the true travel direction.

scr_enemy_visual_direction_update(id);

scr_enemy_update(id);