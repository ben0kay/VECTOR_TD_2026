/// @description Draws one building's optional baked body and effects.

function scr_building_baked_draw(
    _building,
    _angle = 0,
    _offset_x = 0,
    _offset_y = 0,
    _color = c_white
)
{
    if (!instance_exists(_building))
        return false;

    var _baked = _building.visual.baked;

    if (is_undefined(_baked.body))
        return false;

    var _sprite = _baked.body();

    if (!sprite_exists(_sprite))
        return false;

    draw_sprite_ext(
        _sprite,
        0,
        _building.x + _offset_x,
        _building.y + _offset_y,
        1,
        1,
        _angle,
        _color,
        1
    );

    if (!is_undefined(_baked.effects))
    {
        _baked.effects(
            _building,
            _offset_x,
            _offset_y
        );
    }

    return true;
}

/// @description Draws the Solar Generator's vector assembly.

function scr_energy_generator_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _spin =
        global.vtd.tick * 0.75;

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 5
            + real(_building.id)
        ) * 0.2;


    draw_set_color(_color);


    // ========================================================================
    // CENTRAL GENERATOR FRAME
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        15,
        8,
        _spin,
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


        // Energy feed from panel to core.

        draw_line_width(
            _x + lengthdir_x(
                11,
                _angle
            ),

            _y + lengthdir_y(
                11,
                _angle
            ),

            _x + lengthdir_x(
                16,
                _angle
            ),

            _y + lengthdir_y(
                16,
                _angle
            ),

            2
        );
    }


    // ========================================================================
    // ACTIVE POWER CORE
    // ========================================================================

    draw_set_alpha(_pulse);

    draw_set_color(c_yellow);

    draw_circle(
        _x,
        _y,
        6,
        false
    );


    draw_circle(
        _x,
        _y,
        3,
        true
    );


    draw_set_alpha(1);

    draw_set_color(_color);


    // Small rotating energy nodes.

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        12,
        2,
        4,
        -_spin * 2,
        true
    );


    draw_set_color(c_white);

    return true;
}


/// @description Draws one local Energy Node.

function scr_energy_node_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _spin =
        global.vtd.tick * 2;

    var _pulse =
        0.7
        + dsin(
            global.vtd.tick * 6
            + real(_building.id)
        ) * 0.2;


    draw_set_color(_color);


    // ========================================================================
    // NODE FRAME
    // ========================================================================

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        13,
        _spin,
        2
    );


    draw_circle(
        _x,
        _y,
        8,
        false
    );


    // ========================================================================
    // NETWORK CONNECTOR ARMS
    // ========================================================================

    scr_enemy_visual_helper_spokes(
        _x,
        _y,
        8,
        17,
        4,
        45,
        2
    );


    // Connector terminals.

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        18,
        2.5,
        4,
        45,
        true
    );


    // ========================================================================
    // ACTIVE RELAY CORE
    // ========================================================================

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        4,
        false
    );


    draw_circle(
        _x,
        _y,
        2,
        true
    );


    draw_set_alpha(1);


    // Rotating short signal ticks.

    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        10,
        4,
        4,
        -_spin * 1.5,
        1
    );


    draw_set_color(c_white);

    return true;
}


/// @description Draws one Energy Battery and its stored-energy level.

