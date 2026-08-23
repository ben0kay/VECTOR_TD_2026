/// @description Processes passive storage behaviour.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


// FUTURE:
// power state
// storage damage or leakage
// active cargo ports
// drone reservations