/// @description Adds or refreshes one side-HUD notification.

function scr_hud_notification_push(
    _key,
    _title,
    _message,
    _color = c_white,
    _duration_seconds = 3
)
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    var _hud = global.vtd_level.entities.hud;

    if (!instance_exists(_hud))
        return false;

    var _system = _hud.hud.notifications;
    var _active = _system.active;

    _key = string(_key);


    // Refresh an existing notification with the same key.

    for (var i = 0; i < array_length(_active); ++i)
    {
        var _notification = _active[i];

        if (_notification.key != _key)
            continue;

        _notification.title = _title;
        _notification.message = _message;
        _notification.color = _color;
        _notification.remaining = max(0.5, _duration_seconds);
        _notification.removing = false;

        return true;
    }


    // Keep the feed bounded during rapid state changes.

    if (array_length(_active) >= _system.maximum_visible)
        array_delete(_active, 0, 1);


    var _start_y =
        _system.start_y
        + (array_length(_active) * _system.spacing);


    array_push(
        _active,
        {
            key: _key,

            title: _title,
            message: _message,
            color: _color,

            remaining:
                max(0.5, _duration_seconds),

            x: _system.start_x,
            y: _start_y,
            alpha: 0,

            removing: false
        }
    );


    return true;
}


/// @description Updates side-HUD notification animation and lifetime.

function scr_hud_notification_update(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _system = _hud.hud.notifications;
    var _active = _system.active;

    var _delta =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    for (var i = array_length(_active) - 1; i >= 0; --i)
    {
        var _notification = _active[i];

        var _target_y =
            _system.start_y
            + (i * _system.spacing);


        _notification.y =
            lerp(
                _notification.y,
                _target_y,
                _system.vertical_speed
            );


        if (!_notification.removing)
        {
            _notification.x =
                lerp(
                    _notification.x,
                    _system.target_x,
                    _system.opening_speed
                );

            _notification.alpha =
                lerp(
                    _notification.alpha,
                    1,
                    _system.opening_speed
                );

            _notification.remaining =
                max(
                    0,
                    _notification.remaining - _delta
                );


            if (_notification.remaining <= 0)
                _notification.removing = true;
        }
        else
        {
            _notification.x =
                lerp(
                    _notification.x,
                    _system.start_x,
                    _system.closing_speed
                );

            _notification.alpha =
                lerp(
                    _notification.alpha,
                    0,
                    _system.closing_speed
                );


            if (_notification.alpha <= 0.01)
                array_delete(_active, i, 1);
        }
    }


    return true;
}


/// @description Draws the stacked top-left notification feed.

function scr_hud_notification_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _system = _hud.hud.notifications;
    var _active = _system.active;

    if (array_length(_active) <= 0)
        return true;


    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);


    for (var i = 0; i < array_length(_active); ++i)
    {
        var _notification = _active[i];

        var _left = _notification.x;
        var _right = _left + _system.width;

        var _top =
            _notification.y
            - (_system.height * 0.5);

        var _bottom =
            _notification.y
            + (_system.height * 0.5);


        // Dark backing panel.

        draw_set_alpha(
            _notification.alpha
            * _system.background_alpha
        );

        draw_set_color(c_black);

        draw_rectangle(
            _left,
            _top,
            _right,
            _bottom,
            false
        );


        // Vector accent and angled right edge.

        draw_set_alpha(_notification.alpha);
        draw_set_color(_notification.color);

        draw_line_width(
            _left,
            _top,
            _left,
            _bottom,
            3
        );

        draw_line(
            _left,
            _top,
            _right - 12,
            _top
        );

        draw_line(
            _right - 12,
            _top,
            _right,
            _notification.y
        );

        draw_line(
            _right,
            _notification.y,
            _right - 12,
            _bottom
        );


        // Notification text.

        draw_set_color(_notification.color);

        draw_text(
            _left + 14,
            _notification.y - 9,
            string_upper(_notification.title)
        );

        draw_set_color(c_white);

        draw_text(
            _left + 14,
            _notification.y + 9,
            _notification.message
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}