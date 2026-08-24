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


/// @description Draws the CPU.

function scr_cpu_draw(_cpu)
{
    if (!instance_exists(_cpu))
        return false;


    var _visual =
        _cpu.visual;

    var _radius =
        _visual.radius;


    // ========================================================================
    // VECTOR BODY
    // ========================================================================

    draw_set_color(
        _visual.color
    );

    draw_rectangle(
        _cpu.x - _radius,
        _cpu.y - _radius,
        _cpu.x + _radius,
        _cpu.y + _radius,
        false
    );


    draw_set_color(
        c_aqua
    );

    draw_rectangle(
        _cpu.x - _radius + 6,
        _cpu.y - _radius + 6,
        _cpu.x + _radius - 6,
        _cpu.y + _radius - 6,
        true
    );


    draw_set_color(
        _visual.color
    );

    draw_circle(
        _cpu.x,
        _cpu.y,
        _radius * 0.45,
        false
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
        _cpu.x - _radius;

    var _bar_top =
        _cpu.y - _radius - 14;


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
        _cpu.x - 28,
        _cpu.y - 8,
        "CPU"
    );


    return true;
}