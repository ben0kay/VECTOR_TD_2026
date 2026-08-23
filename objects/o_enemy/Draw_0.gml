/// @description Draws one enemy with optional shield and health display.

function scr_enemy_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    scr_enemy_shield_draw(
        _enemy
    );

    scr_enemy_visual_draw(
        _enemy
    );

    scr_enemy_health_bar_draw(
        _enemy
    );


    return true;
}