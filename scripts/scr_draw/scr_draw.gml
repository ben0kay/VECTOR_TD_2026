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