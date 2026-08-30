/// @description Returns a sprite baked from the procedural Minigun visual.

function scr_tower_minigun_baked_sprite_get()
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

/// @description Returns a sprite baked from the static Disruptor body.

function scr_tower_disruptor_baked_sprite_get()
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

    scr_tower_visual_disruptor_body(_preview);

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