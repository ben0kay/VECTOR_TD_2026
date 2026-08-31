/// @description Draws the rotating circular kamikaze enemy.

function scr_enemy_visual_kamikaze(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;


    // Instance offset prevents every kamikaze rotating in sync.

    var _spin =
        (
            global.vtd.tick * 6
            + real(_enemy.id)
        )
        mod 360;


    // ========================================================================
    // OUTER BODY
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(_enemy.visual.color);


    // Main circular outline.

    draw_circle(
        _x,
        _y,
        _radius,
        true
    );


    // Inner structural ring.

    draw_circle(
        _x,
        _y,
        _radius * 0.72,
        true
    );


    // ========================================================================
    // ROTATING ARMS
    // ========================================================================

    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        _radius * 0.72,
        _radius * 0.28,
        4,
        _spin,
        3
    );


    // ========================================================================
    // ROTATING INNER DIAMOND
    // ========================================================================

    draw_set_color(c_white);

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.48,
        _spin,
        2
    );


    // ========================================================================
    // EXPLOSIVE CORE
    // ========================================================================

    draw_set_color(_enemy.visual.color);

    draw_circle(
        _x,
        _y,
        _radius * 0.25,
        true
    );


    // Small rotating spokes between the core and diamond.

    scr_enemy_visual_helper_spokes(
        _x,
        _y,
        _radius * 0.27,
        _radius * 0.43,
        4,
        _spin + 45,
        1
    );


    // ========================================================================
    // CENTER
    // ========================================================================

    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        max(
            1.5,
            _radius * 0.07
        ),
        false
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}