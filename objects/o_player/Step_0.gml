/// @description Processes player behaviour.

if (
    global.vtd.game_state
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