/// @description Reusable primitive helpers for enemy vector visuals.


// ============================================================================
// LINE
// ============================================================================

/// @description Draws one vector line with width.

function scr_enemy_visual_helper_line(
    _x1,
    _y1,
    _x2,
    _y2,
    _width = 1
)
{
    draw_line_width(
        _x1,
        _y1,
        _x2,
        _y2,
        _width
    );

    return true;
}


// ============================================================================
// TRIANGLE
// ============================================================================

/// @description Draws one outlined triangle from three world-space points.

function scr_enemy_visual_helper_triangle(
    _x1,
    _y1,
    _x2,
    _y2,
    _x3,
    _y3,
    _width = 1
)
{
    draw_line_width(
        _x1,
        _y1,
        _x2,
        _y2,
        _width
    );

    draw_line_width(
        _x2,
        _y2,
        _x3,
        _y3,
        _width
    );

    draw_line_width(
        _x3,
        _y3,
        _x1,
        _y1,
        _width
    );

    return true;
}


// ============================================================================
// TRIANGULAR BLADE
// ============================================================================

/// @description Draws one long triangular blade pointing away from a center.

function scr_enemy_visual_helper_triangle_blade(
    _x,
    _y,
    _angle,
    _tip_length,
    _base_distance,
    _base_spread,
    _width = 1
)
{
    var _tip_x =
        _x
        + lengthdir_x(
            _tip_length,
            _angle
        );

    var _tip_y =
        _y
        + lengthdir_y(
            _tip_length,
            _angle
        );


    var _base_a_x =
        _x
        + lengthdir_x(
            _base_distance,
            _angle + 180 - _base_spread
        );

    var _base_a_y =
        _y
        + lengthdir_y(
            _base_distance,
            _angle + 180 - _base_spread
        );


    var _base_b_x =
        _x
        + lengthdir_x(
            _base_distance,
            _angle + 180 + _base_spread
        );

    var _base_b_y =
        _y
        + lengthdir_y(
            _base_distance,
            _angle + 180 + _base_spread
        );


    return scr_enemy_visual_helper_triangle(
        _tip_x,
        _tip_y,
        _base_a_x,
        _base_a_y,
        _base_b_x,
        _base_b_y,
        _width
    );
}


// ============================================================================
// REGULAR POLYGON
// ============================================================================

/// @description Draws an outlined regular polygon.

function scr_enemy_visual_helper_polygon(
    _x,
    _y,
    _radius,
    _sides,
    _angle = 0,
    _width = 1
)
{
    if (_sides < 3)
        return false;


    var _step =
        360 / _sides;


    for (var i = 0; i < _sides; ++i)
    {
        var _a1 =
            _angle
            + (i * _step);

        var _a2 =
            _angle
            + (((i + 1) mod _sides) * _step);


        draw_line_width(
            _x + lengthdir_x(_radius, _a1),
            _y + lengthdir_y(_radius, _a1),

            _x + lengthdir_x(_radius, _a2),
            _y + lengthdir_y(_radius, _a2),

            _width
        );
    }


    return true;
}


// ============================================================================
// SQUARE
// ============================================================================

/// @description Draws one rotated outlined square.

function scr_enemy_visual_helper_square(
    _x,
    _y,
    _radius,
    _angle = 0,
    _width = 1
)
{
    return scr_enemy_visual_helper_polygon(
        _x,
        _y,
        _radius,
        4,
        _angle + 45,
        _width
    );
}


// ============================================================================
// DIAMOND
// ============================================================================

/// @description Draws one outlined diamond.

function scr_enemy_visual_helper_diamond(
    _x,
    _y,
    _radius,
    _angle = 0,
    _width = 1
)
{
    return scr_enemy_visual_helper_polygon(
        _x,
        _y,
        _radius,
        4,
        _angle,
        _width
    );
}


// ============================================================================
// RING
// ============================================================================

/// @description Draws one vector ring.

function scr_enemy_visual_helper_ring(
    _x,
    _y,
    _radius
)
{
    draw_circle(
        _x,
        _y,
        _radius,
        true
    );

    return true;
}


