
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


/// @description Draws the configured tower and active weapon trace.

function scr_tower_draw(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_undefined(_tower.visual.draw_function))
        _tower.visual.draw_function(_tower);
    else
        scr_tower_visual_ground(_tower);

    scr_tower_weapon_trace_draw(_tower);

    return true;
}

/// @description Draws the attack range of a selected tower.

function scr_tower_range_draw(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(global.vtd_level.entities, "hud"))
        return false;


    var _hud =
        global.vtd_level.entities.hud;

    if (!instance_exists(_hud))
        return false;

    if (_hud.hud.selection.target != _tower)
        return false;


    var _range =
        _tower.combat.range;

    // dsin() uses degrees and produces a slow, smooth pulse.

    var _pulse =
        0.55
        + dsin(global.vtd.tick * 2)
        * 0.12;


    // ========================================================================
    // SUBTLE RANGE INTERIOR
    // ========================================================================

    draw_set_color(
        c_aqua
    );

    draw_set_alpha(0.035);

    draw_circle(
        _tower.x,
        _tower.y,
        _range,
        false
    );


    // ========================================================================
    // RANGE OUTLINE
    // ========================================================================

    draw_set_alpha(_pulse);

    draw_circle(
        _tower.x,
        _tower.y,
        _range,
        true
    );


    // ========================================================================
    // DIRECTIONAL RANGE MARKERS
    // ========================================================================

    draw_set_alpha(0.85);

    for (var i = 0; i < 4; ++i)
    {
        var _angle = i * 90;

        var _marker_x =
            _tower.x
            + lengthdir_x(_range, _angle);

        var _marker_y =
            _tower.y
            + lengthdir_y(_range, _angle);


        draw_line(
            _marker_x
                + lengthdir_x(6, _angle + 90),

            _marker_y
                + lengthdir_y(6, _angle + 90),

            _marker_x
                + lengthdir_x(6, _angle - 90),

            _marker_y
                + lengthdir_y(6, _angle - 90)
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the single-barrel anti-air tracker.

function scr_tower_visual_anti_air(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    var _pulse =
        0.65
        + dsin(
            (global.vtd.tick * 5)
            + real(_tower.id)
        ) * 0.2;

    draw_set_color(_color);

    // Tracking dish and central pivot.

    draw_circle(_x, _y, 16, true);
    draw_circle(_x, _y, 9, true);
    draw_circle(_x, _y, 4, false);

    // Single elevated barrel.

    var _end_x = _x + lengthdir_x(38, _angle);
    var _end_y = _y + lengthdir_y(38, _angle);

    draw_line_width(_x, _y, _end_x, _end_y, 4);

    // Small perpendicular sight near the muzzle.

    draw_line_width(
        _end_x + lengthdir_x(5, _angle + 90),
        _end_y + lengthdir_y(5, _angle + 90),
        _end_x + lengthdir_x(5, _angle - 90),
        _end_y + lengthdir_y(5, _angle - 90),
        2
    );

    draw_set_alpha(_pulse);
    draw_set_color(c_white);
    draw_circle(_x, _y, 3, false);

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the alternating twin-minigun tower.

function scr_tower_visual_minigun(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    draw_circle(_x, _y, 17, true);
    draw_circle(_x, _y, 8, false);

    var _side_x = lengthdir_x(7, _angle + 90);
    var _side_y = lengthdir_y(7, _angle + 90);

    var _end_x = _x + lengthdir_x(38, _angle);
    var _end_y = _y + lengthdir_y(38, _angle);

    // Twin rotary barrels.

    draw_line_width(
        _x + _side_x,
        _y + _side_y,
        _end_x + _side_x,
        _end_y + _side_y,
        4
    );

    draw_line_width(
        _x - _side_x,
        _y - _side_y,
        _end_x - _side_x,
        _end_y - _side_y,
        4
    );

    draw_circle(_end_x + _side_x, _end_y + _side_y, 4, true);
    draw_circle(_end_x - _side_x, _end_y - _side_y, 4, true);

    // Highlight the barrel that will fire next.

    var _active_side =
        _tower.combat.weapon.muzzle.side;

    draw_set_color(c_white);

    draw_circle(
        _end_x + (_side_x * _active_side),
        _end_y + (_side_y * _active_side),
        2,
        false
    );

    draw_set_color(c_white);

    return true;
}

/// @description Draws the heavy explosive cannon.

function scr_tower_visual_cannon(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    // Heavy octagonal mount.

    var _radius = 18;

    for (var i = 0; i < 8; ++i)
    {
        var _a1 = _angle + (i * 45);
        var _a2 = _angle + (((i + 1) mod 8) * 45);

        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),
            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),
            3
        );
    }

    draw_circle(_x, _y, 10, false);

    // Wide cannon barrel.

    var _side_x = lengthdir_x(6, _angle + 90);
    var _side_y = lengthdir_y(6, _angle + 90);
    var _end_x = _x + lengthdir_x(40, _angle);
    var _end_y = _y + lengthdir_y(40, _angle);

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

    draw_line_width(
        _end_x + _side_x,
        _end_y + _side_y,
        _end_x - _side_x,
        _end_y - _side_y,
        3
    );

    draw_set_color(c_white);

    return true;
}

