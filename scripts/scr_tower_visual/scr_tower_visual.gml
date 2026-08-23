
/// @description Draws the basic ground cannon.

function scr_tower_visual_ground(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;


    draw_set_color(_color);

    // Rotating diamond mount.

    var _mount_radius = 15;

    for (var i = 0; i < 4; ++i)
    {
        var _a1 = _angle + 45 + (i * 90);
        var _a2 = _angle + 45 + (((i + 1) mod 4) * 90);

        draw_line_width(
            _x + lengthdir_x(_mount_radius, _a1),
            _y + lengthdir_y(_mount_radius, _a1),
            _x + lengthdir_x(_mount_radius, _a2),
            _y + lengthdir_y(_mount_radius, _a2),
            2
        );
    }


    // Central reactor.

    draw_circle(_x, _y, 8, false);
    draw_circle(_x, _y, 3, true);


    // Main barrel with two vector rails.

    var _side_x = lengthdir_x(4, _angle + 90);
    var _side_y = lengthdir_y(4, _angle + 90);

    var _barrel_x =
        _x + lengthdir_x(36, _angle);

    var _barrel_y =
        _y + lengthdir_y(36, _angle);

    draw_line_width(
        _x + _side_x,
        _y + _side_y,
        _barrel_x + _side_x,
        _barrel_y + _side_y,
        2
    );

    draw_line_width(
        _x - _side_x,
        _y - _side_y,
        _barrel_x - _side_x,
        _barrel_y - _side_y,
        2
    );

    draw_line_width(
        _barrel_x + _side_x,
        _barrel_y + _side_y,
        _barrel_x - _side_x,
        _barrel_y - _side_y,
        2
    );


    draw_set_color(c_white);

    return true;
}


/// @description Draws the dedicated anti-air tracking tower.

function scr_tower_visual_anti_air(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    var _pulse =
        0.7
        + sin(
            (global.vtd.tick * 6)
            + real(_tower.id)
        ) * 0.2;


    // Circular tracking mount.

    draw_set_alpha(1);
    draw_set_color(_color);

    draw_circle(_x, _y, 17, false);
    draw_circle(_x, _y, 11, false);


    // Rotating radar cross.

    draw_line_width(
        _x + lengthdir_x(13, _angle),
        _y + lengthdir_y(13, _angle),
        _x + lengthdir_x(13, _angle + 180),
        _y + lengthdir_y(13, _angle + 180),
        2
    );

    draw_line_width(
        _x + lengthdir_x(13, _angle + 90),
        _y + lengthdir_y(13, _angle + 90),
        _x + lengthdir_x(13, _angle - 90),
        _y + lengthdir_y(13, _angle - 90),
        2
    );


    // Twin anti-air rails.

    var _side_x = lengthdir_x(6, _angle + 90);
    var _side_y = lengthdir_y(6, _angle + 90);

    var _end_x =
        _x + lengthdir_x(34, _angle);

    var _end_y =
        _y + lengthdir_y(34, _angle);

    draw_line_width(
        _x + _side_x,
        _y + _side_y,
        _end_x + _side_x,
        _end_y + _side_y,
        3
    );

    draw_line_width(
        _x - _side_x,
        _y - _side_y,
        _end_x - _side_x,
        _end_y - _side_y,
        3
    );


    // Pulsing tracking light.

    draw_set_alpha(_pulse);
    draw_set_color(c_white);
    draw_circle(_x, _y, 3, true);


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the configured rotating tower assembly.

function scr_tower_draw(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_undefined(_tower.visual.draw_function))
    {
        _tower.visual.draw_function(_tower);
        return true;
    }

    scr_tower_visual_ground(_tower);

    return true;
}