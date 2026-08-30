/// @description Draws the Twin Minigun Tower.

function scr_tower_visual_minigun(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;


    draw_set_color(_color);


    // ========================================================================
    // LOW ROTARY BASE
    // ========================================================================

    scr_enemy_visual_helper_polygon(
	    _x,
	    _y,
	    19,
	    6,
	    _angle + 30,
	    2
	);


    draw_circle(
        _x,
        _y,
        12,
        true
    );


    // ========================================================================
    // CENTRAL WEAPON HOUSING
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -9,
        -10,

        15,
        10,

        2
    );


    // ========================================================================
    // LEFT MINIGUN
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        10,
        -10,

        34,
        -4,

        2
    );


    // ========================================================================
    // RIGHT MINIGUN
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        10,
        4,

        34,
        10,

        2
    );


    // Barrel tips.

    var _left_x =
        _x
        + lengthdir_x(38, _angle)
        + lengthdir_x(7, _angle - 90);

    var _left_y =
        _y
        + lengthdir_y(38, _angle)
        + lengthdir_y(7, _angle - 90);


    var _right_x =
        _x
        + lengthdir_x(38, _angle)
        + lengthdir_x(7, _angle + 90);

    var _right_y =
        _y
        + lengthdir_y(38, _angle)
        + lengthdir_y(7, _angle + 90);


    draw_circle(
        _left_x,
        _left_y,
        4,
        true
    );

    draw_circle(
        _right_x,
        _right_y,
        4,
        true
    );


    // ========================================================================
    // REAR AMMO / MOTOR BLOCK
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -17,
        -8,

        -7,
        8,

        2
    );


    draw_set_color(c_white);

    return true;
}
