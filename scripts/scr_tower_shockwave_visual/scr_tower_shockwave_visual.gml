/// @description Draws the complete procedural Shockwave visual.

function scr_tower_visual_shockwave(_tower)
{
    scr_tower_visual_shockwave_body(_tower);
    scr_tower_visual_shockwave_effects(_tower);

    return true;
}


/// @description Draws the static Shockwave body.

function scr_tower_visual_shockwave_body(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    // Twelve-sided outer frame.

    scr_enemy_visual_helper_polygon(
        _x, _y,
        23,
        12,
        _angle + 15,
        3
    );

    // Inner structural ring.

    scr_enemy_visual_helper_polygon(
        _x, _y,
        17,
        12,
        _angle,
        2
    );

    // Main spoke system.

    scr_enemy_visual_helper_spokes(
        _x, _y,
        9,
        17,
        6,
        _angle,
        2
    );

    // Alternating outer emitters.

    scr_enemy_visual_helper_radial_ticks(
        _x, _y,
        18,
        5,
        6,
        _angle + 30,
        2
    );

    // Core housing.

    draw_circle(_x, _y, 10, true);
    draw_circle(_x, _y, 6, true);

    scr_enemy_visual_helper_diamond(
        _x, _y,
        7,
        _angle + 45,
        2
    );

    // Small directional stabilisers.

    scr_enemy_visual_helper_radial_dots(
        _x, _y,
        14,
        2,
        6,
        _angle,
        false
    );

    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the static Shockwave body.

function scr_tower_shockwave_baked_body()
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

    scr_tower_visual_shockwave_body(_preview);

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


/// @description Draws the procedural Shockwave rotating effects.

function scr_tower_visual_shockwave_effects(
    _tower,
    _angle = global.vtd.tick * 2
)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    // Rotating outer shock segments.

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        20,
        6,
        28,
        _angle,
        3,
        2
    );

    // Counter-rotating inner spoke system.

    scr_enemy_visual_helper_radial_ticks(
        _x, _y,
        10,
        5,
        6,
        -_angle,
        2
    );

    // Pulsing shock core.

    var _pulse =
        0.45
        + sin(global.vtd.tick * 6) * 0.15;

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        5,
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        2,
        false
    );

    return true;
}


/// @description Bakes and draws the Shockwave rotating effects.

function scr_tower_shockwave_baked_effects(
    _tower,
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
            x: _size * 0.5,
            y: _size * 0.5,

            visual:
            {
                turret_color: c_white
            }
        };

        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);

        scr_tower_visual_shockwave_effects(_preview, 0);

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

    draw_sprite_ext(
        _sprite,
        0,
        _tower.x + _offset_x,
        _tower.y + _offset_y,
        1, 1,
        global.vtd.tick * 2,
        _tower.visual.turret_color,
        1
    );

    return true;
}