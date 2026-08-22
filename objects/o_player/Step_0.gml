/// @description Processes player behaviour.

if (
    global.vtd.GameState
    != GameState.PLAYING
)
{
    exit;
}

if (
    global.vtd_level.state
    != LevelState.PLAYING
)
{
    exit;
}

scr_player_update(id);