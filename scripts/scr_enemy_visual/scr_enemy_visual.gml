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


/// @description Draws the rotating circular kamikaze enemy.

function scr_enemy_visual_kamikaze(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius = _enemy.visual.radius;

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

    draw_set_color(_enemy.visual.color);

    draw_circle(
        _enemy.x,
        _enemy.y,
        _radius,
        false
    );


    // ========================================================================
    // ROTATING ARMS
    // ========================================================================

    for (var i = 0; i < 4; ++i)
    {
        var _arm_angle = _spin + (i * 90);

        draw_line_width(
            _enemy.x + lengthdir_x(_radius * 0.55, _arm_angle),
            _enemy.y + lengthdir_y(_radius * 0.55, _arm_angle),
            _enemy.x + lengthdir_x(_radius, _arm_angle),
            _enemy.y + lengthdir_y(_radius, _arm_angle),
            3
        );
    }


    // ========================================================================
    // ROTATING INNER SQUARE
    // ========================================================================

    var _square_radius = _radius * 0.52;

    var _x1 = _enemy.x + lengthdir_x(_square_radius, _spin + 45);
    var _y1 = _enemy.y + lengthdir_y(_square_radius, _spin + 45);

    var _x2 = _enemy.x + lengthdir_x(_square_radius, _spin + 135);
    var _y2 = _enemy.y + lengthdir_y(_square_radius, _spin + 135);

    var _x3 = _enemy.x + lengthdir_x(_square_radius, _spin + 225);
    var _y3 = _enemy.y + lengthdir_y(_square_radius, _spin + 225);

    var _x4 = _enemy.x + lengthdir_x(_square_radius, _spin + 315);
    var _y4 = _enemy.y + lengthdir_y(_square_radius, _spin + 315);


    draw_set_color(c_white);

    draw_line_width(_x1, _y1, _x2, _y2, 2);
    draw_line_width(_x2, _y2, _x3, _y3, 2);
    draw_line_width(_x3, _y3, _x4, _y4, 2);
    draw_line_width(_x4, _y4, _x1, _y1, 2);


    // One bright corner makes the rotation especially obvious.

    draw_circle(
        _x1,
        _y1,
        2,
        true
    );


    draw_set_color(c_white);

    return true;
}


/// @description Draws an enemy sprite or falls back to its primitive function.

function scr_enemy_visual_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _visual = _enemy.visual;


    // If a sprite is supplied by the enemy definition, it takes priority.

    if (_visual.sprite != -1)
    {
        draw_sprite_ext(
            _visual.sprite,
            _enemy.image_index,
            _enemy.x,
            _enemy.y,
            1,
            1,
            _visual.draw_angle,
            c_white,
            1
        );

        return true;
    }


    // Until a sprite is assigned, use the enemy's primitive renderer.

    if (!is_undefined(_visual.draw_function))
    {
        _visual.draw_function(_enemy);
        return true;
    }


    // Emergency fallback for an incomplete enemy definition.

    draw_set_color(_visual.color);

    draw_circle(
        _enemy.x,
        _enemy.y,
        _visual.radius,
        false
    );


    return true;
}


/// @description Draws the shared enemy health bar.

function scr_enemy_health_bar_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius = _enemy.visual.radius;

    var _hover =
        scr_enemy_visual_hover_offset_get(_enemy);

    var _hp_percent = clamp(
        _enemy.vitals.hp.current
        / max(1, _enemy.vitals.hp.maximum),
        0,
        1
    );

    var _bar_width = _radius * 2;
    var _bar_left = _enemy.x - _radius;
    var _bar_top = _enemy.y + _hover - _radius - 8;


    draw_set_color(c_dkgray);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left + _bar_width,
        _bar_top + 3,
        false
    );


    draw_set_color(c_red);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left + (_bar_width * _hp_percent),
        _bar_top + 3,
        false
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the larger splitter enemy.

function scr_enemy_visual_splitter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;

    var _front_x = _enemy.x + lengthdir_x(_radius, _angle);
    var _front_y = _enemy.y + lengthdir_y(_radius, _angle);

    var _right_x = _enemy.x + lengthdir_x(_radius, _angle - 90);
    var _right_y = _enemy.y + lengthdir_y(_radius, _angle - 90);

    var _back_x = _enemy.x + lengthdir_x(_radius, _angle + 180);
    var _back_y = _enemy.y + lengthdir_y(_radius, _angle + 180);

    var _left_x = _enemy.x + lengthdir_x(_radius, _angle + 90);
    var _left_y = _enemy.y + lengthdir_y(_radius, _angle + 90);


    draw_set_color(_enemy.visual.color);

    draw_line_width(_front_x, _front_y, _right_x, _right_y, 3);
    draw_line_width(_right_x, _right_y, _back_x, _back_y, 3);
    draw_line_width(_back_x, _back_y, _left_x, _left_y, 3);
    draw_line_width(_left_x, _left_y, _front_x, _front_y, 3);

    draw_line_width(_front_x, _front_y, _back_x, _back_y, 2);
    draw_line_width(_left_x, _left_y, _right_x, _right_y, 2);


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

    return -10 + sin(
        (global.vtd.tick * 5)
        + real(_enemy.id)
    ) * 3;
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
            (global.vtd.tick * 5)
            + real(_enemy.id)
        ) * 0.08;

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


/// @description Updates one enemy's temporary shield feedback.

function scr_enemy_shield_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _enemy.vitals.shield.hit_flash =
        max(
            0,
            _enemy.vitals.shield.hit_flash
            - (4 / _fps)
        );


    return true;
}

/// @description Draws an active primitive vector shield.

function scr_enemy_shield_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _shield =
        _enemy.vitals.shield;

    if (!_shield.enabled)
        return true;

    if (_shield.current <= 0)
        return true;


    var _ratio =
        clamp(
            _shield.current
            / max(1, _shield.maximum),
            0,
            1
        );

    var _radius =
        _enemy.visual.radius
        + 7
        + dsin(
            (global.vtd.tick * 3)
            + real(_enemy.id)
        );

    var _alpha =
        0.35
        + (_ratio * 0.25)
        + (_shield.hit_flash * 0.35);


    draw_set_color(
        _shield.color
    );


    // Faint shield interior.

    draw_set_alpha(
        0.035
        + (_shield.hit_flash * 0.05)
    );

    draw_circle(
        _enemy.x,
        _enemy.y,
        _radius,
        false
    );


    // Main shield boundary.

    draw_set_alpha(
        clamp(_alpha, 0, 1)
    );

    draw_circle(
        _enemy.x,
        _enemy.y,
        _radius,
        true
    );


    // Segments disappear as shield energy falls.

    var _segments =
        max(
            1,
            ceil(_ratio * 8)
        );


    for (var i = 0; i < _segments; ++i)
    {
        var _angle =
            i * 45;

        draw_line(
            _enemy.x
                + lengthdir_x(_radius + 3, _angle - 12),

            _enemy.y
                + lengthdir_y(_radius + 3, _angle - 12),

            _enemy.x
                + lengthdir_x(_radius + 3, _angle + 12),

            _enemy.y
                + lengthdir_y(_radius + 3, _angle + 12)
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}