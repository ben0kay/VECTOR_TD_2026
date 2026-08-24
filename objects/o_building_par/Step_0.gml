/// @description Updates one generic building.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;

scr_building_update(id);