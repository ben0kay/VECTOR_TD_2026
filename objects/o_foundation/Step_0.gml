/// @description Updates one foundation tile.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;

scr_foundation_update(id);