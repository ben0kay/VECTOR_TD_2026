/// @description Updates construction and active tower behaviour.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


scr_building_update(id);

if (!instance_exists(id))
    exit;

if (BuildingState != BuildingState.ACTIVE)
    exit;


scr_tower_update(id);