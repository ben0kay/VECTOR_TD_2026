/// @description Reusable enemy sprite and primitive drawing functions.


/// @description Draws the standard triangular vector enemy.

function scr_enemy_visual_triangle(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;

    var _front_x =
        _enemy.x + lengthdir_x(_radius, _angle);

    var _front_y =
        _enemy.y + lengthdir_y(_radius, _angle);

    var _back_left_x =
        _enemy.x + lengthdir_x(_radius * 0.8, _angle + 140);

    var _back_left_y =
        _enemy.y + lengthdir_y(_radius * 0.8, _angle + 140);

    var _back_right_x =
        _enemy.x + lengthdir_x(_radius * 0.8, _angle - 140);

    var _back_right_y =
        _enemy.y + lengthdir_y(_radius * 0.8, _angle - 140);


    draw_set_color(_enemy.visual.color);

    draw_triangle(
        _front_x,
        _front_y,
        _back_left_x,
        _back_left_y,
        _back_right_x,
        _back_right_y,
        false
    );


    return true;
}

/// @description Draws the Weak enemy using three overlapping triangular blades.

function scr_enemy_visual_weak(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _x = _enemy.x;
    var _y = _enemy.y;

    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    draw_set_color(_color);


    // ========================================================================
    // FORWARD / HEAD BLADE
    // ========================================================================
    //
    // Still long, but considerably broader through the shoulders.

    scr_enemy_visual_helper_triangle_blade(
        _x,
        _y,
        _angle,

        _radius * 1.50,   // tip length
        _radius * 0.8,   // base distance
        62,               // base spread

        1
    );


    // ========================================================================
    // LEFT REAR BLADE
    // ========================================================================
    //
    // Shorter than the head, but much broader.

    scr_enemy_visual_helper_triangle_blade(
        _x,
        _y,
        _angle + 120,

        _radius * 1.18,
        _radius * 0.60,
        66,

        1
    );


    // ========================================================================
    // RIGHT REAR BLADE
    // ========================================================================

    scr_enemy_visual_helper_triangle_blade(
        _x,
        _y,
        _angle + 240,

        _radius * 1.18,
        _radius * 0.60,
        66,

        1
    );


    // ========================================================================
    // CENTRAL JOINT
    // ========================================================================

    draw_circle(
        _x,
        _y,
        1.5,
        true
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the Hunter enemy using three overlapping triangular blades.

function scr_enemy_visual_hunter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _x = _enemy.x;
    var _y = _enemy.y;

    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    draw_set_color(_color);


    // ========================================================================
    // FORWARD / HEAD BLADE
    // ========================================================================

    scr_enemy_visual_helper_triangle_blade(
        _x,
        _y,
        _angle,

        _radius * 1.50,
        _radius * 0.80,
        62,

        1
    );


    // ========================================================================
    // LEFT REAR BLADE
    // ========================================================================

    scr_enemy_visual_helper_triangle_blade(
        _x,
        _y,
        _angle + 120,

        _radius * 1.18,
        _radius * 0.60,
        66,

        1
    );


    // ========================================================================
    // RIGHT REAR BLADE
    // ========================================================================

    scr_enemy_visual_helper_triangle_blade(
        _x,
        _y,
        _angle + 240,

        _radius * 1.18,
        _radius * 0.60,
        66,

        1
    );


    // ========================================================================
    // CENTRAL JOINT
    // ========================================================================

    draw_circle(
        _x,
        _y,
        1.5,
        true
    );


    draw_set_color(c_white);

    return true;
}


/// @description Draws the rotating circular kamikaze enemy.

function scr_enemy_visual_kamikaze(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;


    // Instance offset prevents every kamikaze rotating in sync.

    var _spin =
        (
            global.vtd.tick * 6
            + real(_enemy.id)
        )
        mod 360;


    // ========================================================================
    // OUTER BODY
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(_enemy.visual.color);


    // Main circular outline.

    draw_circle(
        _x,
        _y,
        _radius,
        true
    );


    // Inner structural ring.

    draw_circle(
        _x,
        _y,
        _radius * 0.72,
        true
    );


    // ========================================================================
    // ROTATING ARMS
    // ========================================================================

    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        _radius * 0.72,
        _radius * 0.28,
        4,
        _spin,
        3
    );


    // ========================================================================
    // ROTATING INNER DIAMOND
    // ========================================================================

    draw_set_color(c_white);

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.48,
        _spin,
        2
    );


    // ========================================================================
    // EXPLOSIVE CORE
    // ========================================================================

    draw_set_color(_enemy.visual.color);

    draw_circle(
        _x,
        _y,
        _radius * 0.25,
        true
    );


    // Small rotating spokes between the core and diamond.

    scr_enemy_visual_helper_spokes(
        _x,
        _y,
        _radius * 0.27,
        _radius * 0.43,
        4,
        _spin + 45,
        1
    );


    // ========================================================================
    // CENTER
    // ========================================================================

    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        max(
            1.5,
            _radius * 0.07
        ),
        false
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws an enemy sprite or falls back to its primitive function.

function scr_enemy_visual_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _visual =
        _enemy.visual;


    // A supplied sprite takes priority over primitive drawing.
    // Custom visual scale is deliberately independent from image_xscale
    // and image_yscale.

    if (
        _visual.sprite != -1
        && sprite_exists(_visual.sprite)
    )
    {
        draw_sprite_ext(
            _visual.sprite,
            _enemy.image_index,
            _enemy.x,
            _enemy.y,
            _visual.scale_x,
            _visual.scale_y,
            _visual.draw_angle,
            _visual.color,
            1
        );

        return true;
    }


    // Primitive vector renderer used while no sprite is assigned.

    if (!is_undefined(_visual.draw_function))
    {
        _visual.draw_function(_enemy);
        return true;
    }


    return false;
}


/// @description Draws an enemy's health, natural shield and support shield bars.

function scr_enemy_health_bar_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _hp =
        _enemy.vitals.hp;

    var _shield =
        _enemy.vitals.shield;

    var _support =
        _shield.support;


    // ========================================================================
    // BAR VISIBILITY
    // ========================================================================
    //
    // Do not draw any bars for a completely untouched enemy.
    //
    // However, if either shield is visible, the health bar is also drawn
    // underneath it so the shield bars never appear to float by themselves.

    var _health_damaged =
        _hp.current
        < _hp.maximum;


    var _natural_shield_visible =
        _shield.enabled
        && _shield.maximum > 0
        && _shield.current > 0;


    var _support_shield_visible =
        _support.enabled
        && _support.maximum > 0
        && _support.current > 0;


    if (
        !_health_damaged
        && !_natural_shield_visible
        && !_support_shield_visible
    )
    {
        return true;
    }


    // ========================================================================
    // SHARED GEOMETRY
    // ========================================================================

    var _radius =
        _enemy.visual.radius;

    var _hover =
        scr_enemy_visual_hover_offset_get(
            _enemy
        );

    var _bar_width =
        _radius * 2;

    var _bar_left =
        _enemy.x
        - _radius;

    var _hp_bar_top =
        _enemy.y
        + _hover
        - _radius
        - 8;


    // ========================================================================
    // NATURAL SHIELD BAR
    // ========================================================================

    if (_natural_shield_visible)
    {
        var _shield_percent =
            clamp(
                _shield.current
                / _shield.maximum,
                0,
                1
            );


        var _shield_bar_top =
            _hp_bar_top
            - 4;


        draw_set_color(
            c_dkgray
        );


        draw_rectangle(
            _bar_left,
            _shield_bar_top,
            _bar_left + _bar_width,
            _shield_bar_top + 2,
            false
        );


        draw_set_color(
            _shield.color
        );


        draw_rectangle(
            _bar_left,
            _shield_bar_top,
            _bar_left
            + (
                _bar_width
                * _shield_percent
            ),
            _shield_bar_top + 2,
            false
        );
    }


    // ========================================================================
    // TEMPORARY SUPPORT SHIELD BAR
    // ========================================================================

    if (_support_shield_visible)
    {
        var _support_percent =
            clamp(
                _support.current
                / _support.maximum,
                0,
                1
            );


        var _support_bar_top =
            _hp_bar_top
            - 4;


        if (_natural_shield_visible)
        {
            _support_bar_top -=
                4;
        }


        draw_set_color(
            c_dkgray
        );


        draw_rectangle(
            _bar_left,
            _support_bar_top,
            _bar_left + _bar_width,
            _support_bar_top + 2,
            false
        );


        draw_set_color(
            _support.color
        );


        draw_rectangle(
            _bar_left,
            _support_bar_top,
            _bar_left
            + (
                _bar_width
                * _support_percent
            ),
            _support_bar_top + 2,
            false
        );
    }


    // ========================================================================
    // HEALTH BAR
    // ========================================================================
    //
    // Once any bar is relevant, health remains the bottom baseline even
    // when HP itself is still full.

    var _hp_percent =
        clamp(
            _hp.current
            / max(
                1,
                _hp.maximum
            ),
            0,
            1
        );


    draw_set_color(
        c_dkgray
    );


    draw_rectangle(
        _bar_left,
        _hp_bar_top,
        _bar_left + _bar_width,
        _hp_bar_top + 3,
        false
    );


    draw_set_color(
        c_red
    );


    draw_rectangle(
        _bar_left,
        _hp_bar_top,
        _bar_left
        + (
            _bar_width
            * _hp_percent
        ),
        _hp_bar_top + 3,
        false
    );


    draw_set_color(
        c_white
    );


    return true;
}
/// @description Draws the large triangular Splitter enemy.

