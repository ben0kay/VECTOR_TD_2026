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
    var _color = _enemy.visual.color;

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // MAIN RECTANGULAR HULL
    // ========================================================================

    var _body =
    [
        [_radius * 1.15, -_radius * 0.30],
        [_radius * 0.92, -_radius * 0.58],
        [-_radius * 0.78, -_radius * 0.58],
        [-_radius * 1.08, -_radius * 0.34],
        [-_radius * 1.08,  _radius * 0.34],
        [-_radius * 0.78,  _radius * 0.58],
        [_radius * 0.92,   _radius * 0.58],
        [_radius * 1.15,   _radius * 0.30]
    ];

    scr_enemy_visual_helper_local_polygon(
        _x, _y, _angle,
        _body,
        3
    );


    // ========================================================================
    // CENTRAL CARGO FRAME
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x, _y, _angle,
        -_radius * 0.62, -_radius * 0.34,
         _radius * 0.52,  _radius * 0.34,
        2
    );

    scr_enemy_visual_helper_local_box(
        _x, _y, _angle,
        -_radius * 0.42, -_radius * 0.22,
         _radius * 0.32,  _radius * 0.22,
        1
    );

    // Main structural spine.

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.92, 0,
         _radius * 0.95, 0,
        3
    );

    // Cargo cross-bracing.

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.45, -_radius * 0.32,
         _radius * 0.28,  _radius * 0.32,
        1
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        -_radius * 0.45,  _radius * 0.32,
         _radius * 0.28, -_radius * 0.32,
        1
    );


    // ========================================================================
    // FOUR SIDE CARGO PODS
    // ========================================================================

    for (var i = 0; i < 4; ++i)
    {
        var _forward = i < 2 ? _radius * 0.28 : -_radius * 0.38;
        var _side = (i mod 2 == 0) ? -_radius * 0.60 : _radius * 0.60;

        var _pod_x =
            _x
            + lengthdir_x(_forward, _angle)
            + lengthdir_x(_side, _angle + 90);

        var _pod_y =
            _y
            + lengthdir_y(_forward, _angle)
            + lengthdir_y(_side, _angle + 90);

        scr_enemy_visual_helper_square(
            _pod_x,
            _pod_y,
            _radius * 0.18,
            _angle,
            2
        );

        draw_circle(
            _pod_x,
            _pod_y,
            _radius * 0.07,
            false
        );
    }


    // ========================================================================
    // REAR ENGINE BLOCKS
    // ========================================================================

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _engine_x =
            _x
            + lengthdir_x(_radius * 0.90, _angle + 180)
            + lengthdir_x(_radius * 0.30 * _side, _angle + 90);

        var _engine_y =
            _y
            + lengthdir_y(_radius * 0.90, _angle + 180)
            + lengthdir_y(_radius * 0.30 * _side, _angle + 90);

        draw_circle(
            _engine_x,
            _engine_y,
            _radius * 0.15,
            true
        );

        draw_circle(
            _engine_x,
            _engine_y,
            _radius * 0.07,
            false
        );
    }


    // ========================================================================
    // FORWARD COMMAND SECTION
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x, _y, _angle,
        _radius * 0.55, -_radius * 0.26,
        _radius * 0.92,  _radius * 0.26,
        2
    );

    scr_enemy_visual_helper_diamond(
        _x + lengthdir_x(_radius * 0.88, _angle),
        _y + lengthdir_y(_radius * 0.88, _angle),
        _radius * 0.12,
        _angle,
        2
    );


    // ========================================================================
    // CENTRAL CONTAINMENT CORE
    // ========================================================================

    draw_circle(
        _x,
        _y,
        _radius * 0.24,
        true
    );

    draw_circle(
        _x,
        _y,
        _radius * 0.10,
        false
    );


    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the Flying Transporter's body.

function scr_enemy_flying_transporter_baked_body(_enemy)
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _radius = _enemy.visual.radius;
    var _size = max(64, ceil(_radius * 3));
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


/// @description Draws the Flying Transporter's procedural containment effects.

function scr_enemy_visual_flying_transporter_effects(
    _enemy,
    _offset_x = 0,
    _offset_y = 0,
    _angle = global.vtd.tick * 3
)
{
    var _x = _enemy.x + _offset_x;
    var _y = _enemy.y + _offset_y;
    var _radius = _enemy.visual.radius;

    draw_set_color(_enemy.visual.color);

    // Rotating containment segments.

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        _radius * 0.34,
        4,
        55,
        _angle,
        3,
        2
    );

    // Counter-rotating inner spokes.

    scr_enemy_visual_helper_radial_ticks(
        _x, _y,
        _radius * 0.18,
        _radius * 0.13,
        4,
        -_angle,
        1
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
        var _radius = _enemy.visual.radius;
        var _size = max(32, ceil(_radius * 1.4));
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

    var _pulse =
        0.65
        + dsin(global.vtd.tick * 5 + real(_enemy.id)) * 0.25;

    draw_set_alpha(0.18);
    draw_set_color(c_black);

    draw_ellipse(
        _enemy.x - (_enemy.visual.radius * 1.05),
        _enemy.y + 5,
        _enemy.x + (_enemy.visual.radius * 1.05),
        _enemy.y + 15,
        false
    );

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