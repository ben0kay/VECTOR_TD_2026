/// @description Draws the complete procedural Berserker.

function scr_enemy_visual_berserker(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    scr_enemy_visual_berserker_body(_enemy);
    scr_enemy_visual_berserker_effects(_enemy);

    return true;
}


/// @description Draws the Berserker's static aggressive body.

function scr_enemy_visual_berserker_body(_enemy)
{
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;

    draw_set_alpha(1);
    draw_set_color(_enemy.visual.color);


    // ========================================================================
    // SPIKED OUTER HULL
    // ========================================================================

    var _body =
    [
        [_radius * 1.18, 0],
        [_radius * 0.66, -_radius * 0.30],
        [_radius * 0.82, -_radius * 0.82],
        [_radius * 0.30, -_radius * 0.66],
        [0, -_radius * 1.04],
        [-_radius * 0.30, -_radius * 0.66],
        [-_radius * 0.82, -_radius * 0.82],
        [-_radius * 0.66, -_radius * 0.30],
        [-_radius * 1.04, 0],
        [-_radius * 0.66, _radius * 0.30],
        [-_radius * 0.82, _radius * 0.82],
        [-_radius * 0.30, _radius * 0.66],
        [0, _radius * 1.04],
        [_radius * 0.30, _radius * 0.66],
        [_radius * 0.82, _radius * 0.82],
        [_radius * 0.66, _radius * 0.30]
    ];

    scr_enemy_visual_helper_local_polygon(
        _x, _y, _angle,
        _body,
        3
    );


    // ========================================================================
    // ARMOURED INNER FRAME
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x, _y,
        _radius * 0.62,
        8,
        _angle + 22.5,
        2
    );

    scr_enemy_visual_helper_spokes(
        _x, _y,
        _radius * 0.30,
        _radius * 0.58,
        4,
        _angle + 45,
        2
    );


    // ========================================================================
    // FORWARD ATTACK SPIKE
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        _radius * 0.50, -_radius * 0.30,
        _radius * 1.28, 0,
        3
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        _radius * 1.28, 0,
        _radius * 0.50, _radius * 0.30,
        3
    );


    // Rear aggression fins.

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.54, -_radius * 0.38,
        -_radius * 1.08, -_radius * 0.72,
        2
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.54, _radius * 0.38,
        -_radius * 1.08, _radius * 0.72,
        2
    );


    // ========================================================================
    // CORE HOUSING
    // ========================================================================

    draw_circle(
        _x,
        _y,
        _radius * 0.32,
        true
    );

    draw_circle(
        _x,
        _y,
        _radius * 0.17,
        true
    );


    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the Berserker's static body.

function scr_enemy_berserker_baked_body(_enemy)
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _radius = _enemy.visual.radius;
    var _size = max(64, ceil(_radius * 3.2));
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

    scr_enemy_visual_berserker_body(_preview);

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


/// @description Draws the Berserker's procedural rotating blade system.

function scr_enemy_visual_berserker_effects(
    _enemy,
    _angle = global.vtd.tick * 4
)
{
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;

    draw_set_color(_enemy.visual.color);


    // ========================================================================
    // SIX ROTATING SPIKES
    // ========================================================================

    for (var i = 0; i < 6; ++i)
    {
        var _blade_angle = _angle + (i * 60);

        var _inner_x = _x + lengthdir_x(_radius * 0.48, _blade_angle);
        var _inner_y = _y + lengthdir_y(_radius * 0.48, _blade_angle);

        var _left_x = _x + lengthdir_x(_radius * 0.68, _blade_angle - 15);
        var _left_y = _y + lengthdir_y(_radius * 0.68, _blade_angle - 15);

        var _tip_x = _x + lengthdir_x(_radius * 1.14, _blade_angle);
        var _tip_y = _y + lengthdir_y(_radius * 1.14, _blade_angle);

        var _right_x = _x + lengthdir_x(_radius * 0.68, _blade_angle + 15);
        var _right_y = _y + lengthdir_y(_radius * 0.68, _blade_angle + 15);

        draw_line_width(
            _inner_x, _inner_y,
            _left_x, _left_y,
            2
        );

        draw_line_width(
            _left_x, _left_y,
            _tip_x, _tip_y,
            3
        );

        draw_line_width(
            _tip_x, _tip_y,
            _right_x, _right_y,
            3
        );

        draw_line_width(
            _right_x, _right_y,
            _inner_x, _inner_y,
            2
        );
    }


    // Rotating inner ring.

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        _radius * 0.43,
        6,
        34,
        -_angle,
        2,
        2
    );


    draw_set_color(c_white);

    return true;
}


/// @description Bakes and draws the Berserker's health-reactive rotating effects.

function scr_enemy_berserker_baked_effects(
    _enemy,
    _offset_x,
    _offset_y
)
{
    static _sprite = -1;

    if (!sprite_exists(_sprite))
    {
        var _radius = _enemy.visual.radius;
        var _size = max(64, ceil(_radius * 2.8));
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

        scr_enemy_visual_berserker_effects(
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
    // RAGE
    // ========================================================================

    var _health_percentage = clamp(
        _enemy.vitals.hp.current
        / _enemy.vitals.hp.maximum,
        0,
        1
    );

    var _rage = 1 - _health_percentage;

    var _spin_speed = lerp(
        2.5,
        10,
        _rage
    );

    var _spin =
        (
            global.vtd.tick * _spin_speed
            + real(_enemy.id)
        )
        mod 360;

    var _rage_color = merge_color(
        _enemy.visual.color,
        c_red,
        _rage
    );


    // ========================================================================
    // ROTATING BLADE SPRITE
    // ========================================================================

    draw_set_alpha(1);

    draw_sprite_ext(
        _sprite,
        0,
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        1, 1,
        _spin,
        _rage_color,
        1
    );


    // ========================================================================
    // RAGE CORE
    // ========================================================================

    var _pulse =
        0.45
        + dsin(
            global.vtd.tick * lerp(4, 14, _rage)
            + real(_enemy.id)
        ) * 0.20;

    var _core_radius = lerp(
        _enemy.visual.radius * 0.13,
        _enemy.visual.radius * 0.27,
        _rage
    );

    draw_set_alpha(_pulse);
    draw_set_color(_rage_color);

    draw_circle(
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        _core_radius,
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_circle(
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        max(1.5, _enemy.visual.radius * 0.07),
        false
    );

    return true;
}