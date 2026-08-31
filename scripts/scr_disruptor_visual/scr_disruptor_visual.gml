/// @description Draws the complete procedural Disruptor visual.

function scr_tower_visual_disruptor(_tower)
{
    scr_tower_visual_disruptor_body(_tower);
    scr_tower_visual_disruptor_effects(_tower);

    return true;
}

/// @description Draws the static Disruptor body.

function scr_tower_visual_disruptor_body(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    // Armoured octagonal platform.

    scr_enemy_visual_helper_polygon(
        _x, _y,
        21,
        8,
        _angle + 22.5,
        3
    );

    scr_enemy_visual_helper_diamond(
        _x, _y,
        15,
        _angle,
        2
    );

    scr_enemy_visual_helper_radial_ticks(
        _x, _y,
        16,
        6,
        4,
        _angle + 45,
        2
    );

    // Electromagnetic core.

    scr_enemy_visual_helper_polygon(
        _x, _y,
        10,
        6,
        _angle + 30,
        2
    );

    draw_circle(_x, _y, 6, true);
    draw_circle(_x, _y, 3, false);

    // Main emitter housing.

    scr_enemy_visual_helper_local_box(
        _x, _y, _angle,
        5, -7,
        25, 7,
        3
    );

    // Rear stabiliser.

    scr_enemy_visual_helper_local_box(
        _x, _y, _angle,
        -16, -8,
        -7, 8,
        2
    );

    // Forked emitters.

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        22, -7,
        38, -13,
        3
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        22, 7,
        38, 13,
        3
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        25, -5,
        38, -3,
        2
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        25, 5,
        38, 3,
        2
    );

    // Cross-bracing.

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        12, -7,
        21, 7,
        1
    );

    scr_enemy_visual_helper_local_line(
        _x, _y, _angle,
        12, 7,
        21, -7,
        1
    );

    // Disruption nodes.

    var _cos = dcos(_angle);
    var _sin = dsin(_angle);

    var _node_a_x = _x + (38 * _cos) + (-8 * _sin);
    var _node_a_y = _y - (38 * _sin) + (-8 * _cos);

    var _node_b_x = _x + (38 * _cos) + (8 * _sin);
    var _node_b_y = _y - (38 * _sin) + (8 * _cos);

    draw_circle(_node_a_x, _node_a_y, 4, false);
    draw_circle(_node_b_x, _node_b_y, 4, false);

    draw_circle(_node_a_x, _node_a_y, 7, true);
    draw_circle(_node_b_x, _node_b_y, 7, true);

    draw_set_color(c_white);

    return true;
}

/// @description Returns a sprite baked from the static Disruptor body.

function scr_tower_disruptor_baked_body()
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

/// @description Draws the Disruptor's procedural arc effects.

function scr_tower_visual_disruptor_effects(
    _tower,
    _angle = global.vtd.tick * 2.5
)
{
    draw_set_color(_tower.visual.turret_color);

    scr_enemy_visual_helper_arc_segments(
        _tower.x, _tower.y,
        14,
        3,
        65,
        _angle,
        3,
        2
    );

    draw_set_color(c_white);

    return true;
}

/// @description Bakes and draws the Disruptor's rotating arc effects.

function scr_tower_disruptor_baked_effects(
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

        scr_tower_visual_disruptor_effects(_preview, 0);

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
        global.vtd.tick * 2.5,
        _tower.visual.turret_color,
        1
    );

    return true;
}
