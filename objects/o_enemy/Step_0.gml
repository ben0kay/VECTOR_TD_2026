/// @description Processes one generic enemy.

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


scr_enemy_update(id);