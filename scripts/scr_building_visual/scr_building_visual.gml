/// @description Draws one generator's temporary vector assembly.

function scr_energy_generator_draw(_building)
{
    var _pulse = 0.75 + sin(global.vtd.tick * 4) * 0.15;

    draw_set_color(c_aqua);
    draw_rectangle(
        _building.x - 22,
        _building.y - 14,
        _building.x + 22,
        _building.y + 14,
        false
    );

    draw_line(_building.x - 22, _building.y, _building.x + 22, _building.y);
    draw_line(_building.x, _building.y - 14, _building.x, _building.y + 14);

    draw_set_alpha(_pulse);
    draw_set_color(c_yellow);
    draw_circle(_building.x, _building.y, 6, true);

    draw_set_alpha(1);
    draw_set_color(c_white);
}


/// @description Draws one local energy node.

function scr_energy_node_draw(_building)
{
    var _pulse = 12 + sin(global.vtd.tick * 5) * 2;

    draw_set_color(c_aqua);
    draw_circle(_building.x, _building.y, _pulse, false);
    draw_circle(_building.x, _building.y, 4, true);

    for (var i = 0; i < 4; ++i)
    {
        var _angle = 45 + (i * 90);

        draw_line(
            _building.x + lengthdir_x(6, _angle),
            _building.y + lengthdir_y(6, _angle),
            _building.x + lengthdir_x(17, _angle),
            _building.y + lengthdir_y(17, _angle)
        );
    }

    draw_set_color(c_white);
}


/// @description Draws one network battery and its stored-energy level.