function scr_enemy_visual_splitter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _color =
        _enemy.visual.color;


    draw_set_color(_color);
    draw_set_alpha(1);


    // ========================================================================
    // OUTER TRIANGULAR HULL
    // ========================================================================

    // Forward nose.
    var _nose_x =
        _x
        + lengthdir_x(
            _radius * 1.15,
            _angle
        );

    var _nose_y =
        _y
        + lengthdir_y(
            _radius * 1.15,
            _angle
        );


    // Swept upper-rear point.
    var _upper_x =
        _x
        + lengthdir_x(
            _radius * 1.00,
            _angle + 138
        );

    var _upper_y =
        _y
        + lengthdir_y(
            _radius * 1.00,
            _angle + 138
        );


    // Swept lower-rear point.
    var _lower_x =
        _x
        + lengthdir_x(
            _radius * 1.00,
            _angle - 138
        );

    var _lower_y =
        _y
        + lengthdir_y(
            _radius * 1.00,
            _angle - 138
        );


    draw_line_width(
        _nose_x,
        _nose_y,
        _upper_x,
        _upper_y,
        3
    );

    draw_line_width(
        _upper_x,
        _upper_y,
        _lower_x,
        _lower_y,
        3
    );

    draw_line_width(
        _lower_x,
        _lower_y,
        _nose_x,
        _nose_y,
        3
    );


    // ========================================================================
    // OUTER ARMOUR FINS
    // ========================================================================

    var _nose_inner_x =
        _x
        + lengthdir_x(
            _radius * 0.72,
            _angle
        );

    var _nose_inner_y =
        _y
        + lengthdir_y(
            _radius * 0.72,
            _angle
        );


    var _upper_tip_x =
        _x
        + lengthdir_x(
            _radius * 1.20,
            _angle + 150
        );

    var _upper_tip_y =
        _y
        + lengthdir_y(
            _radius * 1.20,
            _angle + 150
        );


    var _lower_tip_x =
        _x
        + lengthdir_x(
            _radius * 1.20,
            _angle - 150
        );

    var _lower_tip_y =
        _y
        + lengthdir_y(
            _radius * 1.20,
            _angle - 150
        );


    // Upper swept blade.
    draw_line_width(
        _upper_x,
        _upper_y,
        _upper_tip_x,
        _upper_tip_y,
        3
    );

    draw_line_width(
        _upper_tip_x,
        _upper_tip_y,
        _nose_inner_x,
        _nose_inner_y,
        2
    );


    // Lower swept blade.
    draw_line_width(
        _lower_x,
        _lower_y,
        _lower_tip_x,
        _lower_tip_y,
        3
    );

    draw_line_width(
        _lower_tip_x,
        _lower_tip_y,
        _nose_inner_x,
        _nose_inner_y,
        2
    );


    // ========================================================================
    // INNER TRIANGULAR ARMOUR
    // ========================================================================

    var _inner_front_x =
        _x
        + lengthdir_x(
            _radius * 0.56,
            _angle
        );

    var _inner_front_y =
        _y
        + lengthdir_y(
            _radius * 0.56,
            _angle
        );


    var _inner_upper_x =
        _x
        + lengthdir_x(
            _radius * 0.48,
            _angle + 135
        );

    var _inner_upper_y =
        _y
        + lengthdir_y(
            _radius * 0.48,
            _angle + 135
        );


    var _inner_lower_x =
        _x
        + lengthdir_x(
            _radius * 0.48,
            _angle - 135
        );

    var _inner_lower_y =
        _y
        + lengthdir_y(
            _radius * 0.48,
            _angle - 135
        );


    draw_line_width(
        _inner_front_x,
        _inner_front_y,
        _inner_upper_x,
        _inner_upper_y,
        2
    );

    draw_line_width(
        _inner_upper_x,
        _inner_upper_y,
        _inner_lower_x,
        _inner_lower_y,
        2
    );

    draw_line_width(
        _inner_lower_x,
        _inner_lower_y,
        _inner_front_x,
        _inner_front_y,
        2
    );


    // ========================================================================
    // INNER ARMOUR RAILS
    // ========================================================================

    var _rail_upper_a_x =
        _x
        + lengthdir_x(
            _radius * 0.70,
            _angle + 155
        );

    var _rail_upper_a_y =
        _y
        + lengthdir_y(
            _radius * 0.70,
            _angle + 155
        );


    var _rail_upper_b_x =
        _x
        + lengthdir_x(
            _radius * 0.80,
            _angle + 115
        );

    var _rail_upper_b_y =
        _y
        + lengthdir_y(
            _radius * 0.80,
            _angle + 115
        );


    var _rail_lower_a_x =
        _x
        + lengthdir_x(
            _radius * 0.70,
            _angle - 155
        );

    var _rail_lower_a_y =
        _y
        + lengthdir_y(
            _radius * 0.70,
            _angle - 155
        );


    var _rail_lower_b_x =
        _x
        + lengthdir_x(
            _radius * 0.80,
            _angle - 115
        );

    var _rail_lower_b_y =
        _y
        + lengthdir_y(
            _radius * 0.80,
            _angle - 115
        );


    draw_line_width(
        _rail_upper_a_x,
        _rail_upper_a_y,
        _rail_upper_b_x,
        _rail_upper_b_y,
        2
    );

    draw_line_width(
        _rail_lower_a_x,
        _rail_lower_a_y,
        _rail_lower_b_x,
        _rail_lower_b_y,
        2
    );


    // ========================================================================
    // CENTRAL SPLIT CORE
    // ========================================================================

    var _core_front_x =
        _x
        + lengthdir_x(
            _radius * 0.27,
            _angle
        );

    var _core_front_y =
        _y
        + lengthdir_y(
            _radius * 0.27,
            _angle
        );


    var _core_upper_x =
        _x
        + lengthdir_x(
            _radius * 0.23,
            _angle + 135
        );

    var _core_upper_y =
        _y
        + lengthdir_y(
            _radius * 0.23,
            _angle + 135
        );


    var _core_lower_x =
        _x
        + lengthdir_x(
            _radius * 0.23,
            _angle - 135
        );

    var _core_lower_y =
        _y
        + lengthdir_y(
            _radius * 0.23,
            _angle - 135
        );


    draw_line_width(
        _core_front_x,
        _core_front_y,
        _core_upper_x,
        _core_upper_y,
        3
    );

    draw_line_width(
        _core_upper_x,
        _core_upper_y,
        _core_lower_x,
        _core_lower_y,
        3
    );

    draw_line_width(
        _core_lower_x,
        _core_lower_y,
        _core_front_x,
        _core_front_y,
        3
    );


    // ========================================================================
    // FOUR SPLIT NODES
    // ========================================================================

    var _node_distance =
        _radius * 0.48;

    var _node_size =
        max(
            1.5,
            _radius * 0.07
        );


    for (var i = 0; i < 4; ++i)
    {
        var _node_angle =
            _angle
            + (i * 90);

        var _node_x =
            _x
            + lengthdir_x(
                _node_distance,
                _node_angle
            );

        var _node_y =
            _y
            + lengthdir_y(
                _node_distance,
                _node_angle
            );


        var _node_front_x =
            _node_x
            + lengthdir_x(
                _node_size,
                _node_angle
            );

        var _node_front_y =
            _node_y
            + lengthdir_y(
                _node_size,
                _node_angle
            );


        var _node_left_x =
            _node_x
            + lengthdir_x(
                _node_size,
                _node_angle + 90
            );

        var _node_left_y =
            _node_y
            + lengthdir_y(
                _node_size,
                _node_angle + 90
            );


        var _node_back_x =
            _node_x
            + lengthdir_x(
                _node_size,
                _node_angle + 180
            );

        var _node_back_y =
            _node_y
            + lengthdir_y(
                _node_size,
                _node_angle + 180
            );


        var _node_right_x =
            _node_x
            + lengthdir_x(
                _node_size,
                _node_angle - 90
            );

        var _node_right_y =
            _node_y
            + lengthdir_y(
                _node_size,
                _node_angle - 90
            );


        draw_line(
            _node_front_x,
            _node_front_y,
            _node_left_x,
            _node_left_y
        );

        draw_line(
            _node_left_x,
            _node_left_y,
            _node_back_x,
            _node_back_y
        );

        draw_line(
            _node_back_x,
            _node_back_y,
            _node_right_x,
            _node_right_y
        );

        draw_line(
            _node_right_x,
            _node_right_y,
            _node_front_x,
            _node_front_y
        );
    }


    // ========================================================================
    // CENTRAL GLOW
    // ========================================================================

    var _pulse =
        0.45
        + sin(
            (global.vtd.tick * 4)
            + real(_enemy.id)
        )
        * 0.15;


    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        max(
            2,
            _radius * 0.12
        ),
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}