function scr_energy_battery_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _battery =
        _building.energy.battery;


    var _ratio =
        clamp(
            _battery.current
            / max(
                1,
                _battery.maximum
            ),
            0,
            1
        );


    var _pulse =
        0.65
        + dsin(
            global.vtd.tick * 4
            + real(_building.id)
        ) * 0.15;


    draw_set_color(_color);


    // ========================================================================
    // HEAVY STORAGE FRAME
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        24,
        8,
        22.5,
        3
    );


    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        19,
        8,
        22.5,
        1
    );


    // Four structural braces.

    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        19,
        6,
        4,
        45,
        3
    );


    // ========================================================================
    // INTERNAL STORAGE CELLS
    // ========================================================================

    var _cell_width =
        7;

    var _cell_height =
        27;

    var _cell_spacing =
        10;


    for (var i = 0; i < 3; ++i)
    {
        var _cell_x =
            _x
            + ((i - 1) * _cell_spacing);


        // Cell shell.

        draw_rectangle(
            _cell_x - (_cell_width * 0.5),
            _y - (_cell_height * 0.5),

            _cell_x + (_cell_width * 0.5),
            _y + (_cell_height * 0.5),

            true
        );


        // Stored-energy fill.

        var _bottom =
            _y
            + (_cell_height * 0.5)
            - 2;

        var _top =
            lerp(
                _bottom,
                _y
                - (_cell_height * 0.5)
                + 2,
                _ratio
            );


        draw_set_alpha(
            0.25
            + (_ratio * 0.45)
        );


        draw_rectangle(
            _cell_x
                - (_cell_width * 0.5)
                + 2,

            _bottom,

            _cell_x
                + (_cell_width * 0.5)
                - 2,

            _top,

            false
        );


        draw_set_alpha(1);
    }


    // ========================================================================
    // CENTRAL CHARGE CORE
    // ========================================================================

    draw_set_alpha(
        _pulse
        * (
            0.4
            + (_ratio * 0.6)
        )
    );


    draw_circle(
        _x,
        _y,
        5,
        false
    );


    draw_circle(
        _x,
        _y,
        2,
        true
    );


    draw_set_alpha(1);


    // ========================================================================
    // CHARGE INDICATOR NODES
    // ========================================================================

    var _active_nodes =
        floor(
            _ratio * 4
            + 0.001
        );


    for (var i = 0; i < 4; ++i)
    {
        var _angle =
            45
            + (i * 90);

        var _node_x =
            _x
            + lengthdir_x(
                17,
                _angle
            );

        var _node_y =
            _y
            + lengthdir_y(
                17,
                _angle
            );


        if (i < _active_nodes)
        {
            draw_circle(
                _node_x,
                _node_y,
                2.5,
                false
            );
        }
        else
        {
            draw_circle(
                _node_x,
                _node_y,
                2,
                true
            );
        }
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the Credit Magnet.

function scr_utility_credit_magnet_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _spin =
        global.vtd.tick * 2.25;

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 5
            + real(_building.id)
        ) * 0.2;


    draw_set_color(_color);


    // ========================================================================
    // MAGNETIC BASE
    // ========================================================================

    scr_enemy_visual_helper_double_ring(
        _x,
        _y,
        19,
        11
    );


    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        23,
        4,
        42,
        _spin,
        5,
        2
    );


    // ========================================================================
    // MAGNETIC COILS
    // ========================================================================

    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        0,

        -20,
        -8,

        -9,
        8,

        2
    );


    scr_enemy_visual_helper_local_box(
        _x,
        _y,
        0,

        9,
        -8,

        20,
        8,

        2
    );


    // Coil separators.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,
        -16,
        -8,
        -16,
        8,
        1
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,
        16,
        -8,
        16,
        8,
        1
    );


    // ========================================================================
    // ORBITING COLLECTION PARTICLES
    // ========================================================================

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        27,
        2.5,
        6,
        -_spin * 1.5,
        true
    );


    // ========================================================================
    // COLLECTION CORE
    // ========================================================================

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        6,
        false
    );


    draw_circle(
        _x,
        _y,
        2.5,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the Repairer utility.

function scr_utility_repairer_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _spin =
        global.vtd.tick * 0.65;

    var _pulse =
        0.8
        + dsin(
            global.vtd.tick * 4
            + real(_building.id)
        ) * 0.15;


    draw_set_color(_color);


    // ========================================================================
    // MAINTENANCE PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        22,
        8,
        22.5,
        2
    );


    scr_enemy_visual_helper_double_ring(
        _x,
        _y,
        13,
        7
    );


    // ========================================================================
    // FOUR REPAIR ARMS
    // ========================================================================

    for (var i = 0; i < 4; ++i)
    {
        var _angle =
            _spin
            + (i * 90);


        var _arm_x =
            _x
            + lengthdir_x(
                16,
                _angle
            );

        var _arm_y =
            _y
            + lengthdir_y(
                16,
                _angle
            );


        scr_enemy_visual_helper_local_line(
            _x,
            _y,
            _angle,

            9,
            0,

            21,
            0,

            3
        );


        // Tool head.

        scr_enemy_visual_helper_local_polygon(
            _arm_x,
            _arm_y,
            _angle,

            [
                [3, -4],
                [8, -2],
                [8, 2],
                [3, 4],
                [-2, 2],
                [-2, -2]
            ],

            2
        );
    }


    // ========================================================================
    // DIAGNOSTIC CROSS
    // ========================================================================

    draw_line_width(
        _x - 5,
        _y,
        _x + 5,
        _y,
        2
    );


    draw_line_width(
        _x,
        _y - 5,
        _x,
        _y + 5,
        2
    );


    // ========================================================================
    // ACTIVE CORE
    // ========================================================================

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        4,
        false
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the Credit Uplink.

