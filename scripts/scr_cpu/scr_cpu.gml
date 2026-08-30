/// @description CPU initialization, damage, and drawing.


/// @description Initializes the CPU.

function scr_cpu_initialize(_cpu)
{
    if (!instance_exists(_cpu))
        return false;

    _cpu.vitals =
    {
        hp:
        {
            current: 1000,
            maximum: 1000
        }
    };

    _cpu.alerts =
    {
        thresholds:
        [
            { percent: 0.75, triggered: false },
            { percent: 0.50, triggered: false },
            { percent: 0.25, triggered: false },
            { percent: 0.10, triggered: false }
        ],

        destroyed: false
    };

    _cpu.visual =
    {
        radius: 64,
        color: c_blue
    };
		
		_cpu.mask_index = s_collision_square;	
		
		
	var _cell = scr_building_position_to_cell(_cpu.x, _cpu.y);
	var _width = 3;
	var _height = 3;

	_cpu.footprint =
	{
	    width_cells: _width,
	    height_cells: _height,

	    origin:
	    {
	        x: _cell.x - floor(_width * 0.5),
	        y: _cell.y - floor(_height * 0.5)
	    }
	};

    global.vtd_level.entities.cpu = _cpu;

    show_debug_message(
        "VECTOR TD 2026 - CPU INITIALIZED"
    );

    return true;
}

/// @description Damages the CPU and resolves level failure at zero integrity.

function scr_cpu_damage(_cpu, _damage)
{
    if (!instance_exists(_cpu))
        return false;

    if (_damage <= 0)
        return false;

    if (global.LevelState != LevelState.PLAYING)
        return false;


    var _hp = _cpu.vitals.hp;

    var _previous_percent =
        clamp(
            _hp.current / max(1, _hp.maximum),
            0,
            1
        );

    _hp.current =
        max(
            0,
            _hp.current - _damage
        );

    var _current_percent =
        clamp(
            _hp.current / max(1, _hp.maximum),
            0,
            1
        );


    // CPU thresholds remain major centre alerts.

    for (var i = 0; i < array_length(_cpu.alerts.thresholds); ++i)
    {
        var _warning = _cpu.alerts.thresholds[i];

        if (_warning.triggered)
            continue;

        if (
            _previous_percent > _warning.percent
            && _current_percent <= _warning.percent
        )
        {
            _warning.triggered = true;

            var _type =
                _warning.percent <= 0.25
                ? HudAlertType.DANGER
                : HudAlertType.WARNING;


            scr_hud_major_alert_push(
                _type,
                "CPU UNDER ATTACK",

                string(round(_warning.percent * 100))
                + "% INTEGRITY REMAINING",

                4
            );
        }
    }


    if (_hp.current <= 0 && !_cpu.alerts.destroyed)
    {
        _cpu.alerts.destroyed = true;

        scr_level_result_resolve(
            false,
            "CPU CORE DESTROYED"
        );
    }


    return true;
}


/// @description Draws the CPU as a large sci-fi processor chip.

