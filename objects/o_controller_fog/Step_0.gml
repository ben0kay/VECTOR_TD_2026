/// @description Updates level fog visibility.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;

scr_fog_update(id);