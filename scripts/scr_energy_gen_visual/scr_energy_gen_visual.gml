/// @description Draws the complete procedural Solar Generator.

function scr_energy_generator_draw(_building)
{
    if (!instance_exists(_building))
        return false;

    scr_energy_generator_body(_building);
    scr_energy_generator_effects(_building);

    return true;
}


/// @description Draws the Solar Generator's static body.

function scr_energy_generator_body(_building)
{
    var _x = _building.x;
    var _y = _building.y;
    var _color = _building.visual.color;

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // CENTRAL GENERATOR HOUSING
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        15,
        8,
        22.5,
        2
    );

    scr_enemy_visual_helper_double_ring(
        _x,
        _y,
        10,
        5
    );


    // ========================================================================
    // FOUR SOLAR COLLECTOR WINGS
    // ========================================================================

    for (var i = 0; i < 4; ++i)
    {
        var _angle =
            45
            + (i * 90);

        var _panel_x =
            _x
            + lengthdir_x(
                24,
                _angle
            );

        var _panel_y =
            _y
            + lengthdir_y(
                24,
                _angle
            );


        // Main collector panel.

        scr_enemy_visual_helper_local_box(
            _panel_x,
            _panel_y,
            _angle,

            -9,
            -6,

            9,
            6,

            2
        );


        // Panel segmentation.

        scr_enemy_visual_helper_local_line(
            _panel_x,
            _panel_y,
            _angle,

            0,
            -6,

            0,
            6,

            1
        );

        scr_enemy_visual_helper_local_line(
            _panel_x,
            _panel_y,
            _angle,

            -9,
            0,

            9,
            0,

            1
        );


        // Support spine.

        scr_enemy_visual_helper_local_line(
            _panel_x,
            _panel_y,
            _angle,

            -7,
            -4,

            7,
            4,

            1
        );

        scr_enemy_visual_helper_local_line(
            _panel_x,
            _panel_y,
            _angle,

            -7,
            4,

            7,
            -4,

            1
        );


        // Energy feed arm.

        draw_line_width(
            _x
                + lengthdir_x(
                    11,
                    _angle
                ),

            _y
                + lengthdir_y(
                    11,
                    _angle
                ),

            _x
                + lengthdir_x(
                    16,
                    _angle
                ),

            _y
                + lengthdir_y(
                    16,
                    _angle
                ),

            2
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the Solar Generator's static body.

function scr_energy_generator_baked_body(_building)
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 80;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _preview =
    {
        x: _size * 0.5,
        y: _size * 0.5,

        visual:
        {
            color: c_white
        }
    };

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    scr_energy_generator_body(
        _preview
    );

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


/// @description Draws the Solar Generator's rotating energy effects.

function scr_energy_generator_effects(
    _building,
    _angle = global.vtd.tick * 0.75
)
{
    var _x = _building.x;
    var _y = _building.y;
    var _color = _building.visual.color;

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // ROTATING INNER FRAME
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        13,
        8,
        _angle,
        2
    );


    // ========================================================================
    // ROTATING ENERGY NODES
    // ========================================================================

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        12,
        2,
        4,
        -_angle * 2,
        true
    );


    // ========================================================================
    // INNER ENERGY TICKS
    // ========================================================================

    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        7,
        4,
        4,
        _angle + 45,
        1
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Bakes and draws the Solar Generator's rotating effects.

function scr_energy_generator_baked_effects(
    _building,
    _offset_x,
    _offset_y
)
{
    static _sprite = -1;

    if (!sprite_exists(_sprite))
    {
        var _size = 48;
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
                color: c_white
            }
        };

        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);

        scr_energy_generator_effects(
            _preview,
            0
        );

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
    }


    // ========================================================================
    // ROTATING ENERGY SPRITE
    // ========================================================================

    var _spin =
        global.vtd.tick
        * 0.75;

    draw_sprite_ext(
        _sprite,
        0,
        _building.x + _offset_x,
        _building.y + _offset_y,
        1,
        1,
        _spin,
        _building.visual.color,
        1
    );


    // ========================================================================
    // LIVE POWER CORE
    // ========================================================================

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 5
            + real(_building.id)
        ) * 0.2;

    draw_set_alpha(_pulse);
    draw_set_color(c_yellow);

    draw_circle(
        _building.x + _offset_x,
        _building.y + _offset_y,
        6,
        false
    );

    draw_circle(
        _building.x + _offset_x,
        _building.y + _offset_y,
        3,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}