/// @description Draws one small brainless splitter shard.

function scr_enemy_visual_splitter_child(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;

    var _front_x = _enemy.x + lengthdir_x(_radius, _angle);
    var _front_y = _enemy.y + lengthdir_y(_radius, _angle);

    var _left_x =
        _enemy.x + lengthdir_x(_radius * 0.8, _angle + 145);

    var _left_y =
        _enemy.y + lengthdir_y(_radius * 0.8, _angle + 145);

    var _right_x =
        _enemy.x + lengthdir_x(_radius * 0.8, _angle - 145);

    var _right_y =
        _enemy.y + lengthdir_y(_radius * 0.8, _angle - 145);


    draw_set_color(_enemy.visual.color);

    draw_triangle(
        _front_x,
        _front_y,
        _left_x,
        _left_y,
        _right_x,
        _right_y,
        false
    );


    draw_line_width(
        _enemy.x,
        _enemy.y,
        _enemy.x + lengthdir_x(_radius * 0.65, _angle),
        _enemy.y + lengthdir_y(_radius * 0.65, _angle),
        2
    );


    return true;
}

/// @description Returns the visual hover offset for one flying enemy.

function scr_enemy_visual_hover_offset_get(_enemy)
{
    if (!instance_exists(_enemy))
        return 0;

    if (_enemy.movement.layer != EnemyMovementLayer.FLYING)
        return 0;

    return -12 + sin(
        (global.vtd.tick * 1.2)
        + real(_enemy.id)
    ) * 1.5;
}


/// @description Draws a visibly hovering flying drone.

function scr_enemy_visual_flyer(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;

    var _hover =
        scr_enemy_visual_hover_offset_get(_enemy);

    var _draw_x = _enemy.x;
    var _draw_y = _enemy.y + _hover;


    // ========================================================================
    // GROUND SHADOW
    // ========================================================================

    var _shadow_scale =
    0.75
    + sin(
        (global.vtd.tick * 1.2)
        + real(_enemy.id)
    ) * 0.03;

    draw_set_alpha(0.22);
    draw_set_color(c_black);

    draw_ellipse(
        _enemy.x - (_radius * _shadow_scale),
        _enemy.y + 7 - (_radius * 0.28),
        _enemy.x + (_radius * _shadow_scale),
        _enemy.y + 7 + (_radius * 0.28),
        false
    );


    // ========================================================================
    // VECTOR AIRFRAME
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(_enemy.visual.color);

    var _front_x =
        _draw_x + lengthdir_x(_radius, _angle);

    var _front_y =
        _draw_y + lengthdir_y(_radius, _angle);

    var _back_x =
        _draw_x + lengthdir_x(_radius * 0.75, _angle + 180);

    var _back_y =
        _draw_y + lengthdir_y(_radius * 0.75, _angle + 180);

    var _left_x =
        _draw_x + lengthdir_x(_radius * 1.15, _angle + 90);

    var _left_y =
        _draw_y + lengthdir_y(_radius * 1.15, _angle + 90);

    var _right_x =
        _draw_x + lengthdir_x(_radius * 1.15, _angle - 90);

    var _right_y =
        _draw_y + lengthdir_y(_radius * 1.15, _angle - 90);


    draw_line_width(_front_x, _front_y, _left_x, _left_y, 2);
    draw_line_width(_left_x, _left_y, _back_x, _back_y, 2);
    draw_line_width(_back_x, _back_y, _right_x, _right_y, 2);
    draw_line_width(_right_x, _right_y, _front_x, _front_y, 2);

    draw_line_width(_left_x, _left_y, _right_x, _right_y, 2);


    // Inner engine ring.

    draw_circle(
        _draw_x,
        _draw_y,
        _radius * 0.38,
        false
    );

    draw_set_color(c_white);

    draw_circle(
        _draw_x,
        _draw_y,
        2,
        true
    );


    // Small downward altitude markers.

    draw_set_color(_enemy.visual.color);

    draw_line(
        _draw_x - 5,
        _draw_y + _radius * 0.55,
        _draw_x - 2,
        _draw_y + _radius * 0.85
    );

    draw_line(
        _draw_x + 5,
        _draw_y + _radius * 0.55,
        _draw_x + 2,
        _draw_y + _radius * 0.85
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the large armoured-looking Heavy Brute.

function scr_enemy_visual_brute(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    draw_set_color(_color);


    // Heavy hexagonal chassis.

    for (var i = 0; i < 6; ++i)
    {
        var _a1 = _angle + (i * 60);
        var _a2 = _angle + (((i + 1) mod 6) * 60);

        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),
            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),
            3
        );
    }


    // Forward crushing wedge.

    draw_line_width(
        _x + lengthdir_x(_radius * 0.4, _angle + 90),
        _y + lengthdir_y(_radius * 0.4, _angle + 90),
        _x + lengthdir_x(_radius * 1.15, _angle),
        _y + lengthdir_y(_radius * 1.15, _angle),
        3
    );

    draw_line_width(
        _x + lengthdir_x(_radius * 0.4, _angle - 90),
        _y + lengthdir_y(_radius * 0.4, _angle - 90),
        _x + lengthdir_x(_radius * 1.15, _angle),
        _y + lengthdir_y(_radius * 1.15, _angle),
        3
    );


    // Dense central core.

    draw_circle(_x, _y, _radius * 0.4, false);
    draw_circle(_x, _y, 4, true);

    draw_set_color(c_white);

    return true;
}

/// @description Draws the large cargo-carrying Transporter.

function scr_enemy_visual_transporter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    draw_set_color(_color);


    // Rotating outer cargo frame.

    for (var i = 0; i < 4; ++i)
    {
        var _a1 = _angle + 45 + (i * 90);
        var _a2 = _angle + 45 + (((i + 1) mod 4) * 90);

        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),
            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),
            3
        );
    }


    // Internal cargo pods.

    for (var i = 0; i < 4; ++i)
    {
        var _pod_angle =
            _angle + 45 + (i * 90);

        var _pod_x =
            _x + lengthdir_x(
                _radius * 0.55,
                _pod_angle
            );

        var _pod_y =
            _y + lengthdir_y(
                _radius * 0.55,
                _pod_angle
            );

        draw_circle(
            _pod_x,
            _pod_y,
            5,
            false
        );
    }


    draw_circle(
        _x,
        _y,
        _radius * 0.35,
        false
    );

    draw_set_color(c_white);

    return true;
}

/// @description Draws the hovering orbiting Gunship as a broad swept-wing craft.

