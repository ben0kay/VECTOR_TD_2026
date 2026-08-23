/// @description Processes one generic enemy.

/// @description Processes one generic enemy.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


// Process gameplay first. This may start a path, change direction,
// enter an attacking state, or move a brainless enemy.

scr_enemy_update(id);


// Update visual feedback after the enemy's gameplay state is known.

scr_enemy_visual_direction_update(id);
scr_enemy_shield_update(id);