// ============================================================================
// DOUBLE RING
// ============================================================================

/// @description Draws two concentric vector rings.

function scr_enemy_visual_helper_double_ring(
    _x,
    _y,
    _outer_radius,
    _inner_radius
)
{
    draw_circle(
        _x,
        _y,
        _outer_radius,
        true
    );

    draw_circle(
        _x,
        _y,
        _inner_radius,
        true
    );

    return true;
}


// ============================================================================
// SPOKES
// ============================================================================

/// @description Draws equally spaced radial spokes.

function scr_enemy_visual_helper_spokes(
    _x,
    _y,
    _inner_radius,
    _outer_radius,
    _count,
    _angle = 0,
    _width = 1
)
{
    if (_count <= 0)
        return false;


    var _step =
        360 / _count;


    for (var i = 0; i < _count; ++i)
    {
        var _a =
            _angle
            + (i * _step);


        draw_line_width(
            _x + lengthdir_x(_inner_radius, _a),
            _y + lengthdir_y(_inner_radius, _a),

            _x + lengthdir_x(_outer_radius, _a),
            _y + lengthdir_y(_outer_radius, _a),

            _width
        );
    }


    return true;
}


// ============================================================================
// ARC
// ============================================================================

/// @description Draws one outlined arc using line segments.

function scr_enemy_visual_helper_arc(
    _x,
    _y,
    _radius,
    _angle_start,
    _angle_end,
    _segments = 12,
    _width = 1
)
{
    if (_segments <= 0)
        return false;


    var _difference =
        _angle_end
        - _angle_start;


    var _previous_x =
        _x
        + lengthdir_x(
            _radius,
            _angle_start
        );

    var _previous_y =
        _y
        + lengthdir_y(
            _radius,
            _angle_start
        );


    for (var i = 1; i <= _segments; ++i)
    {
        var _ratio =
            i / _segments;

        var _angle =
            _angle_start
            + (_difference * _ratio);


        var _current_x =
            _x
            + lengthdir_x(
                _radius,
                _angle
            );

        var _current_y =
            _y
            + lengthdir_y(
                _radius,
                _angle
            );


        draw_line_width(
            _previous_x,
            _previous_y,
            _current_x,
            _current_y,
            _width
        );


        _previous_x =
            _current_x;

        _previous_y =
            _current_y;
    }


    return true;
}


// ============================================================================
// ARC SEGMENTS
// ============================================================================

/// @description Draws evenly spaced broken arc segments around a circle.

function scr_enemy_visual_helper_arc_segments(
    _x,
    _y,
    _radius,
    _count,
    _segment_degrees,
    _angle = 0,
    _segments_per_arc = 5,
    _width = 1
)
{
    if (_count <= 0)
        return false;


    var _step =
        360 / _count;


    for (var i = 0; i < _count; ++i)
    {
        var _center_angle =
            _angle
            + (i * _step);

        var _half =
            _segment_degrees * 0.5;


        scr_enemy_visual_helper_arc(
            _x,
            _y,
            _radius,
            _center_angle - _half,
            _center_angle + _half,
            _segments_per_arc,
            _width
        );
    }


    return true;
}


// ============================================================================
// RADIAL DOTS
// ============================================================================

/// @description Draws equally spaced dots around a center.

function scr_enemy_visual_helper_radial_dots(
    _x,
    _y,
    _distance,
    _dot_radius,
    _count,
    _angle = 0,
    _filled = true
)
{
    if (_count <= 0)
        return false;


    var _step =
        360 / _count;


    for (var i = 0; i < _count; ++i)
    {
        var _a =
            _angle
            + (i * _step);


        draw_circle(
            _x + lengthdir_x(_distance, _a),
            _y + lengthdir_y(_distance, _a),
            _dot_radius,
            !_filled
        );
    }


    return true;
}


// ============================================================================
// TRIANGLE RING
// ============================================================================

/// @description Draws multiple triangular blades around one center.

