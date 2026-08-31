/// @description Draws the complete procedural Flying Transporter.

function scr_enemy_visual_flying_transporter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _hover = scr_enemy_visual_hover_offset_get(_enemy);

    scr_enemy_visual_flying_transporter_body(_enemy, _hover);
    scr_enemy_visual_flying_transporter_effects(_enemy, 0, _hover);

    return true;
}


/// @description Draws the Flying Transporter's static body.

function scr_enemy_visual_flying_transporter_body(_enemy, _offset_y = 0)
{
    var _x = _enemy.x;
    var _y = _enemy.y + _offset_y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;

    draw_set_alpha(1);
    draw_set_color(_enemy.visual.color);

    var _body =
    [
        [_radius, 0],
        [_radius * 0.55, -_radius * 0.68],
        [0, -_radius * 0.92],
        [-_radius * 0.72, -_radius * 0.72],
        [-_radius, -_radius * 0.28],
        [-_radius * 0.82, 0],
        [-_radius, _radius * 0.28],
        [-_radius * 0.72, _radius * 0.72],
        [0, _radius * 0.92],
        [_radius * 0.55, _radius * 0.68]
    ];

    scr_enemy_visual_helper_local_polygon(
        _x, _y, _angle,
        _body,
        3
    );

    // Central reinforced cargo frame.

    scr_enemy_visual_helper_local_box(
        _x, _y, _angle,
        -_radius * 0.46, -_radius * 0.38,
        _radius * 0.42, _radius * 0.38,
        2
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.72, 0,
        _radius * 0.82, 0,
        3
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.4, -_radius * 0.36,
        _radius * 0.34, _radius * 0.36,
        1
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.4, _radius * 0.36,
        _radius * 0.34, -_radius * 0.36,
        1
    );

    // Four armoured cargo pods.

    for (var i = 0; i < 4; ++i)
    {
        var _forward = i < 2 ? _radius * 0.25 : -_radius * 0.4;
        var _side = (i mod 2 == 0) ? -_radius * 0.57 : _radius * 0.57;

        var _pod_x = _x
            + lengthdir_x(_forward, _angle)
            + lengthdir_x(_side, _angle + 90);

        var _pod_y = _y
            + lengthdir_y(_forward, _angle)
            + lengthdir_y(_side, _angle + 90);

        draw_circle(_pod_x, _pod_y, _radius * 0.19, false);
        draw_circle(_pod_x, _pod_y, _radius * 0.11, true);
    }

    // Rear engine housings.

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _engine_x = _x
            + lengthdir_x(_radius * 0.72, _angle + 180)
            + lengthdir_x(_radius * 0.43 * _side, _angle + 90);

        var _engine_y = _y
            + lengthdir_y(_radius * 0.72, _angle + 180)
            + lengthdir_y(_radius * 0.43 * _side, _angle + 90);

        draw_circle(_engine_x, _engine_y, _radius * 0.17, false);
        draw_circle(_engine_x, _engine_y, _radius * 0.09, true);
    }

    // Nose and central cargo core.

    scr_enemy_visual_helper_diamond(
        _x + lengthdir_x(_radius * 0.67, _angle),
        _y + lengthdir_y(_radius * 0.67, _angle),
        _radius * 0.16,
        _angle,
        2
    );

    draw_circle(_x, _y, _radius * 0.3, false);
    draw_circle(_x, _y, _radius * 0.17, true);

    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the Flying Transporter's body.

function scr_enemy_flying_transporter_baked_body()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 128;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _preview =
    {
        x: _size * 0.5,
        y: _size * 0.5,

        visual:
        {
            radius: 30,
            draw_angle: 0,
            color: c_white
        }
    };

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    scr_enemy_visual_flying_transporter_body(_preview);

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


/// @description Draws the Flying Transporter's procedural containment field.

function scr_enemy_visual_flying_transporter_effects(
    _enemy,
    _offset_x = 0,
    _offset_y = 0,
    _angle = global.vtd.tick * 3
)
{
    draw_set_color(_enemy.visual.color);

    scr_enemy_visual_helper_arc_segments(
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        _enemy.visual.radius * 0.38,
        3,
        70,
        _angle,
        3,
        2
    );

    draw_set_color(c_white);

    return true;
}


/// @description Bakes and draws the Flying Transporter's moving effects.

function scr_enemy_flying_transporter_baked_effects(
    _enemy,
    _offset_x,
    _offset_y
)
{
    static _sprite = -1;

    if (!sprite_exists(_sprite))
    {
        var _size = 64;
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
                radius: 30,
                color: c_white
            }
        };

        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);

        scr_enemy_visual_flying_transporter_effects(
            _preview,
            0,
            0,
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

    var _pulse = 0.65
        + dsin(global.vtd.tick * 5 + real(_enemy.id)) * 0.25;

    // Ground shadow stays beneath the hovering enemy.

    draw_set_alpha(0.18);
    draw_set_color(c_black);

    draw_ellipse(
        _enemy.x - (_enemy.visual.radius * 1.05),
        _enemy.y + 5,
        _enemy.x + (_enemy.visual.radius * 1.05),
        _enemy.y + 15,
        false
    );

    // Draw and rotate the cached containment field.

    draw_set_alpha(0.75);

    draw_sprite_ext(
        _sprite,
        0,
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        1,
        1,
        global.vtd.tick * 3,
        _enemy.visual.color,
        1
    );

    // This pulse changes shape, so it remains procedural.

    draw_set_alpha(_pulse);
    draw_set_color(_enemy.visual.color);

    draw_circle(
        _enemy.x + _offset_x,
        _enemy.y + _offset_y,
        _enemy.visual.radius * 0.1,
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}