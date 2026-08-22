/// @description Processes active tower behaviour.

if (
    global.GameState
    != GameState.PLAYING
)
{
    exit;
}


if (
    global.LevelState
    != LevelState.PLAYING
)
{
    exit;
}


scr_tower_update(id);