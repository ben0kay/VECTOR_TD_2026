/// @description Processes active miner extraction.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


scr_miner_update(id);