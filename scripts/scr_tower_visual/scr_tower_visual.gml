/// @description Lightweight visual recoil for tower turrets.



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

    var _visual = _tower.visual;
    var _offset = scr_tower_recoil_offset_get(_tower);

    var _baked_used = scr_building_baked_draw(
        _tower,
        _visual.draw_angle,
        _offset.x,
        _offset.y,
        _visual.turret_color
    );

    if (!_baked_used)
    {
        if (_visual.sprite != -1 && sprite_exists(_visual.sprite))
        {
            draw_sprite_ext(
                _visual.sprite,
                0,
                _tower.x + _offset.x,
                _tower.y + _offset.y,
                _visual.scale_x,
                _visual.scale_y,
                _visual.draw_angle,
                _visual.sprite_color,
                1
            );
        }
        else
        {
            var _draw_function = _visual.draw_function;

            if (_offset.x == 0 && _offset.y == 0)
            {
                if (!is_undefined(_draw_function))
                    _draw_function(_tower);
                else
                    scr_tower_visual_ground(_tower);
            }
            else
            {
                var _previous_matrix = matrix_get(matrix_world);

                matrix_set(
                    matrix_world,
                    matrix_build(
                        _offset.x,
                        _offset.y,
                        0,
                        0,
                        0,
                        0,
                        1,
                        1,
                        1
                    )
                );

                if (!is_undefined(_draw_function))
                    _draw_function(_tower);
                else
                    scr_tower_visual_ground(_tower);

                matrix_set(matrix_world, _previous_matrix);
            }
        }
    }

    scr_tower_weapon_trace_draw(_tower);

    return true;
}
/// @description Draws the attack range of a selected tower.

function scr_tower_range_draw(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_struct_exists(global.vtd_level.entities, "hud"))
        return false;

    var _hud = global.vtd_level.entities.hud;

    if (!instance_exists(_hud))
        return false;

    if (_hud.hud.selection.target != _tower)
        return false;

    var _range = _tower.combat.range;

    draw_set_color(c_aqua);

    draw_set_alpha(0.035);
    draw_circle(_tower.x, _tower.y, _range, false);

    draw_set_alpha(0.65);
    draw_circle(_tower.x, _tower.y, _range, true);

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the Anti-Air Tower.

function scr_tower_visual_anti_air(_tower)
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
    // TRACKING BASE
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        18,
        8,
        _angle + 22.5,
        2
    );


    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        13,
        4,
        48,
        _spin,
        4,
        2
    );


    // ========================================================================
    // CENTRAL SENSOR
    // ========================================================================

    draw_circle(
        _x,
        _y,
        6,
        false
    );


    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        7,
        5,
        4,
        _spin,
        2
    );


    // ========================================================================
    // QUAD AA PRONGS
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        5,
        -8,

        29,
        -11,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        5,
        -3,

        32,
        -4,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        5,
        3,

        32,
        4,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        5,
        8,

        29,
        11,

        2
    );


    // ========================================================================
    // FRONT TARGETING NODE
    // ========================================================================

    var _node_x =
        _x
        + lengthdir_x(
            34,
            _angle
        );

    var _node_y =
        _y
        + lengthdir_y(
            34,
            _angle
        );


    draw_circle(
        _node_x,
        _node_y,
        3,
        true
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

/// @description Draws the Sniper Tower.

function scr_tower_visual_sniper(_tower)
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
    // PRECISION BASE
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        17,
        _angle,
        2
    );


    draw_circle(
        _x,
        _y,
        8,
        true
    );


    // ========================================================================
    // LONG RIFLE BODY
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -8,
        -4,

        20,
        4,

        2
    );


    // ========================================================================
    // EXTENDED BARREL
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        18,
        -2,

        45,
        2,

        2
    );


    // Muzzle brake.

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        45,
        -5,

        50,
        5,

        2
    );


    // ========================================================================
    // TARGETING SCOPE
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -1,
        -7,

        17,
        -7,

        2
    );


    var _scope_x =
        _x
        + lengthdir_x(
            10,
            _angle
        )
        + lengthdir_x(
            7,
            _angle - 90
        );

    var _scope_y =
        _y
        + lengthdir_y(
            10,
            _angle
        )
        + lengthdir_y(
            7,
            _angle - 90
        );


    draw_circle(
        _scope_x,
        _scope_y,
        3,
        true
    );


    // ========================================================================
    // REAR STOCK / ENERGY CELL
    // ========================================================================

    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,

        [
            [-18, -6],
            [-6, -4],
            [-6, 4],
            [-18, 6],
            [-13, 0]
        ],

        2
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


