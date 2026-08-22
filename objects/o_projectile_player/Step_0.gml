/// @description Processes one player projectile.

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


scr_projectile_player_update(id);