function scr_enemy_visual_gunship(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _hover =
        scr_enemy_visual_hover_offset_get(_enemy);


    var _x =
        _enemy.x;

    var _y =
        _enemy.y + _hover;

    var _color =
        _enemy.visual.color;


    // ========================================================================
    // GROUND SHADOW
    // ========================================================================

    var _shadow_scale =
        0.82
        + sin(
            (global.vtd.tick * 1.2)
            + real(_enemy.id)
        ) * 0.025;


    draw_set_alpha(0.18);
    draw_set_color(c_black);


    draw_ellipse(
        _enemy.x - (_radius * 1.45 * _shadow_scale),
        _enemy.y + 4,

        _enemy.x + (_radius * 1.45 * _shadow_scale),
        _enemy.y + 12,

        false
    );


    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // LEFT WING
    // ========================================================================

    var _left_wing =
    [
        [ _radius * 0.18, -_radius * 0.24 ],
        [ _radius * 0.48, -_radius * 0.72 ],
        [ _radius * 0.18, -_radius * 1.10 ],
        [ -_radius * 0.40, -_radius * 1.55 ],
        [ -_radius * 0.72, -_radius * 1.48 ],
        [ -_radius * 0.48, -_radius * 0.92 ],
        [ -_radius * 0.12, -_radius * 0.38 ]
    ];


    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _left_wing,
        1
    );


    // ========================================================================
    // RIGHT WING
    // ========================================================================

    var _right_wing =
    [
        [ _radius * 0.18,  _radius * 0.24 ],
        [ _radius * 0.48,  _radius * 0.72 ],
        [ _radius * 0.18,  _radius * 1.10 ],
        [ -_radius * 0.40,  _radius * 1.55 ],
        [ -_radius * 0.72,  _radius * 1.48 ],
        [ -_radius * 0.48,  _radius * 0.92 ],
        [ -_radius * 0.12,  _radius * 0.38 ]
    ];


    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _right_wing,
        1
    );


    // ========================================================================
    // LEFT INNER WING STRUCTURE
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

         _radius * 0.22,
        -_radius * 0.36,

        -_radius * 0.38,
        -_radius * 1.30,

        1
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -_radius * 0.38,
        -_radius * 1.30,

        -_radius * 0.18,
        -_radius * 0.72,

        1
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -_radius * 0.18,
        -_radius * 0.72,

         _radius * 0.22,
        -_radius * 0.36,

        1
    );


    // ========================================================================
    // RIGHT INNER WING STRUCTURE
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

         _radius * 0.22,
         _radius * 0.36,

        -_radius * 0.38,
         _radius * 1.30,

        1
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -_radius * 0.38,
         _radius * 1.30,

        -_radius * 0.18,
         _radius * 0.72,

        1
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -_radius * 0.18,
         _radius * 0.72,

         _radius * 0.22,
         _radius * 0.36,

        1
    );


    // ========================================================================
    // CENTRAL FUSELAGE
    // ========================================================================

    var _body =
    [
        [  _radius * 1.15,  0 ],
        [  _radius * 0.20, -_radius * 0.43 ],
        [ -_radius * 0.72,  0 ],
        [  _radius * 0.20,  _radius * 0.43 ]
    ];


    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _body,
        2
    );


    // ========================================================================
    // CENTRAL INNER DIAMOND
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.34,
        _angle,
        1
    );


    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.18,
        _angle,
        1
    );


    // ========================================================================
    // FORWARD SPINE
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        _radius * 0.18,
        0,

        _radius * 1.05,
        0,

        1
    );


    // ========================================================================
    // SMALL REAR ENGINE DETAILS
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -_radius * 0.28,
        -_radius * 0.20,

        -_radius * 0.66,
        -_radius * 0.34,

        1
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -_radius * 0.28,
         _radius * 0.20,

        -_radius * 0.66,
         _radius * 0.34,

        1
    );


    // ========================================================================
    // CENTRAL CORE
    // ========================================================================

    draw_circle(
        _x,
        _y,
        2,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the enemy Shield Generator support unit.

function scr_enemy_visual_shield_generator(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    var _pulse =
        0.65
        + dsin(
            (global.vtd.tick * 4)
            + real(_enemy.id)
        ) * 0.25;


    draw_set_color(_color);


    // Rotating outer support frame.

    for (var i = 0; i < 6; ++i)
    {
        var _a1 =
            _angle
            + 30
            + (i * 60);

        var _a2 =
            _angle
            + 30
            + (((i + 1) mod 6) * 60);

        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),
            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),
            3
        );
    }


    // Energy spokes.

    for (var i = 0; i < 3; ++i)
    {
        var _spoke_angle =
            _angle
            + (i * 120);

        draw_line_width(
            _x,
            _y,
            _x + lengthdir_x(_radius * 0.75, _spoke_angle),
            _y + lengthdir_y(_radius * 0.75, _spoke_angle),
            2
        );
    }


    // Pulsing shield core.

    draw_set_alpha(_pulse);
    draw_circle(_x, _y, _radius * 0.4, false);

    draw_set_alpha(1);
    draw_circle(_x, _y, _radius * 0.18, true);

    draw_set_color(c_white);

    return true;
}

/// @description Draws the mobile continuous-beam siege tank.

function scr_enemy_visual_siege_beam(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x = _enemy.x;
    var _y = _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _hull_angle =
        _enemy.visual.hull_angle;

    var _turret_angle =
        _enemy.visual.turret_angle;

    var _color =
        _enemy.visual.color;


    // ========================================================================
    // HULL
    // ========================================================================

    draw_set_color(_color);


    // Armoured hexagonal chassis.

    for (var i = 0; i < 6; ++i)
    {
        var _a1 =
            _hull_angle
            + 30
            + (i * 60);

        var _a2 =
            _hull_angle
            + 30
            + (((i + 1) mod 6) * 60);

        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),

            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),

            3
        );
    }


    // Track lines make hull rotation obvious.

    var _track_side_x =
        lengthdir_x(
            _radius * 0.62,
            _hull_angle + 90
        );

    var _track_side_y =
        lengthdir_y(
            _radius * 0.62,
            _hull_angle + 90
        );

    var _track_front_x =
        lengthdir_x(
            _radius * 0.68,
            _hull_angle
        );

    var _track_front_y =
        lengthdir_y(
            _radius * 0.68,
            _hull_angle
        );


    draw_line_width(
        _x + _track_side_x - _track_front_x,
        _y + _track_side_y - _track_front_y,

        _x + _track_side_x + _track_front_x,
        _y + _track_side_y + _track_front_y,

        5
    );

    draw_line_width(
        _x - _track_side_x - _track_front_x,
        _y - _track_side_y - _track_front_y,

        _x - _track_side_x + _track_front_x,
        _y - _track_side_y + _track_front_y,

        5
    );


    // Hull direction marker.

    draw_line_width(
        _x,
        _y,

        _x + lengthdir_x(
            _radius * 0.55,
            _hull_angle
        ),

        _y + lengthdir_y(
            _radius * 0.55,
            _hull_angle
        ),

        2
    );


    // ========================================================================
    // TURRET
    // ========================================================================

    draw_circle(
        _x,
        _y,
        _radius * 0.46,
        false
    );

    draw_circle(
        _x,
        _y,
        _radius * 0.22,
        true
    );


    var _turret_side_x =
        lengthdir_x(
            7,
            _turret_angle + 90
        );

    var _turret_side_y =
        lengthdir_y(
            7,
            _turret_angle + 90
        );

    var _muzzle_x =
        _x + lengthdir_x(
            _radius * 1.22,
            _turret_angle
        );

    var _muzzle_y =
        _y + lengthdir_y(
            _radius * 1.22,
            _turret_angle
        );


    draw_line_width(
        _x + _turret_side_x,
        _y + _turret_side_y,

        _muzzle_x + _turret_side_x,
        _muzzle_y + _turret_side_y,

        4
    );

    draw_line_width(
        _x - _turret_side_x,
        _y - _turret_side_y,

        _muzzle_x - _turret_side_x,
        _muzzle_y - _turret_side_y,

        4
    );

    draw_line_width(
        _muzzle_x + _turret_side_x,
        _muzzle_y + _turret_side_y,

        _muzzle_x - _turret_side_x,
        _muzzle_y - _turret_side_y,

        3
    );


    // ========================================================================
    // CONTINUOUS BEAM
    // ========================================================================

    if (
        _enemy.EnemyState
            == EnemyState.ATTACKING
        && instance_exists(
            _enemy.targeting.target
        )
    )
    {
        var _target =
            _enemy.targeting.target;

        var _beam =
            _enemy.enemy_data
                .ability_data
                .beam;

        var _flicker =
            dsin(
                (global.vtd.tick * 28)
                + real(_enemy.id)
            )
            * 2;


        draw_set_alpha(0.35);
        draw_set_color(_beam.color);

        draw_line_width(
            _muzzle_x,
            _muzzle_y,
            _target.x,
            _target.y,
            _beam.width + 6
        );


        draw_set_alpha(0.9);

        draw_line_width(
            _muzzle_x,
            _muzzle_y,
            _target.x + _flicker,
            _target.y - _flicker,
            _beam.width
        );


        draw_set_alpha(1);
        draw_set_color(
            _beam.inner_color
        );

        draw_line_width(
            _muzzle_x,
            _muzzle_y,
            _target.x,
            _target.y,
            1
        );


        // FUTURE:
        // beam embers
        // heat particles
        // impact sparks
        // scorch marks
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the heavy explosive-rocket siege platform.

function scr_enemy_visual_siege_rocket(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;


    draw_set_color(_color);


    // Broad octagonal siege chassis.

    for (var i = 0; i < 8; ++i)
    {
        var _a1 = _angle + 22.5 + (i * 45);
        var _a2 = _angle + 22.5 + (((i + 1) mod 8) * 45);

        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),
            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),
            3
        );
    }


    // Armoured inner ring.

    draw_circle(
        _x,
        _y,
        _radius * 0.58,
        false
    );


    // Large forward launch tube.

    var _side_x = lengthdir_x(10, _angle + 90);
    var _side_y = lengthdir_y(10, _angle + 90);

    var _back_x = _x + lengthdir_x(12, _angle + 180);
    var _back_y = _y + lengthdir_y(12, _angle + 180);

    var _front_x = _x + lengthdir_x(_radius * 1.25, _angle);
    var _front_y = _y + lengthdir_y(_radius * 1.25, _angle);


    draw_line_width(
        _back_x + _side_x,
        _back_y + _side_y,
        _front_x + _side_x,
        _front_y + _side_y,
        4
    );

    draw_line_width(
        _back_x - _side_x,
        _back_y - _side_y,
        _front_x - _side_x,
        _front_y - _side_y,
        4
    );

    draw_line_width(
        _front_x + _side_x,
        _front_y + _side_y,
        _front_x - _side_x,
        _front_y - _side_y,
        4
    );


    // Volatile warhead indicator.

    var _pulse =
        0.6
        + dsin(
            (global.vtd.tick * 6)
            + real(_enemy.id)
        ) * 0.3;

    draw_set_alpha(_pulse);
    draw_circle(_x, _y, 8, true);


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the Centipede head as an angular armoured square unit.

