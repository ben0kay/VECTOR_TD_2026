/// @description Draws a vector arc using connected line segments.

function scr_draw_arc(
    _x,
    _y,
    _radius,
    _angle_start,
    _angle_end,
    _segments = 16
)
{
    _radius =
        max(0, _radius);

    _segments =
        max(2, floor(_segments));


    var _span =
        _angle_end - _angle_start;

    while (_span <= 0)
        _span += 360;


    var _previous_x =
        _x + lengthdir_x(
            _radius,
            _angle_start
        );

    var _previous_y =
        _y + lengthdir_y(
            _radius,
            _angle_start
        );


    for (var i = 1; i <= _segments; ++i)
    {
        var _angle =
            _angle_start
            + (_span * i / _segments);

        var _next_x =
            _x + lengthdir_x(
                _radius,
                _angle
            );

        var _next_y =
            _y + lengthdir_y(
                _radius,
                _angle
            );


        draw_line(
            _previous_x,
            _previous_y,
            _next_x,
            _next_y
        );


        _previous_x =
            _next_x;

        _previous_y =
            _next_y;
    }


    return true;
}

/// @description Draws one reusable layered vector beam.

function scr_draw_beam(
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _color_outer,
    _color_core,
    _width = 4,
    _alpha = 1,
    _impact_radius = 4
)
{
    _width = max(1, _width);
    _alpha = clamp(_alpha, 0, 1);
    _impact_radius = max(0, _impact_radius);


    // Outer energy layer.

    draw_set_color(_color_outer);
    draw_set_alpha(_alpha * 0.65);

    draw_line_width(
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        _width
    );


    // Bright inner core.

    draw_set_color(_color_core);
    draw_set_alpha(_alpha);

    draw_line_width(
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        max(1, _width * 0.3)
    );


    // Vector impact marker.

    if (_impact_radius > 0)
    {
        draw_circle(
            _end_x,
            _end_y,
            _impact_radius,
            false
        );

        draw_circle(
            _end_x,
            _end_y,
            max(1, _impact_radius * 0.35),
            true
        );
    }


    // FUTURE PARTICLE HOOK:
    // Spawn sparks, repair motes or laser embers along this line.

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}