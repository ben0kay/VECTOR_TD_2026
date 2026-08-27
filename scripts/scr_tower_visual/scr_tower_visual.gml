
/// @description Draws the Basic Tower.

function scr_tower_visual_ground(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;


    draw_set_color(_color);


    // ========================================================================
    // ROTATING BASE PLATE
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        20,
        _angle,
        2
    );


    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        14,
        5,
        4,
        _angle,
        2
    );


    // ========================================================================
    // CENTRAL TURRET
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        11,
        6,
        _angle + 30,
        2
    );


    draw_circle(
        _x,
        _y,
        5,
        false
    );


    // ========================================================================
    // MAIN CANNON
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        7,
        -4,

        31,
        4,

        2
    );


    // Narrow muzzle extension.

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        31,
        -2.5,

        38,
        2.5,

        2
    );


    // ========================================================================
    // REAR COUNTERWEIGHT
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -14,
        -5,

        -5,
        5,

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

/// @description Draws the Twin Minigun Tower.

function scr_tower_visual_minigun(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;


    draw_set_color(_color);


    // ========================================================================
    // LOW ROTARY BASE
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        19,
        8,
        _angle + 22.5,
        2
    );


    draw_circle(
        _x,
        _y,
        12,
        true
    );


    // ========================================================================
    // CENTRAL WEAPON HOUSING
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -9,
        -10,

        15,
        10,

        2
    );


    // ========================================================================
    // LEFT MINIGUN
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        10,
        -10,

        34,
        -4,

        2
    );


    // ========================================================================
    // RIGHT MINIGUN
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        10,
        4,

        34,
        10,

        2
    );


    // Barrel tips.

    var _left_x =
        _x
        + lengthdir_x(38, _angle)
        + lengthdir_x(7, _angle - 90);

    var _left_y =
        _y
        + lengthdir_y(38, _angle)
        + lengthdir_y(7, _angle - 90);


    var _right_x =
        _x
        + lengthdir_x(38, _angle)
        + lengthdir_x(7, _angle + 90);

    var _right_y =
        _y
        + lengthdir_y(38, _angle)
        + lengthdir_y(7, _angle + 90);


    draw_circle(
        _left_x,
        _left_y,
        4,
        true
    );

    draw_circle(
        _right_x,
        _right_y,
        4,
        true
    );


    // ========================================================================
    // REAR AMMO / MOTOR BLOCK
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -17,
        -8,

        -7,
        8,

        2
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the heavy Explosive Cannon Tower.

function scr_tower_visual_cannon(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;


    draw_set_color(_color);


    // ========================================================================
    // HEAVY OCTAGONAL PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        22,
        8,
        _angle + 22.5,
        3
    );


    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        15,
        8,
        _angle,
        2
    );


    // Reinforcing mounts.

    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        17,
        5,
        4,
        _angle + 45,
        3
    );


    // ========================================================================
    // LARGE BREECH
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -10,
        -9,

        14,
        9,

        3
    );


    // ========================================================================
    // HEAVY BARREL
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        10,
        -6,

        34,
        6,

        3
    );


    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        34,
        -7,

        41,
        7,

        3
    );


    // ========================================================================
    // REAR RECOIL ASSEMBLY
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -19,
        -6,

        -8,
        6,

        2
    );


    draw_circle(
        _x,
        _y,
        5,
        false
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the Shield Laser Tower.

function scr_tower_visual_laser(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;

    var _spin =
        global.vtd.tick * 2;


    draw_set_color(_color);


    // ========================================================================
    // ENERGY BASE
    // ========================================================================

    scr_enemy_visual_helper_double_ring(
        _x,
        _y,
        18,
        11
    );


    // Slowly rotating energy nodes.

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        15,
        2,
        4,
        _spin,
        true
    );


    // ========================================================================
    // FOCUSING ARMS
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        2,
        -9,

        27,
        -4,

        3
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        2,
        9,

        27,
        4,

        3
    );


    // Rear braces.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -9,
        -7,

        7,
        -9,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -9,
        7,

        7,
        9,

        2
    );


    // ========================================================================
    // LASER FOCUS
    // ========================================================================

    var _focus_x =
        _x
        + lengthdir_x(31, _angle);

    var _focus_y =
        _y
        + lengthdir_y(31, _angle);


    draw_circle(
        _focus_x,
        _focus_y,
        5,
        true
    );


    draw_circle(
        _focus_x,
        _focus_y,
        2,
        false
    );


    // Central reactor.

    draw_circle(
        _x,
        _y,
        5,
        false
    );


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
    if (!instance_exists(_tower))
        return false;

    var _trace =
        _tower.combat.weapon.trace;

    if (!_trace.active)
        return true;


    scr_draw_beam(
        _trace.start_x,
        _trace.start_y,
        _trace.end_x,
        _trace.end_y,
        _trace.color_outer,
        _trace.color_core,
        _trace.width,
        0.9,
        max(2, _trace.width)
    );


    // FUTURE PARTICLE HOOK:
    // Laser embers can be distributed along this trace.
    // Restoration beams can use floating repair particles.
    // Energy links can animate packets travelling between endpoints.


    return true;
}

