/// @description Processes one generic enemy.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


// Effects calculate the effective movement speed first.

scr_enemy_effects_update(id);

if (!instance_exists(id))
    exit;


// Temporary player aggro may override the active target while preserving
// the enemy's strategic building or CPU objective.

scr_enemy_player_targeting_update(id);

if (!instance_exists(id))
    exit;


// Gameplay may now navigate, reposition or attack.

scr_enemy_update(id);

if (!instance_exists(id))
    exit;


// Visual feedback follows the completed gameplay update.

scr_enemy_visual_direction_update(id);
scr_enemy_shield_update(id);
scr_particles_enemy_update(id);