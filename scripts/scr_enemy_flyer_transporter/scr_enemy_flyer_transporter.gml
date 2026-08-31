/// @description Draws the hovering Flying Transporter.

function scr_enemy_visual_flying_transporter(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _radius = _enemy.visual.radius;
    var _angle = _enemy.visual.draw_angle;
    var _color = _enemy.visual.color;

    var _hover =
        scr_enemy_visual_hover_offset_get(_enemy);

    var _x = _enemy.x;
    var _y = _enemy.y + _hover;

    var _pulse =
        0.65
        + sin(
            (global.vtd.tick * 2)
            + real(_enemy.id)
        ) * 0.2;


    // ========================================================================
    // GROUND SHADOW
    // ========================================================================

    draw_set_alpha(0.2);
    draw_set_color(c_black);

    draw_ellipse(
        _enemy.x - (_radius * 1.15),
        _enemy.y + 3,
        _enemy.x + (_radius * 1.15),
        _enemy.y + 15,
        false
    );


    // ========================================================================
    // MAIN AIRFRAME
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(_color);

    var _body =
    [
        [ _radius,        0 ],
        [ _radius * 0.45, -_radius * 0.70 ],
        [ -_radius * 0.2, -_radius * 0.95 ],
        [ -_radius * 0.9, -_radius * 0.55 ],
        [ -_radius * 0.75, 0 ],
        [ -_radius * 0.9,  _radius * 0.55 ],
        [ -_radius * 0.2,  _radius * 0.95 ],
        [ _radius * 0.45,  _radius * 0.70 ]
    ];

    scr_enemy_visual_helper_local_polygon(
        _x,
        _y,
        _angle,
        _body,
        2
    );


    // Central structural spine.

    scr_enemy_visual_helper_local_line(
        _x,
        _y,
        _angle,
        -_radius * 0.72,
        0,
        _radius * 0.82,
        0,
        2
    );


    // ========================================================================
    // CARGO PODS
    // ========================================================================

    for (var i = 0; i < 4; ++i)
    {
        var _forward =
            i < 2
            ? _radius * 0.28
            : -_radius * 0.35;

        var _side =
            (i mod 2 == 0)
            ? -_radius * 0.56
            : _radius * 0.56;

        var _pod_x =
            _x
            + lengthdir_x(_forward, _angle)
            + lengthdir_x(_side, _angle + 90);

        var _pod_y =
            _y
            + lengthdir_y(_forward, _angle)
            + lengthdir_y(_side, _angle + 90);

        draw_circle(
            _pod_x,
            _pod_y,
            _radius * 0.16,
            true
        );

        draw_set_alpha(0.35 + (_pulse * 0.25));

        draw_circle(
            _pod_x,
            _pod_y,
            _radius * 0.09,
            false
        );

        draw_set_alpha(1);
    }


    // ========================================================================
    // REAR HOVER ENGINES
    // ========================================================================

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _engine_x =
            _x
            + lengthdir_x(
                _radius * 0.7,
                _angle + 180
            )
            + lengthdir_x(
                _radius * 0.42 * _side,
                _angle + 90
            );

        var _engine_y =
            _y
            + lengthdir_y(
                _radius * 0.7,
                _angle + 180
            )
            + lengthdir_y(
                _radius * 0.42 * _side,
                _angle + 90
            );

        draw_circle(
            _engine_x,
            _engine_y,
            _radius * 0.13,
            true
        );

        draw_set_alpha(_pulse);

        draw_circle(
            _engine_x,
            _engine_y,
            _radius * 0.06,
            false
        );

        draw_set_alpha(1);
    }


    // ========================================================================
    // CARGO CORE
    // ========================================================================

    draw_circle(
        _x,
        _y,
        _radius * 0.28,
        true
    );

    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        _radius * 0.12,
        false
    );


    // ========================================================================
    // ALTITUDE MARKERS
    // ========================================================================

    draw_set_alpha(0.65);

    draw_line(
        _enemy.x - 7,
        _enemy.y + 5,
        _enemy.x - 3,
        _enemy.y + 11
    );

    draw_line(
        _enemy.x + 7,
        _enemy.y + 5,
        _enemy.x + 3,
        _enemy.y + 11
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}