/// @description Draws the shield-focused laser emitter.

function scr_tower_visual_laser(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    var _pulse =
        0.7
        + dsin(
            (global.vtd.tick * 8)
            + real(_tower.id)
        ) * 0.2;

    draw_set_color(_color);

    draw_circle(_x, _y, 16, true);
    draw_circle(_x, _y, 11, true);

    // Three focusing prongs.

    for (var i = -1; i <= 1; ++i)
    {
        var _side = i * 5;

        draw_line_width(
            _x + lengthdir_x(_side, _angle + 90),
            _y + lengthdir_y(_side, _angle + 90),
            _x + lengthdir_x(31, _angle)
                + lengthdir_x(_side * 0.45, _angle + 90),
            _y + lengthdir_y(31, _angle)
                + lengthdir_y(_side * 0.45, _angle + 90),
            2
        );
    }

    draw_set_alpha(_pulse);
    draw_set_color(c_white);
    draw_circle(_x, _y, 4, false);

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the long-range sniper tower.

function scr_tower_visual_sniper(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    // Narrow precision mount.

    draw_circle(_x, _y, 15, true);
    draw_circle(_x, _y, 6, false);

    var _end_x = _x + lengthdir_x(44, _angle);
    var _end_y = _y + lengthdir_y(44, _angle);

    draw_line_width(_x, _y, _end_x, _end_y, 3);

    // Long rail and sight marks.

    draw_line(
        _x + lengthdir_x(8, _angle + 90),
        _y + lengthdir_y(8, _angle + 90),
        _x + lengthdir_x(8, _angle - 90),
        _y + lengthdir_y(8, _angle - 90)
    );

    draw_line(
        _end_x + lengthdir_x(4, _angle + 90),
        _end_y + lengthdir_y(4, _angle + 90),
        _end_x + lengthdir_x(4, _angle - 90),
        _end_y + lengthdir_y(4, _angle - 90)
    );

    draw_set_color(c_white);

    return true;
}

/// @description Draws a tower's temporary hitscan or beam trace.

function scr_tower_weapon_trace_draw(_tower)
{
    var _trace = _tower.combat.weapon.trace;

    if (!_trace.active)
        return true;


    // Outer heated beam or rail trail.

    draw_set_color(_trace.color_outer);
    draw_set_alpha(0.8);

    draw_line_width(
        _trace.start_x,
        _trace.start_y,
        _trace.end_x,
        _trace.end_y,
        _trace.width
    );


    // Bright inner beam core.

    draw_set_color(_trace.color_core);
    draw_set_alpha(0.9);

    draw_line_width(
        _trace.start_x,
        _trace.start_y,
        _trace.end_x,
        _trace.end_y,
        max(1, _trace.width * 0.35)
    );


    // Small impact point.

    draw_circle(
        _trace.end_x,
        _trace.end_y,
        max(2, _trace.width),
        true
    );


    // FUTURE PARTICLE HOOK:
    // Ember particles can be distributed between start and end.

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}