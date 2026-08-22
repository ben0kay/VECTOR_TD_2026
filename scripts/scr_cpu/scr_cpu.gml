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
            current:
                1000,

            maximum:
                1000
        }
    };


    _cpu.visual =
    {
        radius:
            64,

        color:
            c_blue
    };


    global.vtd_level.entities.cpu =
        _cpu;


    show_debug_message(
        "VECTOR TD 2026 - CPU INITIALIZED"
    );


    return true;
}


/// @description Applies damage to the CPU.

function scr_cpu_damage(
    _cpu,
    _damage
)
{
    if (!instance_exists(_cpu))
        return false;

    if (_damage <= 0)
        return false;

    if (
        global.LevelState
        != LevelState.PLAYING
    )
    {
        return false;
    }


    _cpu.vitals.hp.current =
        max(
            0,
            _cpu.vitals.hp.current
            - _damage
        );


    if (_cpu.vitals.hp.current <= 0)
    {
        global.LevelState =
            LevelState.FAILED;


        show_debug_message(
            "VECTOR TD 2026 - CPU DESTROYED"
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