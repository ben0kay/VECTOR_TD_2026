function scr_hud_alert_color_get(_type)
{
    switch (_type)
    {
        case HudAlertType.INFO:
            return c_aqua;

        case HudAlertType.WARNING:
            return c_yellow;

        case HudAlertType.DANGER:
            return c_red;

        case HudAlertType.MILESTONE:
            return c_fuchsia;

        case HudAlertType.SUCCESS:
            return c_lime;
    }


    return c_white;
}


/// @description Queues one reusable level HUD alert.

function scr_hud_alert_push(
    _type,
    _title,
    _message,
    _duration_seconds = 4
)
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(
        global.vtd_level.entities,
        "hud"
    ))
    {
        return false;
    }


    var _hud =
        global.vtd_level.entities.hud;

    if (!instance_exists(_hud))
        return false;


    array_push(
        _hud.hud.alerts.queue,
        {
            type: _type,
            title: _title,
            message: _message,

            color:
                scr_hud_alert_color_get(_type),

            duration:
                max(0.5, _duration_seconds),

            hold_remaining:
                max(0.5, _duration_seconds),

            state:
                HudAlertState.OPENING,

            progress: 0
        }
    );


    return true;
}


/// @description Processes the active alert and advances the queue.

function scr_hud_alert_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _alerts =
        _hud.hud.alerts;


    if (
        is_undefined(_alerts.active)
        && array_length(_alerts.queue) > 0
    )
    {
        var _queue = _alerts.queue;

        _alerts.active = _queue[0];

        array_delete(_queue, 0, 1);

        _alerts.queue = _queue;
    }


    if (is_undefined(_alerts.active))
        return true;


    var _alert =
        _alerts.active;

    var _step_seconds =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    switch (_alert.state)
    {
        case HudAlertState.OPENING:
        {
            _alert.progress = min(
                1,
                _alert.progress
                + _alerts.opening_speed
            );


            if (_alert.progress >= 1)
                _alert.state = HudAlertState.HOLDING;
        }
        break;


        case HudAlertState.HOLDING:
        {
            _alert.hold_remaining = max(
                0,
                _alert.hold_remaining
                - _step_seconds
            );


            if (_alert.hold_remaining <= 0)
                _alert.state = HudAlertState.CLOSING;
        }
        break;


        case HudAlertState.CLOSING:
        {
            _alert.progress = max(
                0,
                _alert.progress
                - _alerts.closing_speed
            );


            if (_alert.progress <= 0)
                _alerts.active = undefined;
        }
        break;
    }


    return true;
}


/// @description Draws the active animated vector alert.

function scr_hud_alert_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _alerts =
        _hud.hud.alerts;

    if (is_undefined(_alerts.active))
        return true;


    var _alert =
        _alerts.active;

    var _gui_width =
        display_get_gui_width();

    var _center_x =
        _gui_width * 0.5;

    var _center_y =
        _hud.hud.top.height + 58;


    // The horizontal line opens first, then the panel gains height.

    var _line_progress =
        _alert.progress;

    var _panel_progress = clamp(
        (_alert.progress - 0.25) / 0.75,
        0,
        1
    );


    var _half_width =
        (_alerts.width * 0.5)
        * _line_progress;

    var _half_height =
        (_alerts.height * 0.5)
        * _panel_progress;

    var _left = _center_x - _half_width;
    var _right = _center_x + _half_width;
    var _top = _center_y - _half_height;
    var _bottom = _center_y + _half_height;


    var _pulse = 1;


    if (
        _alert.type == HudAlertType.DANGER
        || _alert.type == HudAlertType.MILESTONE
    )
    {
        _pulse =
            0.75
            + (sin(global.vtd.tick * 9) * 0.2);
    }


    // ========================================================================
    // OPENING VECTOR LINE
    // ========================================================================

    draw_set_alpha(_pulse);
    draw_set_color(_alert.color);

    draw_line_width(
        _left,
        _center_y,
        _right,
        _center_y,
        2
    );


    if (_panel_progress <= 0)
    {
        draw_set_alpha(1);
        return true;
    }


    // ========================================================================
    // PANEL SHELL
    // ========================================================================

    draw_set_alpha(
        0.88
        * _panel_progress
    );

    draw_set_color(c_black);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    draw_set_alpha(_pulse);
    draw_set_color(_alert.color);

    draw_line_width(
        _left + 16,
        _top,
        _right - 16,
        _top,
        2
    );

    draw_line_width(
        _left + 16,
        _bottom,
        _right - 16,
        _bottom,
        2
    );


    // Angled vector corners.

    draw_line(_left, _center_y, _left + 16, _top);
    draw_line(_left, _center_y, _left + 16, _bottom);

    draw_line(_right - 16, _top, _right, _center_y);
    draw_line(_right - 16, _bottom, _right, _center_y);


    // Centre ticks.

    draw_line(
        _center_x,
        _top - 5,
        _center_x,
        _top + 5
    );

    draw_line(
        _center_x,
        _bottom - 5,
        _center_x,
        _bottom + 5
    );


    // ========================================================================
    // TEXT
    // ========================================================================

    if (_panel_progress >= 0.7)
    {
        var _text_alpha = clamp(
            (_panel_progress - 0.7) / 0.3,
            0,
            1
        );


        draw_set_alpha(_text_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(_alert.color);

        draw_text(
            _center_x,
            _center_y - 13,
            string_upper(_alert.title)
        );


        draw_set_color(c_white);

        draw_text(
            _center_x,
            _center_y + 13,
            _alert.message
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}