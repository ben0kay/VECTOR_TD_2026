/// @description Draws one primitive vector Fabricator.

function scr_fabricator_draw(_fabricator)
{
    if (!instance_exists(_fabricator))
        return false;


    var _x = _fabricator.x;
    var _y = _fabricator.y;

    var _pulse =
        0.7
        + (
            sin(
                (global.vtd.tick * 4)
                + real(_fabricator.id)
            )
            * 0.2
        );


    draw_set_color(
        _fabricator.visual.color
    );


    // Outer manufacturing frame.

    draw_rectangle(
        _x - 30,
        _y - 30,
        _x + 30,
        _y + 30,
        true
    );

    draw_rectangle(
        _x - 23,
        _y - 23,
        _x + 23,
        _y + 23,
        true
    );


    // Internal assembly rails.

    draw_line_width(
        _x - 20,
        _y,
        _x + 20,
        _y,
        2
    );

    draw_line_width(
        _x,
        _y - 20,
        _x,
        _y + 20,
        2
    );


    draw_set_alpha(_pulse);

    draw_circle(
        _x,
        _y,
        10,
        false
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}