function scr_enemy_visual_centipede_head(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    draw_set_color(_color);


    // ========================================================================
    // OUTER ARMOURED CHASSIS
    // ========================================================================

    scr_enemy_visual_helper_square(
        _x,
        _y,
        _radius,
        _angle,
        2
    );


    // ========================================================================
    // INNER DIAMOND CORE
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.52,
        _angle,
        1
    );


    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.22,
        _angle,
        1
    );


    // ========================================================================
    // FORWARD ARMOURED WEDGE
    // ========================================================================

    var _front_x =
        _x
        + lengthdir_x(
            _radius * 1.32,
            _angle
        );

    var _front_y =
        _y
        + lengthdir_y(
            _radius * 1.32,
            _angle
        );


    var _front_left_x =
        _x
        + lengthdir_x(
            _radius * 0.72,
            _angle + 42
        );

    var _front_left_y =
        _y
        + lengthdir_y(
            _radius * 0.72,
            _angle + 42
        );


    var _front_right_x =
        _x
        + lengthdir_x(
            _radius * 0.72,
            _angle - 42
        );

    var _front_right_y =
        _y
        + lengthdir_y(
            _radius * 0.72,
            _angle - 42
        );


    scr_enemy_visual_helper_triangle(
        _front_x,
        _front_y,

        _front_left_x,
        _front_left_y,

        _front_right_x,
        _front_right_y,

        2
    );


    // ========================================================================
    // MANDIBLES
    // ========================================================================

    var _mandible_left_x =
        _x
        + lengthdir_x(
            _radius * 1.55,
            _angle + 22
        );

    var _mandible_left_y =
        _y
        + lengthdir_y(
            _radius * 1.55,
            _angle + 22
        );


    var _mandible_right_x =
        _x
        + lengthdir_x(
            _radius * 1.55,
            _angle - 22
        );

    var _mandible_right_y =
        _y
        + lengthdir_y(
            _radius * 1.55,
            _angle - 22
        );


    draw_line_width(
        _front_left_x,
        _front_left_y,
        _mandible_left_x,
        _mandible_left_y,
        2
    );


    draw_line_width(
        _front_right_x,
        _front_right_y,
        _mandible_right_x,
        _mandible_right_y,
        2
    );


    // Small inward hooks.

    draw_line_width(
        _mandible_left_x,
        _mandible_left_y,

        _x + lengthdir_x(
            _radius * 1.32,
            _angle + 8
        ),

        _y + lengthdir_y(
            _radius * 1.32,
            _angle + 8
        ),

        1
    );


    draw_line_width(
        _mandible_right_x,
        _mandible_right_y,

        _x + lengthdir_x(
            _radius * 1.32,
            _angle - 8
        ),

        _y + lengthdir_y(
            _radius * 1.32,
            _angle - 8
        ),

        1
    );


    // ========================================================================
    // SIDE ARMOUR FINS
    // ========================================================================

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _side_angle =
            _angle
            + (_side * 90);


        var _inner_x =
            _x
            + lengthdir_x(
                _radius * 0.72,
                _side_angle
            );

        var _inner_y =
            _y
            + lengthdir_y(
                _radius * 0.72,
                _side_angle
            );


        var _outer_x =
            _x
            + lengthdir_x(
                _radius * 1.22,
                _side_angle
            );

        var _outer_y =
            _y
            + lengthdir_y(
                _radius * 1.22,
                _side_angle
            );


        draw_line_width(
            _inner_x,
            _inner_y,
            _outer_x,
            _outer_y,
            2
        );


        draw_line_width(
            _outer_x,
            _outer_y,

            _x + lengthdir_x(
                _radius * 0.72,
                _side_angle + 35
            ),

            _y + lengthdir_y(
                _radius * 0.72,
                _side_angle + 35
            ),

            1
        );
    }


    // ========================================================================
    // CENTRAL ENERGY POINT
    // ========================================================================

    draw_circle(
        _x,
        _y,
        2,
        true
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws one Centipede child as an angular armoured segment.

function scr_enemy_visual_centipede_child(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    draw_set_color(_color);


    // ========================================================================
    // MAIN SQUARE SEGMENT
    // ========================================================================

    scr_enemy_visual_helper_square(
        _x,
        _y,
        _radius,
        _angle,
        2
    );


    // ========================================================================
    // INNER ARMOUR DIAMOND
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        _radius * 0.52,
        _angle,
        1
    );


    // ========================================================================
    // FORWARD SPINE
    // ========================================================================

    draw_line_width(
        _x,
        _y,

        _x + lengthdir_x(
            _radius * 0.82,
            _angle
        ),

        _y + lengthdir_y(
            _radius * 0.82,
            _angle
        ),

        1
    );


    // ========================================================================
    // SIDE ARMOUR / LEGS
    // ========================================================================

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _side_angle =
            _angle
            + (_side * 90);


        var _root_x =
            _x
            + lengthdir_x(
                _radius * 0.65,
                _side_angle
            );

        var _root_y =
            _y
            + lengthdir_y(
                _radius * 0.65,
                _side_angle
            );


        var _joint_x =
            _x
            + lengthdir_x(
                _radius * 1.15,
                _side_angle
            );

        var _joint_y =
            _y
            + lengthdir_y(
                _radius * 1.15,
                _side_angle
            );


        var _tip_x =
            _joint_x
            + lengthdir_x(
                _radius * 0.42,
                _angle + 180
            );

        var _tip_y =
            _joint_y
            + lengthdir_y(
                _radius * 0.42,
                _angle + 180
            );


        draw_line_width(
            _root_x,
            _root_y,
            _joint_x,
            _joint_y,
            1
        );


        draw_line_width(
            _joint_x,
            _joint_y,
            _tip_x,
            _tip_y,
            1
        );
    }


    // ========================================================================
    // CENTRAL JOINT
    // ========================================================================

    draw_circle(
        _x,
        _y,
        1.5,
        true
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the large armoured Heavy Flyer siege aircraft.

function scr_enemy_visual_heavy_flyer(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    // Heavy flyers hover slightly less dramatically than small drones.

    var _hover =
        scr_enemy_visual_hover_offset_get(
            _enemy
        )
        * 0.65;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y + _hover;


    // ========================================================================
    // GROUND SHADOW
    // ========================================================================

    var _shadow_pulse =
        1
        + dsin(
            (global.vtd.tick * 0.8)
            + real(_enemy.id)
        )
        * 0.025;


    draw_set_alpha(0.24);
    draw_set_color(c_black);

    draw_ellipse(
        _enemy.x - (_radius * 1.65 * _shadow_pulse),
        _enemy.y + 9 - (_radius * 0.30),

        _enemy.x + (_radius * 1.65 * _shadow_pulse),
        _enemy.y + 9 + (_radius * 0.30),

        false
    );


    draw_set_alpha(1);
    draw_set_color(_color);


    // ========================================================================
    // LOCAL POINT HELPER VALUES
    // ========================================================================

    // Forward/backward vectors.

    var _fx =
        lengthdir_x(1, _angle);

    var _fy =
        lengthdir_y(1, _angle);

    var _sx =
        lengthdir_x(1, _angle + 90);

    var _sy =
        lengthdir_y(1, _angle + 90);


    // ========================================================================
    // BROAD MAIN WINGS
    // ========================================================================

    var _nose_x =
        _x + (_fx * _radius * 1.12);

    var _nose_y =
        _y + (_fy * _radius * 1.12);


    var _rear_x =
        _x - (_fx * _radius * 0.82);

    var _rear_y =
        _y - (_fy * _radius * 0.82);


    var _left_tip_x =
        _x + (_sx * _radius * 1.95)
        - (_fx * _radius * 0.08);

    var _left_tip_y =
        _y + (_sy * _radius * 1.95)
        - (_fy * _radius * 0.08);


    var _right_tip_x =
        _x - (_sx * _radius * 1.95)
        - (_fx * _radius * 0.08);

    var _right_tip_y =
        _y - (_sy * _radius * 1.95)
        - (_fy * _radius * 0.08);


    var _left_rear_x =
        _x + (_sx * _radius * 1.10)
        - (_fx * _radius * 0.72);

    var _left_rear_y =
        _y + (_sy * _radius * 1.10)
        - (_fy * _radius * 0.72);


    var _right_rear_x =
        _x - (_sx * _radius * 1.10)
        - (_fx * _radius * 0.72);

    var _right_rear_y =
        _y - (_sy * _radius * 1.10)
        - (_fy * _radius * 0.72);


    // Left outer wing.

    draw_line_width(
        _nose_x,
        _nose_y,
        _left_tip_x,
        _left_tip_y,
        3
    );

    draw_line_width(
        _left_tip_x,
        _left_tip_y,
        _left_rear_x,
        _left_rear_y,
        3
    );

    draw_line_width(
        _left_rear_x,
        _left_rear_y,
        _rear_x,
        _rear_y,
        3
    );


    // Right outer wing.

    draw_line_width(
        _nose_x,
        _nose_y,
        _right_tip_x,
        _right_tip_y,
        3
    );

    draw_line_width(
        _right_tip_x,
        _right_tip_y,
        _right_rear_x,
        _right_rear_y,
        3
    );

    draw_line_width(
        _right_rear_x,
        _right_rear_y,
        _rear_x,
        _rear_y,
        3
    );


    // ========================================================================
    // INNER SWEPT WING ARMOUR
    // ========================================================================

    var _left_inner_x =
        _x + (_sx * _radius * 1.20)
        + (_fx * _radius * 0.15);

    var _left_inner_y =
        _y + (_sy * _radius * 1.20)
        + (_fy * _radius * 0.15);


    var _right_inner_x =
        _x - (_sx * _radius * 1.20)
        + (_fx * _radius * 0.15);

    var _right_inner_y =
        _y - (_sy * _radius * 1.20)
        + (_fy * _radius * 0.15);


    draw_line_width(
        _left_tip_x,
        _left_tip_y,
        _left_inner_x,
        _left_inner_y,
        2
    );

    draw_line_width(
        _left_inner_x,
        _left_inner_y,
        _x,
        _y,
        2
    );


    draw_line_width(
        _right_tip_x,
        _right_tip_y,
        _right_inner_x,
        _right_inner_y,
        2
    );

    draw_line_width(
        _right_inner_x,
        _right_inner_y,
        _x,
        _y,
        2
    );


    // ========================================================================
    // CENTRAL ARMOURED DIAMOND
    // ========================================================================

    var _core_front_x =
        _x + (_fx * _radius * 0.62);

    var _core_front_y =
        _y + (_fy * _radius * 0.62);


    var _core_back_x =
        _x - (_fx * _radius * 0.62);

    var _core_back_y =
        _y - (_fy * _radius * 0.62);


    var _core_left_x =
        _x + (_sx * _radius * 0.48);

    var _core_left_y =
        _y + (_sy * _radius * 0.48);


    var _core_right_x =
        _x - (_sx * _radius * 0.48);

    var _core_right_y =
        _y - (_sy * _radius * 0.48);


    draw_line_width(
        _core_front_x,
        _core_front_y,
        _core_left_x,
        _core_left_y,
        3
    );

    draw_line_width(
        _core_left_x,
        _core_left_y,
        _core_back_x,
        _core_back_y,
        3
    );

    draw_line_width(
        _core_back_x,
        _core_back_y,
        _core_right_x,
        _core_right_y,
        3
    );

    draw_line_width(
        _core_right_x,
        _core_right_y,
        _core_front_x,
        _core_front_y,
        3
    );


    // ========================================================================
    // UPPER / REAR SPINE
    // ========================================================================

    var _spine_front_x =
        _x + (_fx * _radius * 0.15);

    var _spine_front_y =
        _y + (_fy * _radius * 0.15);


    var _spine_rear_x =
        _x - (_fx * _radius * 1.16);

    var _spine_rear_y =
        _y - (_fy * _radius * 1.16);


    var _spine_left_x =
        _x + (_sx * _radius * 0.27)
        - (_fx * _radius * 0.72);

    var _spine_left_y =
        _y + (_sy * _radius * 0.27)
        - (_fy * _radius * 0.72);


    var _spine_right_x =
        _x - (_sx * _radius * 0.27)
        - (_fx * _radius * 0.72);

    var _spine_right_y =
        _y - (_sy * _radius * 0.27)
        - (_fy * _radius * 0.72);


    draw_line_width(
        _spine_front_x,
        _spine_front_y,
        _spine_left_x,
        _spine_left_y,
        2
    );

    draw_line_width(
        _spine_left_x,
        _spine_left_y,
        _spine_rear_x,
        _spine_rear_y,
        2
    );

    draw_line_width(
        _spine_rear_x,
        _spine_rear_y,
        _spine_right_x,
        _spine_right_y,
        2
    );

    draw_line_width(
        _spine_right_x,
        _spine_right_y,
        _spine_front_x,
        _spine_front_y,
        2
    );


    // ========================================================================
    // ROCKET LAUNCHER / FORWARD WEAPON
    // ========================================================================

    var _launcher_back_x =
        _x + (_fx * _radius * 0.25);

    var _launcher_back_y =
        _y + (_fy * _radius * 0.25);


    var _launcher_front_x =
        _x + (_fx * _radius * 1.35);

    var _launcher_front_y =
        _y + (_fy * _radius * 1.35);


    draw_line_width(
        _launcher_back_x,
        _launcher_back_y,
        _launcher_front_x,
        _launcher_front_y,
        4
    );


    // ========================================================================
    // ENERGY CORE
    // ========================================================================

    var _pulse =
        0.62
        + dsin(
            (global.vtd.tick * 5)
            + real(_enemy.id)
        )
        * 0.18;


    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        _radius * 0.22,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        2,
        true
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the reinforced Mk.II version of the Weak CPU Seeker.

function scr_enemy_visual_weak_mk2(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    // ========================================================================
    // BASE MK.I SHAPE
    // ========================================================================

    scr_enemy_visual_weak(_enemy);


    // ========================================================================
    // REINFORCED CENTRAL ARMOUR
    // ========================================================================

    var _front_x =
        _x
        + lengthdir_x(
            _radius * 0.55,
            _angle
        );

    var _front_y =
        _y
        + lengthdir_y(
            _radius * 0.55,
            _angle
        );


    var _rear_x =
        _x
        + lengthdir_x(
            _radius * 0.55,
            _angle + 180
        );

    var _rear_y =
        _y
        + lengthdir_y(
            _radius * 0.55,
            _angle + 180
        );


    var _left_x =
        _x
        + lengthdir_x(
            _radius * 0.42,
            _angle + 90
        );

    var _left_y =
        _y
        + lengthdir_y(
            _radius * 0.42,
            _angle + 90
        );


    var _right_x =
        _x
        + lengthdir_x(
            _radius * 0.42,
            _angle - 90
        );

    var _right_y =
        _y
        + lengthdir_y(
            _radius * 0.42,
            _angle - 90
        );


    draw_set_color(_color);
    draw_set_alpha(0.95);


    // Central reinforcement diamond.

    draw_line_width(
        _front_x,
        _front_y,
        _left_x,
        _left_y,
        2
    );

    draw_line_width(
        _left_x,
        _left_y,
        _rear_x,
        _rear_y,
        2
    );

    draw_line_width(
        _rear_x,
        _rear_y,
        _right_x,
        _right_y,
        2
    );

    draw_line_width(
        _right_x,
        _right_y,
        _front_x,
        _front_y,
        2
    );


    // ========================================================================
    // INNER ARMOUR BRACES
    // ========================================================================

    for (var i = 0; i < 3; ++i)
    {
        var _blade_angle =
            _angle
            + (i * 120);


        var _inner_x =
            _x
            + lengthdir_x(
                _radius * 0.46,
                _blade_angle
            );

        var _inner_y =
            _y
            + lengthdir_y(
                _radius * 0.46,
                _blade_angle
            );


        var _outer_x =
            _x
            + lengthdir_x(
                _radius * 0.78,
                _blade_angle
            );

        var _outer_y =
            _y
            + lengthdir_y(
                _radius * 0.78,
                _blade_angle
            );


        draw_line_width(
            _inner_x,
            _inner_y,
            _outer_x,
            _outer_y,
            2
        );
    }


    // ========================================================================
    // HEAVIER CORE
    // ========================================================================

    draw_set_alpha(0.35);

    draw_circle(
        _x,
        _y,
        _radius * 0.28,
        false
    );


    draw_set_alpha(1);

    draw_circle(
        _x,
        _y,
        _radius * 0.12,
        true
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the reinforced Mk.II version of the Building Hunter.

function scr_enemy_visual_hunter_mk2(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    // ========================================================================
    // BASE MK.I SHAPE
    // ========================================================================

    scr_enemy_visual_hunter(_enemy);


    // ========================================================================
    // HEAVY CENTRAL PLATING
    // ========================================================================

    var _plate_radius =
        _radius * 0.52;


    var _front_x =
        _x
        + lengthdir_x(
            _plate_radius,
            _angle
        );

    var _front_y =
        _y
        + lengthdir_y(
            _plate_radius,
            _angle
        );


    var _back_x =
        _x
        + lengthdir_x(
            _plate_radius,
            _angle + 180
        );

    var _back_y =
        _y
        + lengthdir_y(
            _plate_radius,
            _angle + 180
        );


    var _left_x =
        _x
        + lengthdir_x(
            _plate_radius,
            _angle + 90
        );

    var _left_y =
        _y
        + lengthdir_y(
            _plate_radius,
            _angle + 90
        );


    var _right_x =
        _x
        + lengthdir_x(
            _plate_radius,
            _angle - 90
        );

    var _right_y =
        _y
        + lengthdir_y(
            _plate_radius,
            _angle - 90
        );


    draw_set_color(_color);
    draw_set_alpha(1);


    draw_line_width(
        _front_x,
        _front_y,
        _left_x,
        _left_y,
        3
    );

    draw_line_width(
        _left_x,
        _left_y,
        _back_x,
        _back_y,
        3
    );

    draw_line_width(
        _back_x,
        _back_y,
        _right_x,
        _right_y,
        3
    );

    draw_line_width(
        _right_x,
        _right_y,
        _front_x,
        _front_y,
        3
    );


    // ========================================================================
    // BLADE REINFORCEMENT RAILS
    // ========================================================================

    for (var i = 0; i < 3; ++i)
    {
        var _blade_angle =
            _angle
            + (i * 120);


        var _rail_left_angle =
            _blade_angle - 9;

        var _rail_right_angle =
            _blade_angle + 9;


        var _inner_distance =
            _radius * 0.50;

        var _outer_distance =
            _radius * 0.92;


        var _inner_left_x =
            _x
            + lengthdir_x(
                _inner_distance,
                _rail_left_angle
            );

        var _inner_left_y =
            _y
            + lengthdir_y(
                _inner_distance,
                _rail_left_angle
            );


        var _outer_left_x =
            _x
            + lengthdir_x(
                _outer_distance,
                _rail_left_angle
            );

        var _outer_left_y =
            _y
            + lengthdir_y(
                _outer_distance,
                _rail_left_angle
            );


        var _inner_right_x =
            _x
            + lengthdir_x(
                _inner_distance,
                _rail_right_angle
            );

        var _inner_right_y =
            _y
            + lengthdir_y(
                _inner_distance,
                _rail_right_angle
            );


        var _outer_right_x =
            _x
            + lengthdir_x(
                _outer_distance,
                _rail_right_angle
            );

        var _outer_right_y =
            _y
            + lengthdir_y(
                _outer_distance,
                _rail_right_angle
            );


        draw_line_width(
            _inner_left_x,
            _inner_left_y,
            _outer_left_x,
            _outer_left_y,
            2
        );

        draw_line_width(
            _inner_right_x,
            _inner_right_y,
            _outer_right_x,
            _outer_right_y,
            2
        );
    }


    // ========================================================================
    // CORE / ARMOUR HUB
    // ========================================================================

    draw_set_alpha(0.25);

    draw_circle(
        _x,
        _y,
        _radius * 0.36,
        false
    );


    draw_set_alpha(1);

    draw_circle(
        _x,
        _y,
        _radius * 0.16,
        true
    );


    // Small inner white point makes the core read more clearly.

    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        2,
        true
    );


    return true;
}

/// @description Draws the long-range Sniper enemy.

function scr_enemy_visual_sniper(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    draw_set_color(_color);
    draw_set_alpha(1);


    // ========================================================================
    // MAIN NARROW HULL
    // ========================================================================

    var _front_x =
        _x
        + lengthdir_x(
            _radius * 1.05,
            _angle
        );

    var _front_y =
        _y
        + lengthdir_y(
            _radius * 1.05,
            _angle
        );


    var _rear_x =
        _x
        + lengthdir_x(
            _radius * 0.85,
            _angle + 180
        );

    var _rear_y =
        _y
        + lengthdir_y(
            _radius * 0.85,
            _angle + 180
        );


    var _upper_x =
        _x
        + lengthdir_x(
            _radius * 0.58,
            _angle + 115
        );

    var _upper_y =
        _y
        + lengthdir_y(
            _radius * 0.58,
            _angle + 115
        );


    var _lower_x =
        _x
        + lengthdir_x(
            _radius * 0.58,
            _angle - 115
        );

    var _lower_y =
        _y
        + lengthdir_y(
            _radius * 0.58,
            _angle - 115
        );


    draw_line_width(
        _front_x,
        _front_y,
        _upper_x,
        _upper_y,
        2
    );

    draw_line_width(
        _upper_x,
        _upper_y,
        _rear_x,
        _rear_y,
        2
    );

    draw_line_width(
        _rear_x,
        _rear_y,
        _lower_x,
        _lower_y,
        2
    );

    draw_line_width(
        _lower_x,
        _lower_y,
        _front_x,
        _front_y,
        2
    );


    // ========================================================================
    // LONG SNIPER BARREL
    // ========================================================================

    var _barrel_start_x =
        _x
        + lengthdir_x(
            _radius * 0.35,
            _angle
        );

    var _barrel_start_y =
        _y
        + lengthdir_y(
            _radius * 0.35,
            _angle
        );


    var _barrel_end_x =
        _x
        + lengthdir_x(
            _radius * 1.65,
            _angle
        );

    var _barrel_end_y =
        _y
        + lengthdir_y(
            _radius * 1.65,
            _angle
        );


    draw_line_width(
        _barrel_start_x,
        _barrel_start_y,
        _barrel_end_x,
        _barrel_end_y,
        3
    );


    // Small muzzle fork.

    var _muzzle_left_x =
        _barrel_end_x
        + lengthdir_x(
            _radius * 0.22,
            _angle + 135
        );

    var _muzzle_left_y =
        _barrel_end_y
        + lengthdir_y(
            _radius * 0.22,
            _angle + 135
        );


    var _muzzle_right_x =
        _barrel_end_x
        + lengthdir_x(
            _radius * 0.22,
            _angle - 135
        );

    var _muzzle_right_y =
        _barrel_end_y
        + lengthdir_y(
            _radius * 0.22,
            _angle - 135
        );


    draw_line(
        _muzzle_left_x,
        _muzzle_left_y,
        _barrel_end_x,
        _barrel_end_y
    );

    draw_line(
        _barrel_end_x,
        _barrel_end_y,
        _muzzle_right_x,
        _muzzle_right_y
    );


    // ========================================================================
    // REAR STABILIZER FINS
    // ========================================================================

    var _rear_upper_x =
        _rear_x
        + lengthdir_x(
            _radius * 0.50,
            _angle + 70
        );

    var _rear_upper_y =
        _rear_y
        + lengthdir_y(
            _radius * 0.50,
            _angle + 70
        );


    var _rear_lower_x =
        _rear_x
        + lengthdir_x(
            _radius * 0.50,
            _angle - 70
        );

    var _rear_lower_y =
        _rear_y
        + lengthdir_y(
            _radius * 0.50,
            _angle - 70
        );


    draw_line_width(
        _rear_x,
        _rear_y,
        _rear_upper_x,
        _rear_upper_y,
        2
    );

    draw_line_width(
        _rear_x,
        _rear_y,
        _rear_lower_x,
        _rear_lower_y,
        2
    );


    // ========================================================================
    // CENTRAL SCOPE / CORE
    // ========================================================================

    draw_circle(
        _x,
        _y,
        _radius * 0.25,
        true
    );


    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        1.5,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}

/// @description Draws the Berserker as a health-reactive spinning blade unit.

function scr_enemy_visual_berserker(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _health_percentage =
        clamp(
            _enemy.vitals.hp.current
            / _enemy.vitals.hp.maximum,
            0,
            1
        );

    var _rage =
        1
        - _health_percentage;


    // The body spins faster as the Berserker becomes more dangerous.

    var _spin_speed =
        lerp(
            2.5,
            10,
            _rage
        );

    var _spin =
        (
            global.vtd.tick
            * _spin_speed
            + real(_enemy.id)
        )
        mod 360;


    var _rage_color =
        merge_color(
            _enemy.visual.color,
            c_red,
            _rage
        );


    draw_set_alpha(1);
    draw_set_color(_rage_color);


    // ========================================================================
    // SIX OUTER BLADES
    // ========================================================================

    for (var i = 0; i < 6; ++i)
    {
        var _blade_angle =
            _spin
            + (i * 60);

        var _inner_distance =
            _radius * 0.42;

        var _tip_distance =
            _radius * 1.08;

        var _inner_left_x =
            _x
            + lengthdir_x(
                _inner_distance,
                _blade_angle - 22
            );

        var _inner_left_y =
            _y
            + lengthdir_y(
                _inner_distance,
                _blade_angle - 22
            );

        var _inner_right_x =
            _x
            + lengthdir_x(
                _inner_distance,
                _blade_angle + 22
            );

        var _inner_right_y =
            _y
            + lengthdir_y(
                _inner_distance,
                _blade_angle + 22
            );

        var _tip_x =
            _x
            + lengthdir_x(
                _tip_distance,
                _blade_angle
            );

        var _tip_y =
            _y
            + lengthdir_y(
                _tip_distance,
                _blade_angle
            );


        draw_line_width(
            _inner_left_x,
            _inner_left_y,
            _tip_x,
            _tip_y,
            3
        );

        draw_line_width(
            _tip_x,
            _tip_y,
            _inner_right_x,
            _inner_right_y,
            3
        );
    }


    // ========================================================================
    // INNER HEXAGONAL BODY
    // ========================================================================

    var _body_radius =
        _radius * 0.52;


    for (var i = 0; i < 6; ++i)
    {
        var _angle_a =
            _spin
            + 30
            + (i * 60);

        var _angle_b =
            _spin
            + 30
            + (((i + 1) mod 6) * 60);


        draw_line_width(
            _x
                + lengthdir_x(
                    _body_radius,
                    _angle_a
                ),

            _y
                + lengthdir_y(
                    _body_radius,
                    _angle_a
                ),

            _x
                + lengthdir_x(
                    _body_radius,
                    _angle_b
                ),

            _y
                + lengthdir_y(
                    _body_radius,
                    _angle_b
                ),

            2
        );
    }


    // ========================================================================
    // FORWARD ATTACK WEDGE
    // ========================================================================
    //
    // The rotating blades show rage, while this fixed wedge shows the actual
    // movement and attack direction.

    var _direction =
        _enemy.visual.draw_angle;

    var _forward_x =
        _x
        + lengthdir_x(
            _radius * 0.78,
            _direction
        );

    var _forward_y =
        _y
        + lengthdir_y(
            _radius * 0.78,
            _direction
        );

    var _left_x =
        _x
        + lengthdir_x(
            _radius * 0.34,
            _direction + 125
        );

    var _left_y =
        _y
        + lengthdir_y(
            _radius * 0.34,
            _direction + 125
        );

    var _right_x =
        _x
        + lengthdir_x(
            _radius * 0.34,
            _direction - 125
        );

    var _right_y =
        _y
        + lengthdir_y(
            _radius * 0.34,
            _direction - 125
        );


    draw_set_color(c_white);

    draw_line_width(
        _left_x,
        _left_y,
        _forward_x,
        _forward_y,
        2
    );

    draw_line_width(
        _forward_x,
        _forward_y,
        _right_x,
        _right_y,
        2
    );


    // ========================================================================
    // RAGE CORE
    // ========================================================================

    var _pulse =
        0.45
        + (
            sin(
                global.vtd.tick
                * lerp(
                    4,
                    14,
                    _rage
                )
                + real(_enemy.id)
            )
            * 0.20
        );

    var _core_radius =
        lerp(
            _radius * 0.16,
            _radius * 0.30,
            _rage
        );


    draw_set_color(_rage_color);
    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        _core_radius,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        max(
            1.5,
            _radius * 0.08
        ),
        true
    );


    return true;
}

/// @description Draws the heavy cargo-carrying Transporter MK2.

function scr_enemy_visual_transporter_mk2(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _x = _enemy.x;
    var _y = _enemy.y;

    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;

    var _color =
        _enemy.visual.color;


    draw_set_color(_color);


    // ========================================================================
    // OUTER HEAVY CARGO FRAME
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        _radius,
        6,
        _angle + 30,
        3
    );


    // ========================================================================
    // INNER REINFORCEMENT FRAME
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        _radius * 0.72,
        6,
        _angle,
        2
    );


    // ========================================================================
    // STRUCTURAL SUPPORTS
    // ========================================================================

    scr_enemy_visual_helper_spokes(
        _x,
        _y,
        _radius * 0.40,
        _radius * 0.92,
        6,
        _angle + 30,
        2
    );


    // ========================================================================
    // CARGO PODS
    // ========================================================================

    for (var i = 0; i < 6; ++i)
    {
        var _pod_angle =
            _angle
            + 30
            + (i * 60);

        var _pod_x =
            _x
            + lengthdir_x(
                _radius * 0.68,
                _pod_angle
            );

        var _pod_y =
            _y
            + lengthdir_y(
                _radius * 0.68,
                _pod_angle
            );


        draw_circle(
            _pod_x,
            _pod_y,
            7,
            false
        );


        draw_circle(
            _pod_x,
            _pod_y,
            3,
            false
        );
    }


    // ========================================================================
    // CENTRAL COMMAND CORE
    // ========================================================================

    scr_enemy_visual_helper_double_ring(
        _x,
        _y,
        _radius * 0.34,
        _radius * 0.20
    );


    // Small rotating inner reactor markers.

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        _radius * 0.27,
        2.5,
        6,
        -_angle,
        true
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the hovering Flying Transporter.

function scr_enemy_visual_flying_transporter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    var _hover =
        scr_enemy_visual_hover_offset_get(_enemy);

    var _x = _enemy.x;
    var _y = _enemy.y + _hover;

    var _pulse =
        0.65
        + sin(
            (global.vtd.tick * 2)
            + real(_enemy.id)
        ) * 0.2;


    // ========================================================================
    // GROUND SHADOW
    // ========================================================================

    draw_set_alpha(0.2);
    draw_set_color(c_black);

    draw_ellipse(
        _enemy.x - (_radius * 1.15),
        _enemy.y + 3,
        _enemy.x + (_radius * 1.15),
        _enemy.y + 15,
        false
    );


    // ========================================================================
    // MAIN AIRFRAME
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(_color);

    var _body =
    [
        [ _radius,        0 ],
        [ _radius * 0.45, -_radius * 0.70 ],
        [ -_radius * 0.2, -_radius * 0.95 ],
        [ -_radius * 0.9, -_radius * 0.55 ],
        [ -_radius * 0.75, 0 ],
        [ -_radius * 0.9,  _radius * 0.55 ],
        [ -_radius * 0.2,  _radius * 0.95 ],
        [ _radius * 0.45,  _radius * 0.70 ]
    ];

    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _body,
        2
    );


    // Central structural spine.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,
        -_radius * 0.72,
        0,
        _radius * 0.82,
        0,
        2
    );


    // ========================================================================
    // CARGO PODS
    // ========================================================================

    for (var i = 0; i < 4; ++i)
    {
        var _forward =
            i < 2
            ? _radius * 0.28
            : -_radius * 0.35;

        var _side =
            (i mod 2 == 0)
            ? -_radius * 0.56
            : _radius * 0.56;

        var _pod_x =
            _x
            + lengthdir_x(_forward, _angle)
            + lengthdir_x(_side, _angle + 90);

        var _pod_y =
            _y
            + lengthdir_y(_forward, _angle)
            + lengthdir_y(_side, _angle + 90);

        draw_circle(
            _pod_x,
            _pod_y,
            _radius * 0.16,
            true
        );

        draw_set_alpha(0.35 + (_pulse * 0.25));

        draw_circle(
            _pod_x,
            _pod_y,
            _radius * 0.09,
            false
        );

        draw_set_alpha(1);
    }


    // ========================================================================
    // REAR HOVER ENGINES
    // ========================================================================

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _engine_x =
            _x
            + lengthdir_x(
                _radius * 0.7,
                _angle + 180
            )
            + lengthdir_x(
                _radius * 0.42 * _side,
                _angle + 90
            );

        var _engine_y =
            _y
            + lengthdir_y(
                _radius * 0.7,
                _angle + 180
            )
            + lengthdir_y(
                _radius * 0.42 * _side,
                _angle + 90
            );

        draw_circle(
            _engine_x,
            _engine_y,
            _radius * 0.13,
            true
        );

        draw_set_alpha(_pulse);

        draw_circle(
            _engine_x,
            _engine_y,
            _radius * 0.06,
            false
        );

        draw_set_alpha(1);
    }


    // ========================================================================
    // CARGO CORE
    // ========================================================================

    draw_circle(
        _x,
        _y,
        _radius * 0.28,
        true
    );

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        _radius * 0.12,
        false
    );


    // ========================================================================
    // ALTITUDE MARKERS
    // ========================================================================

    draw_set_alpha(0.65);

    draw_line(
        _enemy.x - 7,
        _enemy.y + 5,
        _enemy.x - 3,
        _enemy.y + 11
    );

    draw_line(
        _enemy.x + 7,
        _enemy.y + 5,
        _enemy.x + 3,
        _enemy.y + 11
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}