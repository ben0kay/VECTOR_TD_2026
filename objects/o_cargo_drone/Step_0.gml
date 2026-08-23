/// @description Processes cargo-drone movement and delivery.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


scr_logistics_drone_update(id);