function scr_energy_battery_draw(_building)
{
    var _battery = _building.energy.battery;

    var _ratio =
        _battery.current
        / max(1, _battery.maximum);

    draw_set_color(c_lime);

    draw_rectangle(
        _building.x - 18,
        _building.y - 24,
        _building.x + 18,
        _building.y + 24,
        true
    );

    draw_rectangle(
        _building.x - 7,
        _building.y - 29,
        _building.x + 7,
        _building.y - 24,
        true
    );

    draw_set_alpha(0.4);
    draw_set_color(c_lime);

    draw_rectangle(
        _building.x - 14,
        _building.y + 20,
        _building.x + 14,
        lerp(_building.y + 20, _building.y - 20, _ratio),
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// @description Draws the Credit Magnet's vector assembly.

function scr_utility_credit_magnet_draw(_utility)
{
    var _pulse =
        0.75
        + sin(
            global.vtd.tick * 5
            + real(_utility.id)
        ) * 0.2;

    var _color =
        make_color_rgb(
            190,
            70,
            255
        );


    draw_set_color(_color);

    draw_circle(
        _utility.x,
        _utility.y,
        17,
        false
    );

    scr_draw_arc(
    _utility.x - 9,
    _utility.y,
    9,
    90,
    270
	);

	scr_draw_arc(
	    _utility.x + 9,
	    _utility.y,
	    9,
	    270,
	    90
	);


    draw_line_width(
        _utility.x - 9,
        _utility.y + 9,
        _utility.x - 9,
        _utility.y + 20,
        3
    );

    draw_line_width(
        _utility.x + 9,
        _utility.y + 9,
        _utility.x + 9,
        _utility.y + 20,
        3
    );


    draw_set_alpha(_pulse);
    draw_circle(
        _utility.x,
        _utility.y,
        5,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
}


/// @description Draws the Restoration Array and its active repair beam.

function scr_utility_repairer_draw(_utility)
{
    if (!instance_exists(_utility))
        return false;


    var _runtime = _utility.utility;

    var _color_outer =
        make_color_rgb(30, 170, 100);

    var _color_core =
        make_color_rgb(150, 255, 205);

    var _pulse =
        0.7
        + dsin(
            global.vtd.tick * 6
            + real(_utility.id)
        ) * 0.2;


    // ========================================================================
    // RESTORATION ARRAY ASSEMBLY
    // ========================================================================

    draw_set_color(_color_core);

    draw_circle(
        _utility.x,
        _utility.y,
        16,
        false
    );

    draw_circle(
        _utility.x,
        _utility.y,
        9,
        true
    );


    // Medical/restoration cross.

    draw_line_width(
        _utility.x - 11,
        _utility.y,
        _utility.x + 11,
        _utility.y,
        4
    );

    draw_line_width(
        _utility.x,
        _utility.y - 11,
        _utility.x,
        _utility.y + 11,
        4
    );


    draw_set_alpha(_pulse);
    draw_circle(
        _utility.x,
        _utility.y,
        4,
        false
    );


    // ========================================================================
    // ACTIVE REPAIR BEAM
    // ========================================================================

    if (
        _runtime.feedback.remaining > 0
        && instance_exists(_runtime.target)
    )
    {
        var _beam_alpha =
            clamp(
                _runtime.feedback.remaining
                / max(
                    0.001,
                    _runtime.feedback.duration
                ),
                0,
                1
            );

        scr_draw_beam(
            _utility.x,
            _utility.y,
            _runtime.target.x,
            _runtime.target.y,
            _color_outer,
            _color_core,
            5,
            _beam_alpha,
            7
        );


        // Expanding repair confirmation ring.

        var _repair_progress =
            1 - _beam_alpha;

        draw_set_color(_color_core);
        draw_set_alpha(_beam_alpha);

        draw_circle(
            _runtime.target.x,
            _runtime.target.y,
            10 + (_repair_progress * 18),
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the passive Credit Uplink.

function scr_utility_credit_uplink_draw(_utility)
{
    var _runtime =
        _utility.utility;

    var _pulse =
        0.6
        + sin(
            global.vtd.tick * 4
            + real(_utility.id)
        ) * 0.25;


    draw_set_color(c_yellow);

    draw_rectangle(
        _utility.x - 17,
        _utility.y - 12,
        _utility.x + 17,
        _utility.y + 12,
        true
    );

    draw_line(
        _utility.x,
        _utility.y - 20,
        _utility.x,
        _utility.y + 12
    );

    draw_line(
        _utility.x,
        _utility.y - 20,
        _utility.x - 9,
        _utility.y - 29
    );

    draw_line(
        _utility.x,
        _utility.y - 20,
        _utility.x + 9,
        _utility.y - 29
    );


    draw_set_alpha(_pulse);

    draw_circle(
        _utility.x,
        _utility.y,
        6,
        true
    );


    if (_runtime.feedback.remaining > 0)
    {
        var _radius =
            12
            + (
                1
                - _runtime.feedback.remaining
                / max(
                    0.001,
                    _runtime.feedback.duration
                )
            ) * 18;

        draw_circle(
            _utility.x,
            _utility.y,
            _radius,
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// @description Draws the Radar Array and its active detection pulse.

function scr_utility_radar_draw(_utility)
{
    if (!instance_exists(_utility))
        return false;


    var _runtime =
        _utility.utility;

    var _radar =
        _runtime.radar;

    var _x =
        _utility.x;

    var _y =
        _utility.y;

    var _angle =
        _radar.sweep_angle;

    var _color =
        _radar.color;


    var _pulse =
        0.7
        + dsin(
            (global.vtd.tick * 5)
            + real(_utility.id)
        ) * 0.2;


    // ========================================================================
    // VECTOR BASE
    // ========================================================================

    draw_set_color(_color);
    draw_set_alpha(0.8);

    draw_circle(
        _x,
        _y,
        20,
        false
    );

    draw_circle(
        _x,
        _y,
        13,
        false
    );


    // Four support braces.

    for (var i = 0; i < 4; ++i)
    {
        var _brace_angle =
            45
            + (i * 90);


        draw_line(
            _x + lengthdir_x(13, _brace_angle),
            _y + lengthdir_y(13, _brace_angle),

            _x + lengthdir_x(22, _brace_angle),
            _y + lengthdir_y(22, _brace_angle)
        );
    }


    // ========================================================================
    // ROTATING RADAR DISH
    // ========================================================================

    var _dish_x =
        _x
        + lengthdir_x(
            18,
            _angle
        );

    var _dish_y =
        _y
        + lengthdir_y(
            18,
            _angle
        );


    draw_set_alpha(1);

    draw_line_width(
        _x,
        _y,
        _dish_x,
        _dish_y,
        3
    );


    var _dish_left_x =
        _dish_x
        + lengthdir_x(
            10,
            _angle + 125
        );

    var _dish_left_y =
        _dish_y
        + lengthdir_y(
            10,
            _angle + 125
        );

    var _dish_right_x =
        _dish_x
        + lengthdir_x(
            10,
            _angle - 125
        );

    var _dish_right_y =
        _dish_y
        + lengthdir_y(
            10,
            _angle - 125
        );


    draw_line_width(
        _dish_left_x,
        _dish_left_y,
        _dish_x,
        _dish_y,
        2
    );

    draw_line_width(
        _dish_x,
        _dish_y,
        _dish_right_x,
        _dish_right_y,
        2
    );


    // ========================================================================
    // SWEEP LINE
    // ========================================================================

    draw_set_alpha(0.28);

    draw_line(
        _x,
        _y,
        _x + lengthdir_x(192, _angle),
        _y + lengthdir_y(192, _angle)
    );


    // Faint trailing sweep lines.

    draw_set_alpha(0.12);

    for (var i = 1; i <= 3; ++i)
    {
        var _trail_angle =
            _angle
            - (i * 8);


        draw_line(
            _x,
            _y,
            _x + lengthdir_x(84, _trail_angle),
            _y + lengthdir_y(84, _trail_angle)
        );
    }


    // ========================================================================
    // EXPANDING DETECTION PULSE
    // ========================================================================

    if (_radar.pulse.active)
    {
        var _progress =
            clamp(
                _radar.pulse.progress,
                0,
                1
            );

        var _radius =
            lerp(
                20,
                _runtime.range,
                _progress
            );

        var _alpha =
            1 - _progress;


        // Pulse begins 3 pixels thick and gradually becomes 1 pixel thick.

        var _thickness =
            lerp(
                4,
                1,
                _progress
            );


        // Main pulse ring.
        //
        // Multiple circles are used so thickness can smoothly decrease
        // without requiring a separate circle-width helper.

        draw_set_alpha(
            _alpha * 0.55
        );


        draw_circle(
            _x,
            _y,
            _radius,
            true
        );


        if (_thickness > 1.35)
        {
            draw_set_alpha(
                _alpha
                * 0.42
                * clamp(
                    _thickness - 1,
                    0,
                    1
                )
            );

            draw_circle(
                _x,
                _y,
                max(
                    0,
                    _radius - 1
                ),
                true
            );
        }


        if (_thickness > 2.1)
        {
            draw_set_alpha(
                _alpha
                * 0.28
                * clamp(
                    _thickness - 2,
                    0,
                    1
                )
            );

            draw_circle(
                _x,
                _y,
                max(
                    0,
                    _radius - 2
                ),
                true
            );
        }


        // Faint inner echo ring.

        draw_set_alpha(
            _alpha * 0.12
        );

        draw_circle(
            _x,
            _y,
            max(
                0,
                _radius - 5
            ),
            true
        );
    }


    // ========================================================================
    // CENTRAL STATUS LIGHT
    // ========================================================================

    draw_set_alpha(_pulse);
    draw_set_color(c_white);

    draw_circle(
        _x,
        _y,
        4,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}