function scr_enemy_visual_helper_triangle_ring(
    _x,
    _y,
    _angle,
    _count,
    _tip_length,
    _base_distance,
    _base_spread,
    _width = 1
)
{
    if (_count <= 0)
        return false;


    var _step =
        360 / _count;


    for (var i = 0; i < _count; ++i)
    {
        scr_enemy_visual_helper_triangle_blade(
            _x,
            _y,
            _angle + (i * _step),
            _tip_length,
            _base_distance,
            _base_spread,
            _width
        );
    }


    return true;
}

// ============================================================================
// LOCAL-SPACE LINE
// ============================================================================

/// @description Draws a line between two local-space points, rotated around a world-space center.

function scr_enemy_visual_helper_local_line(
    _x,
    _y,
    _angle,
    _x1,
    _y1,
    _x2,
    _y2,
    _width = 1
)
{
    var _cos = dcos(_angle);
    var _sin = dsin(_angle);


    // GameMaker direction convention:
    // +X local = forward
    // +Y local = right side of the craft

    var _world_x1 =
        _x
        + (_x1 * _cos)
        + (_y1 * _sin);

    var _world_y1 =
        _y
        - (_x1 * _sin)
        + (_y1 * _cos);


    var _world_x2 =
        _x
        + (_x2 * _cos)
        + (_y2 * _sin);

    var _world_y2 =
        _y
        - (_x2 * _sin)
        + (_y2 * _cos);


    draw_line_width(
        _world_x1,
        _world_y1,
        _world_x2,
        _world_y2,
        _width
    );


    return true;
}

// ============================================================================
// LOCAL-SPACE POLYGON
// ============================================================================

/// @description Draws a closed polygon from local-space [x,y] points.

function scr_enemy_visual_helper_local_polygon(
    _x,
    _y,
    _angle,
    _points,
    _width = 1
)
{
    var _count =
        array_length(_points);

    if (_count < 3)
        return false;


    var _cos =
        dcos(_angle);

    var _sin =
        dsin(_angle);


    for (var i = 0; i < _count; ++i)
    {
        var _next =
            (i + 1) mod _count;


        var _p1 =
            _points[i];

        var _p2 =
            _points[_next];


        var _x1 =
            _x
            + (_p1[0] * _cos)
            + (_p1[1] * _sin);

        var _y1 =
            _y
            - (_p1[0] * _sin)
            + (_p1[1] * _cos);


        var _x2 =
            _x
            + (_p2[0] * _cos)
            + (_p2[1] * _sin);

        var _y2 =
            _y
            - (_p2[0] * _sin)
            + (_p2[1] * _cos);


        draw_line_width(
            _x1,
            _y1,
            _x2,
            _y2,
            _width
        );
    }


    return true;
}

// ============================================================================
// LOCAL-SPACE BOX
// ============================================================================

/// @description Draws a rotated outlined rectangle using local-space coordinates.

function scr_enemy_visual_helper_local_box(
    _x,
    _y,
    _angle,
    _x1,
    _y1,
    _x2,
    _y2,
    _width = 1
)
{
    var _points =
    [
        [_x1, _y1],
        [_x2, _y1],
        [_x2, _y2],
        [_x1, _y2]
    ];


    return scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _points,
        _width
    );
}

// ============================================================================
// RADIAL TICKS
// ============================================================================

/// @description Draws short evenly spaced radial tick marks around a center.

function scr_enemy_visual_helper_radial_ticks(
    _x,
    _y,
    _radius,
    _tick_length,
    _count,
    _angle = 0,
    _width = 1
)
{
    if (_count <= 0)
        return false;


    var _step =
        360 / _count;


    for (var i = 0; i < _count; ++i)
    {
        var _a =
            _angle
            + (i * _step);


        draw_line_width(
            _x + lengthdir_x(
                _radius,
                _a
            ),

            _y + lengthdir_y(
                _radius,
                _a
            ),

            _x + lengthdir_x(
                _radius + _tick_length,
                _a
            ),

            _y + lengthdir_y(
                _radius + _tick_length,
                _a
            ),

            _width
        );
    }


    return true;
}