function scr_cpu_draw(_cpu)
{
    if (!instance_exists(_cpu))
        return false;


    var _x =
        _cpu.x;

    var _y =
        _cpu.y;

    var _radius =
        _cpu.visual.radius;

    var _spin =
        global.vtd.tick * 0.8;

    var _pulse =
        0.75
        + dsin(
            global.vtd.tick * 4
            + real(_cpu.id)
        ) * 0.2;


    var _green =
        make_color_rgb(
            50,
            210,
            95
        );

    var _lime =
        make_color_rgb(
            150,
            255,
            80
        );

    var _yellow =
        make_color_rgb(
            255,
            220,
            60
        );


    // ========================================================================
    // OUTER CPU CHIP BODY
    // ========================================================================

    draw_set_color(
        _green
    );


    draw_rectangle(
        _x - _radius,
        _y - _radius,
        _x + _radius,
        _y + _radius,
        true
    );


    draw_rectangle(
        _x - (_radius * 0.82),
        _y - (_radius * 0.82),
        _x + (_radius * 0.82),
        _y + (_radius * 0.82),
        true
    );


    // ========================================================================
    // CHIP CONTACT PINS
    // ========================================================================

    draw_set_color(
        _yellow
    );


    var _pin_count =
        6;

    var _pin_spacing =
        (_radius * 1.5)
        / (_pin_count - 1);


    for (var i = 0; i < _pin_count; ++i)
    {
        var _offset =
            -(_radius * 0.75)
            + (i * _pin_spacing);


        // Top.

        draw_line_width(
            _x + _offset,
            _y - _radius,
            _x + _offset,
            _y - _radius - 10,
            3
        );


        // Bottom.

        draw_line_width(
            _x + _offset,
            _y + _radius,
            _x + _offset,
            _y + _radius + 10,
            3
        );


        // Left.

        draw_line_width(
            _x - _radius,
            _y + _offset,
            _x - _radius - 10,
            _y + _offset,
            3
        );


        // Right.

        draw_line_width(
            _x + _radius,
            _y + _offset,
            _x + _radius + 10,
            _y + _offset,
            3
        );
    }


    // ========================================================================
    // INTERNAL CIRCUIT PATHS
    // ========================================================================

    draw_set_color(
        _green
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        -48,
        -34,

        -20,
        -34,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        -20,
        -34,

        -20,
        -16,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        48,
        -32,

        24,
        -32,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        24,
        -32,

        24,
        -14,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        -46,
        34,

        -26,
        34,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        -26,
        34,

        -26,
        17,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        48,
        30,

        25,
        30,

        2
    );


    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        0,

        25,
        30,

        25,
        15,

        2
    );


    // ========================================================================
    // CIRCUIT NODES
    // ========================================================================

    draw_set_color(
        _yellow
    );


    draw_circle(
        _x - 20,
        _y - 34,
        3,
        false
    );


    draw_circle(
        _x + 24,
        _y - 32,
        3,
        false
    );


    draw_circle(
        _x - 26,
        _y + 34,
        3,
        false
    );


    draw_circle(
        _x + 25,
        _y + 30,
        3,
        false
    );


    // ========================================================================
    // CENTRAL PROCESSOR PACKAGE
    // ========================================================================

    draw_set_color(
        _lime
    );


    draw_rectangle(
        _x - 26,
        _y - 26,
        _x + 26,
        _y + 26,
        true
    );


    draw_set_color(
        _yellow
    );


    draw_rectangle(
        _x - 19,
        _y - 19,
        _x + 19,
        _y + 19,
        true
    );


    // ========================================================================
    // ROTATING SCI-FI PROCESSOR CORE
    // ========================================================================

    draw_set_color(
        _green
    );


    scr_enemy_visual_helper_arc_segments(
        _x,
        _y,
        16,
        4,
        55,
        _spin,
        5,
        2
    );


    scr_enemy_visual_helper_diamond(
        _x,
        _y,
        10,
        -_spin * 1.5,
        2
    );


    // ========================================================================
    // ACTIVE CPU CORE
    // ========================================================================

    draw_set_alpha(
        _pulse
    );


    draw_set_color(
        _yellow
    );


    draw_circle(
        _x,
        _y,
        7,
        false
    );


    draw_set_color(
        _lime
    );


    draw_circle(
        _x,
        _y,
        3,
        true
    );


    draw_set_alpha(
        1
    );


    // ========================================================================
    // HEALTH BAR
    // ========================================================================

    var _hp_percent =
        clamp(
            _cpu.vitals.hp.current
            / _cpu.vitals.hp.maximum,
            0,
            1
        );


    var _bar_width =
        _radius * 2;

    var _bar_left =
        _x - _radius;

    var _bar_top =
        _y - _radius - 20;


    draw_set_color(
        c_dkgray
    );


    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left + _bar_width,
        _bar_top + 6,
        false
    );


    draw_set_color(
        c_lime
    );


    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left
            + (_bar_width * _hp_percent),
        _bar_top + 6,
        false
    );


    draw_set_color(
        c_white
    );


    draw_text(
        _x - 28,
        _y - 8,
        "CPU"
    );


    return true;
}