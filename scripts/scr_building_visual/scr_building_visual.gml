/// @description Draws one generator's temporary vector assembly.

function scr_energy_generator_draw(_building)
{
    var _pulse = 0.75 + sin(global.vtd.tick * 4) * 0.15;

    draw_set_color(c_aqua);
    draw_rectangle(
        _building.x - 22,
        _building.y - 14,
        _building.x + 22,
        _building.y + 14,
        false
    );

    draw_line(_building.x - 22, _building.y, _building.x + 22, _building.y);
    draw_line(_building.x, _building.y - 14, _building.x, _building.y + 14);

    draw_set_alpha(_pulse);
    draw_set_color(c_yellow);
    draw_circle(_building.x, _building.y, 6, true);

    draw_set_alpha(1);
    draw_set_color(c_white);
}


/// @description Draws one local energy node.

function scr_energy_node_draw(_building)
{
    var _pulse = 12 + sin(global.vtd.tick * 5) * 2;

    draw_set_color(c_aqua);
    draw_circle(_building.x, _building.y, _pulse, false);
    draw_circle(_building.x, _building.y, 4, true);

    for (var i = 0; i < 4; ++i)
    {
        var _angle = 45 + (i * 90);

        draw_line(
            _building.x + lengthdir_x(6, _angle),
            _building.y + lengthdir_y(6, _angle),
            _building.x + lengthdir_x(17, _angle),
            _building.y + lengthdir_y(17, _angle)
        );
    }

    draw_set_color(c_white);
}


/// @description Draws one network battery and its stored-energy level.

function scr_energy_battery_draw(_building)
{
    var _battery = _building.energy.battery;

    var _ratio =
        _battery.current
        / max(1, _battery.maximum);

    draw_set_color(c_lime);

    draw_rectangle(
        _building.x - 18,
        _building.y - 24,
        _building.x + 18,
        _building.y + 24,
        true
    );

    draw_rectangle(
        _building.x - 7,
        _building.y - 29,
        _building.x + 7,
        _building.y - 24,
        true
    );

    draw_set_alpha(0.4);
    draw_set_color(c_lime);

    draw_rectangle(
        _building.x - 14,
        _building.y + 20,
        _building.x + 14,
        lerp(_building.y + 20, _building.y - 20, _ratio),
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
}