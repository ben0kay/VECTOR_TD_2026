/// @description Draws the complete procedural Kamikaze.

function scr_enemy_visual_kamikaze(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    scr_enemy_visual_kamikaze_body(_enemy);
    scr_enemy_visual_kamikaze_effects(_enemy);

    return true;
}


/// @description Draws the Kamikaze's static explosive body.

function scr_enemy_visual_kamikaze_body(_enemy)
{
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // OUTER BODY
    // ========================================================================

    draw_circle(_x, _y, _radius * 0.88, true);
    draw_circle(_x, _y, _radius * 0.72, true);


    // ========================================================================
    // STATIC ARMOUR FRAME
    // ========================================================================

    scr_enemy_visual_helper_spokes(
        _x, _y,
        _radius * 0.48,
        _radius * 0.69,
        4,
        _angle + 45,
        2
    );


    // ========================================================================
    // INNER DETONATION ASSEMBLY
    // ========================================================================

    draw_set_color(c_white);

    draw_circle(_x, _y, _radius * 0.48, true);
    draw_circle(_x, _y, _radius * 0.36, true);


    // ========================================================================
    // EXPLOSIVE CORE
    // ========================================================================

    draw_set_color(_color);

    draw_circle(_x, _y, _radius * 0.25, false);


    var _core_triangle =
    [
        [_radius * 0.14, 0],
        [-_radius * 0.09, -_radius * 0.12],
        [-_radius * 0.09,  _radius * 0.12]
    ];


    draw_set_color(c_white);

    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _core_triangle,
        2
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the Kamikaze's static body.

function scr_enemy_kamikaze_baked_body(_enemy)
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _radius = _enemy.visual.radius;
    var _size = max(64, ceil(_radius * 2.8));
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _preview =
    {
        x: _size * 0.5,
        y: _size * 0.5,

        visual:
        {
            radius: _radius,
            draw_angle: 0,
            color: c_white
        }
    };

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    scr_enemy_visual_kamikaze_body(_preview);

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _size, _size,
        false, false,
        _size * 0.5,
        _size * 0.5
    );

    surface_free(_surface);

    return _sprite;
}


/// @description Draws the Kamikaze's rotating blade assembly.

function scr_enemy_visual_kamikaze_effects(_enemy, _angle = undefined)
{
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _color = _enemy.visual.color;

    if (is_undefined(_angle))
    {
        _angle =
            (
                global.vtd.tick * 6
                + real(_enemy.id)
            )
            mod 360;
    }

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // OUTER ROTOR SEGMENTS
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        _radius * 1.04,
        8,
        20,
        _angle + 10,
        2,
        1
    );


    // ========================================================================
    // FOUR LONG THIN DETONATION BLADES
    // ========================================================================

    var _blade =
    [
        [_radius * 0.30, -_radius * 0.07],
        [_radius * 0.58, -_radius * 0.10],
        [_radius * 1.02, -_radius * 0.28],
        [_radius * 1.42, -_radius * 0.16],
        [_radius * 1.18,  _radius * 0.02],
        [_radius * 0.72,  _radius * 0.11],
        [_radius * 0.38,  _radius * 0.08]
    ];

    for (var i = 0; i < 4; ++i)
    {
        var _blade_angle = _angle + (i * 90);

        scr_enemy_visual_helper_local_polygon(
            _x,
            _y,
            _blade_angle,
            _blade,
            1
        );


        // Thin internal blade spine.

        scr_enemy_visual_helper_local_line(
            _x, _y,
            _blade_angle,

            _radius * 0.47,
            -_radius * 0.02,

            _radius * 1.20,
            -_radius * 0.12,

            1
        );
    }


    // ========================================================================
    // INNER ROTOR
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        _radius * 0.56,
        4,
        42,
        -_angle,
        2,
        1
    );

    scr_enemy_visual_helper_radial_ticks(
        _x, _y,
        _radius * 0.32,
        _radius * 0.11,
        4,
        _angle + 45,
        1
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Bakes and draws the Kamikaze's rotating blade assembly.

function scr_enemy_kamikaze_baked_effects(_enemy, _offset_x, _offset_y)
{
    static _sprite = -1;

    if (!sprite_exists(_sprite))
    {
        var _radius = _enemy.visual.radius;
        var _size = max(64, ceil(_radius * 3.2));
        var _surface = surface_create(_size, _size);

        if (!surface_exists(_surface))
            return false;

        var _preview =
        {
            id: 0,
            x: _size * 0.5,
            y: _size * 0.5,

            visual:
            {
                radius: _radius,
                color: c_white
            }
        };

        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);

        scr_enemy_visual_kamikaze_effects(
            _preview,
            0
        );

        surface_reset_target();

        _sprite = sprite_create_from_surface(
            _surface,
            0, 0,
            _size, _size,
            false, false,
            _size * 0.5,
            _size * 0.5
        );

        surface_free(_surface);
    }


    // ========================================================================
    // ROTATION
    // ========================================================================

    var _spin =
        (
            global.vtd.tick * 6
            + real(_enemy.id)
        )
        mod 360;


    draw_set_alpha(1);

    draw_sprite_ext(
        _sprite,
        0,
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        1,
        1,
        _spin,
        _enemy.visual.color,
        1
    );

    draw_set_color(c_white);

    return true;
}