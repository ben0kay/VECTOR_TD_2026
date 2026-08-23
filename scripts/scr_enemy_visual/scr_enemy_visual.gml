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

    // Offset by instance ID so multiple kamikazes do not rotate in sync.

    var _spin =
        (
            global.vtd.tick * 6
            + real(_enemy.id)
        )
        mod 360;


    // Outer explosive shell.

    draw_set_color(_enemy.visual.color);

    draw_circle(
        _enemy.x,
        _enemy.y,
        _radius,
        false
    );


    // Inner core.

    draw_circle(
        _enemy.x,
        _enemy.y,
        _radius * 0.4,
        false
    );


    // Four rotating arms.

    for (var i = 0; i < 4; ++i)
    {
        var _arm_angle = _spin + (i * 90);

        var _inner_x =
            _enemy.x
            + lengthdir_x(
                _radius * 0.4,
                _arm_angle
            );

        var _inner_y =
            _enemy.y
            + lengthdir_y(
                _radius * 0.4,
                _arm_angle
            );

        var _outer_x =
            _enemy.x
            + lengthdir_x(
                _radius,
                _arm_angle
            );

        var _outer_y =
            _enemy.y
            + lengthdir_y(
                _radius,
                _arm_angle
            );


        draw_line_width(
            _inner_x,
            _inner_y,
            _outer_x,
            _outer_y,
            3
        );
    }


    // Small bright explosive core.

    draw_set_color(c_white);

    draw_circle(
        _enemy.x,
        _enemy.y,
        _radius * 0.18,
        true
    );


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

    var _hp_percent = clamp(
        _enemy.vitals.hp.current
        / _enemy.vitals.hp.maximum,
        0,
        1
    );

    var _bar_width = _radius * 2;
    var _bar_left = _enemy.x - _radius;
    var _bar_top = _enemy.y - _radius - 8;


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