/// @description Draws the Mortar Tower.

function scr_tower_visual_mortar(_tower)
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
    // ARTILLERY PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        22,
        8,
        _angle + 22.5,
        3
    );


    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        16,
        6,
        4,
        _angle + 45,
        3
    );


    // ========================================================================
    // MORTAR CRADLE
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -11,
        -10,

        12,
        10,

        3
    );


    // Side supports.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -7,
        -12,

        12,
        -9,

        3
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        -7,
        12,

        12,
        9,

        3
    );


    // ========================================================================
    // LARGE SHORT MORTAR TUBE
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        5,
        -7,

        28,
        7,

        3
    );


    // Huge barrel opening.

    var _muzzle_x =
        _x
        + lengthdir_x(
            31,
            _angle
        );

    var _muzzle_y =
        _y
        + lengthdir_y(
            31,
            _angle
        );


    draw_circle(
        _muzzle_x,
        _muzzle_y,
        9,
        true
    );


    draw_circle(
        _muzzle_x,
        _muzzle_y,
        5,
        false
    );


    // ========================================================================
    // REAR AMMO HOUSING
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -18,
        -7,

        -8,
        7,

        2
    );


    draw_set_color(c_white);

    return true;
}

/// @description Draws the Anti-Air Rocket Tower.

function scr_tower_visual_aa_rocket(_tower)
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
        global.vtd.tick;


    draw_set_color(_color);


    // ========================================================================
    // HEAVY TRACKING PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        21,
        8,
        _angle + 22.5,
        3
    );


    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        14,
        4,
        52,
        _spin,
        4,
        2
    );


    // ========================================================================
    // MISSILE LAUNCHER BODY
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        _angle,

        -8,
        -13,

        27,
        13,

        3
    );


    // ========================================================================
    // FOUR LAUNCH CELLS
    // ========================================================================

    var _cell_x =
        19;

    var _cell_spacing =
        7;


    for (var i = 0; i < 4; ++i)
    {
        var _offset =
            -10.5
            + (i * _cell_spacing);


        var _rocket_x =
            _x
            + lengthdir_x(
                _cell_x,
                _angle
            )
            + lengthdir_x(
                _offset,
                _angle + 90
            );

        var _rocket_y =
            _y
            + lengthdir_y(
                _cell_x,
                _angle
            )
            + lengthdir_y(
                _offset,
                _angle + 90
            );


        draw_circle(
            _rocket_x,
            _rocket_y,
            3,
            true
        );
    }


    // ========================================================================
    // FRONT LAUNCHER EDGE
    // ========================================================================

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        27,
        -13,

        33,
        -10,

        3
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        27,
        13,

        33,
        10,

        3
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,

        33,
        -10,

        33,
        10,

        3
    );


    // ========================================================================
    // REAR RADAR / TARGETER
    // ========================================================================

    var _radar_x =
        _x
        + lengthdir_x(
            -15,
            _angle
        );

    var _radar_y =
        _y
        + lengthdir_y(
            -15,
            _angle
        );


    draw_circle(
        _radar_x,
        _radar_y,
        5,
        true
    );


    scr_enemy_visual_helper_radial_ticks(
        _radar_x,
        _radar_y,
        5,
        3,
        4,
        _spin * 2,
        1
    );


    draw_set_color(c_white);

    return true;
}
