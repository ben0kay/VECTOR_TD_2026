/// @description Updates construction and passive storage behaviour.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


scr_building_update(id);

if (!instance_exists(id))
    exit;

if (BuildingState != BuildingState.ACTIVE)
    exit;


// FUTURE:
// power state
// storage damage or leakage
// active cargo ports
// drone reservations