function scr_utility_credit_uplink_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _spin =
        global.vtd.tick * 1.25;

    var _pulse =
        0.7
        + dsin(
            global.vtd.tick * 5
            + real(_building.id)
        ) * 0.25;


    draw_set_color(_color);


    // ========================================================================
    // DATA PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        21,
        6,
        30,
        2
    );


    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        14,
        6,
        0,
        2
    );


    // ========================================================================
    // COMMUNICATION ARRAY
    // ========================================================================

    scr_enemy_visual_helper_spokes(
        _x,
        _y,
        7,
        18,
        3,
        -90,
        2
    );


    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        18,
        3,
        3,
        -90,
        false
    );


    // ========================================================================
    // ROTATING DATA RING
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        25,
        3,
        50,
        _spin,
        5,
        2
    );


    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        25,
        2,
        3,
        _spin + 25,
        true
    );


    // ========================================================================
    // UPLINK CORE
    // ========================================================================

    draw_set_alpha(_pulse);

    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        7,
        -_spin * 1.5,
        2
    );


    draw_circle(
        _x,
        _y,
        2.5,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws the Radar utility.

function scr_utility_radar_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _sweep =
        global.vtd.tick * 1.75;

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 4
            + real(_building.id)
        ) * 0.2;


    draw_set_color(_color);


    // ========================================================================
    // RADAR DISH / PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_double_ring(
        _x,
        _y,
        23,
        13
    );


    scr_enemy_visual_helper_radial_ticks(
        _x,
        _y,
        18,
        5,
        8,
        22.5,
        1
    );


    // ========================================================================
    // ROTATING SCANNER ARM
    // ========================================================================

    draw_line_width(
        _x,
        _y,

        _x + lengthdir_x(
            30,
            _sweep
        ),

        _y + lengthdir_y(
            30,
            _sweep
        ),

        3
    );


    // Small cross-arm near the scanner head.

    var _head_x =
        _x
        + lengthdir_x(
            23,
            _sweep
        );

    var _head_y =
        _y
        + lengthdir_y(
            23,
            _sweep
        );


    scr_enemy_visual_helper_local_line(
        _head_x,
        _head_y,
        _sweep,

        0,
        -6,

        0,
        6,

        2
    );


    // ========================================================================
    // SIGNAL RETURNS
    // ========================================================================

    var _return_angle_1 =
        _sweep - 45;

    var _return_angle_2 =
        _sweep - 115;


    draw_circle(
        _x + lengthdir_x(
            16,
            _return_angle_1
        ),

        _y + lengthdir_y(
            16,
            _return_angle_1
        ),

        2.5,
        true
    );


    draw_circle(
        _x + lengthdir_x(
            20,
            _return_angle_2
        ),

        _y + lengthdir_y(
            20,
            _return_angle_2
        ),

        2,
        true
    );


    // ========================================================================
    // CENTRAL SENSOR
    // ========================================================================

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        6,
        false
    );


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

/// @description Draws the Shield Generator utility.

function scr_utility_shield_generator_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _x =
        _building.x;

    var _y =
        _building.y;

    var _color =
        _building.visual.color;

    var _spin =
        global.vtd.tick * 1.2;

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 4
            + real(_building.id)
        ) * 0.2;


    draw_set_color(_color);


    // ========================================================================
    // HEAVY HEXAGONAL PLATFORM
    // ========================================================================

    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        25,
        6,
        30,
        3
    );


    scr_enemy_visual_helper_polygon(
        _x,
        _y,
        19,
        6,
        0,
        2
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


        draw_circle(
            _node_x,
            _node_y,
            4,
            false
        );


        draw_line_width(
            _x
                + lengthdir_x(
                    13,
                    _angle
                ),

            _y
                + lengthdir_y(
                    13,
                    _angle
                ),

            _node_x,
            _node_y,

            2
        );
    }


    // ========================================================================
    // FIELD CONTAINMENT RINGS
    // ========================================================================

    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        16,
        6,
        35,
        _spin,
        4,
        2
    );


    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        11,
        3,
        70,
        -_spin * 1.5,
        5,
        2
    );


    // ========================================================================
    // SHIELD REACTOR
    // ========================================================================

    draw_set_alpha(_pulse);


    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        8,
        _spin * 2,
        2
    );


    draw_circle(
        _x,
        _y,
        4,
        false
    );


    draw_circle(
        _x,
        _y,
        2,
        true
    );


    draw_set_alpha(1);


    // ========================================================================
    // FIELD PARTICLES
    // ========================================================================

    scr_enemy_visual_helper_radial_dots(
        _x,
        _y,
        29,
        2,
        6,
        -_spin,
        true
    );


    draw_set_color(c_white);

    return true;
}

