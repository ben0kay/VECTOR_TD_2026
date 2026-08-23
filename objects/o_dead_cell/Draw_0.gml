/// @description Draws one vector-style dead terrain cell.

var _cell_size = global.vtd_level.map.cell_size;
var _half_size = _cell_size * 0.5;

var _left = x - _half_size;
var _top = y - _half_size;
var _right = x + _half_size;
var _bottom = y + _half_size;


draw_set_color(visual.color);

draw_rectangle(
    _left,
    _top,
    _right,
    _bottom,
    true
);


draw_set_color(c_gray);

draw_rectangle(
    _left + visual.inset,
    _top + visual.inset,
    _right - visual.inset,
    _bottom - visual.inset,
    false
);


// Small diagonal lines help neighboring cells resemble connected rock.

draw_line(
    _left + 3,
    _bottom - 6,
    _left + 10,
    _bottom - 3
);

draw_line(
    _right - 10,
    _top + 3,
    _right - 3,
    _top + 7
);


draw_set_color(c_white);