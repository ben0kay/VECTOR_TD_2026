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

/// @description Returns a sprite baked from the procedural Minigun visual.

function scr_tower_minigun_baked_body()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 128;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    var _preview =
    {
        id: 0,
        x: _size * 0.5,
        y: _size * 0.5,

        visual:
        {
            draw_angle: 0,
            turret_color: c_white
        }
    };

    scr_tower_visual_minigun(_preview);

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface,
        0,
        0,
        _size,
        _size,
        false,
        false,
        _size * 0.5,
        _size * 0.5
    );

    surface_free(_surface);

    return _sprite;
}