/// @description Draws the Cryo Tower.

function scr_tower_visual_cryo(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;

    var _spin =
        global.vtd.tick * 1.5;


    draw_set_color(_color);


    // ========================================================================
    // CRYOGENIC CORE
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        15,
        6,
        _spin,
        2
    );


    scr_enemy_visual_helper_spokes(
        _x,
        _y,
        5,
        17,
        6,
        _spin,
        2
    );


    draw_circle(
        _x,
        _y,
        5,
        false
    );


    // ========================================================================
    // COOLANT PRONGS
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        5,
        -9,

        26,
        -6,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        5,
        9,

        26,
        6,

        2
    );


    // Inner emitter rail.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        8,
        0,

        34,
        0,

        3
    );


    // ========================================================================
    // CRYO EMITTER
    // ========================================================================

    var _emitter_x =
        _x
        + lengthdir_x(38, _angle);

    var _emitter_y =
        _y
        + lengthdir_y(38, _angle);


    draw_circle(
        _emitter_x,
        _emitter_y,
        6,
        true
    );


    draw_circle(
        _emitter_x,
        _emitter_y,
        3,
        false
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the Stasis Tower.

function scr_tower_visual_stasis(_tower)
{
    var _x =
        _tower.x;

    var _y =
        _tower.y;

    var _angle =
        _tower.visual.draw_angle;

    var _color =
        _tower.visual.turret_color;

    var _spin =
        global.vtd.tick * -1.5;


    draw_set_color(_color);


    // ========================================================================
    // CONTAINMENT FIELD
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        19,
        4,
        55,
        _spin,
        5,
        2
    );


    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        13,
        4,
        42,
        -_spin,
        4,
        2
    );


    // ========================================================================
    // CENTRAL FIELD CORE
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        8,
        _spin,
        2
    );


    draw_circle(
        _x,
        _y,
        3,
        false
    );


    // ========================================================================
    // STASIS PROJECTOR
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        7,
        -3,

        30,
        3,

        2
    );


    // Forked emitter.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        27,
        -3,

        38,
        -6,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        27,
        3,

        38,
        6,

        2
    );


    var _emitter_x =
        _x
        + lengthdir_x(38, _angle);

    var _emitter_y =
        _y
        + lengthdir_y(38, _angle);


    draw_circle(
        _emitter_x,
        _emitter_y,
        3,
        false
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the Disruptor Tower.

function scr_tower_visual_disruptor(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;
    var _spin = global.vtd.tick * -3 + real(_tower.id);

    draw_set_color(_color);

    for (var i = 0; i < 3; ++i)
    {
        var _a = _spin + (i * 120);

        draw_line_width(
            _x + lengthdir_x(7, _a),
            _y + lengthdir_y(7, _a),
            _x + lengthdir_x(18, _a + 25),
            _y + lengthdir_y(18, _a + 25),
            2
        );
    }

    draw_circle(_x, _y, 7, false);

    draw_line_width(
        _x,
        _y,
        _x + lengthdir_x(34, _angle),
        _y + lengthdir_y(34, _angle),
        3
    );

    draw_set_color(c_white);

    return true;
}

/// @description Draws the Mortar Tower.

function scr_tower_visual_mortar(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    draw_set_color(_color);

    draw_circle(_x, _y, 17, false);
    draw_circle(_x, _y, 10, false);

    draw_line_width(
        _x + lengthdir_x(4, _angle),
        _y + lengthdir_y(4, _angle),
        _x + lengthdir_x(29, _angle),
        _y + lengthdir_y(29, _angle),
        8
    );

    draw_circle(
        _x + lengthdir_x(30, _angle),
        _y + lengthdir_y(30, _angle),
        6,
        false
    );

    draw_set_color(c_white);

    return true;
}

/// @description Draws the twin-launcher AA Rocket Tower.

function scr_tower_visual_aa_rocket(_tower)
{
    var _x = _tower.x;
    var _y = _tower.y;
    var _angle = _tower.visual.draw_angle;
    var _color = _tower.visual.turret_color;

    var _side_x = lengthdir_x(7, _angle + 90);
    var _side_y = lengthdir_y(7, _angle + 90);

    draw_set_color(_color);

    draw_circle(_x, _y, 15, true);

    for (var side = -1; side <= 1; side += 2)
    {
        var _sx = _x + (_side_x * side);
        var _sy = _y + (_side_y * side);

        var _ex = _sx + lengthdir_x(34, _angle);
        var _ey = _sy + lengthdir_y(34, _angle);

        draw_line_width(_sx, _sy, _ex, _ey, 5);

        draw_triangle(
            _ex + lengthdir_x(5, _angle),
            _ey + lengthdir_y(5, _angle),

            _ex + lengthdir_x(5, _angle + 135),
            _ey + lengthdir_y(5, _angle + 135),

            _ex + lengthdir_x(5, _angle - 135),
            _ey + lengthdir_y(5, _angle - 135),
            true
        );
    }

    draw_set_color(c_white);

    return true;
}