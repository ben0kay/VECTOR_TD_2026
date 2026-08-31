/// @description Draws the complete procedural Shield Generator.

function scr_utility_shield_generator_draw(_building)
{
    if (!instance_exists(_building))
        return false;

    scr_utility_shield_generator_body(_building);
    scr_utility_shield_generator_effects(_building);

    return true;
}


/// @description Draws the Shield Generator's static body.

function scr_utility_shield_generator_body(_building)
{
    var _x = _building.x;
    var _y = _building.y;
    var _color = _building.visual.color;

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // HEAVY HEXAGONAL PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x, _y,
        25,
        6,
        30,
        3
    );

    scr_enemy_visual_helper_polygon(
        _x, _y,
        19,
        6,
        0,
        2
    );


    // ========================================================================
    // CENTRAL REACTOR HOUSING
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x, _y,
        13,
        6,
        30,
        2
    );

    draw_circle(
        _x,
        _y,
        8,
        true
    );

    draw_circle(
        _x,
        _y,
        4,
        true
    );


    // ========================================================================
    // SIX FIELD EMITTERS
    // ========================================================================

    for (var i = 0; i < 6; ++i)
    {
        var _angle =
            30
            + (i * 60);

        var _node_x =
            _x
            + lengthdir_x(
                22,
                _angle
            );

        var _node_y =
            _y
            + lengthdir_y(
                22,
                _angle
            );


        // Structural arm.

        draw_line_width(
            _x
                + lengthdir_x(
                    12,
                    _angle
                ),

            _y
                + lengthdir_y(
                    12,
                    _angle
                ),

            _node_x,
            _node_y,

            2
        );


        // Emitter housing.

        draw_circle(
            _node_x,
            _node_y,
            5,
            true
        );

        draw_circle(
            _node_x,
            _node_y,
            3,
            false
        );
    }


    // ========================================================================
    // STATIC CROSS BRACING
    // ========================================================================

    scr_enemy_visual_helper_spokes(
        _x, _y,
        8,
        17,
        6,
        30,
        1
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Returns a sprite baked from the static Shield Generator body.

function scr_utility_shield_generator_baked_body(_building)
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

    scr_utility_shield_generator_body(
        _preview
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

    return _sprite;
}


/// @description Draws the Shield Generator's moving field effects.

function scr_utility_shield_generator_effects(
    _building,
    _angle = global.vtd.tick * 1.2
)
{
    var _x = _building.x;
    var _y = _building.y;
    var _color = _building.visual.color;

    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // OUTER FIELD CONTAINMENT RING
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        16,
        6,
        35,
        _angle,
        4,
        2
    );


    // ========================================================================
    // INNER FIELD RING
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x, _y,
        11,
        3,
        70,
        -_angle * 1.5,
        5,
        2
    );


    // ========================================================================
    // ROTATING REACTOR DIAMOND
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        8,
        _angle * 2,
        2
    );


    // ========================================================================
    // FIELD PARTICLES
    // ========================================================================

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        29,
        2,
        6,
        -_angle,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Bakes and draws the Shield Generator's moving field effects.

function scr_utility_shield_generator_baked_effects(
    _building,
    _offset_x,
    _offset_y
)
{
    static _sprite = -1;

    if (!sprite_exists(_sprite))
    {
        var _size = 80;
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

        scr_utility_shield_generator_effects(
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
    // ROTATING FIELD SPRITE
    // ========================================================================

    var _spin =
        global.vtd.tick
        * 1.2;

    draw_set_alpha(0.9);

    draw_sprite_ext(
        _sprite,
        0,
        _building.x + _offset_x,
        _building.y + _offset_y,
        1, 1,
        _spin,
        _building.visual.color,
        1
    );


    // ========================================================================
    // LIVE REACTOR PULSE
    // ========================================================================

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 4
            + real(_building.id)
        ) * 0.2;

    draw_set_alpha(_pulse);
    draw_set_color(_building.visual.color);

    draw_circle(
        _building.x + _offset_x,
        _building.y + _offset_y,
        4,
        false
    );

    draw_circle(
        _building.x + _offset_x,
        _building.y + _offset_y,
        2,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}