/// @description Processes one generic enemy.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


// Effects calculate the enemy's effective movement speed first.

scr_enemy_effects_update(id);

if (!instance_exists(id))
    exit;


// Gameplay may now move, navigate or attack using the effective speed.

scr_enemy_update(id);

if (!instance_exists(id))
    exit;


// Visual feedback follows the completed gameplay update.

scr_enemy_visual_direction_update(id);
scr_enemy_shield_update(id);