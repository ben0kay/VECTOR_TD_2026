/// @description Returns readable energy-role text.

function scr_hud_energy_role_text(_role)
{
    switch (_role)
    {
        case EnergyRole.GENERATOR: return "GENERATOR";
        case EnergyRole.NODE:      return "DISTRIBUTION NODE";
        case EnergyRole.BATTERY:   return "NETWORK BATTERY";
        case EnergyRole.CONSUMER:  return "CONSUMER";
    }

    return "NONE";
}

/// @description Draws selected-building energy information in the inspector.

function scr_hud_energy_selection_draw(
    _building,
    _left,
    _top,
    _right,
    _bottom
)
{
    if (!instance_exists(_building))
        return false;

    if (!variable_instance_exists(_building, "energy"))
        return false;

    if (!is_struct(_building.energy))
        return false;

    if (!_building.energy.participates)
        return false;


    // Only draw this expanded section in the permanent tall inspector.
    // The smaller animated world window remains uncluttered.

    if ((_bottom - _top) < 260)
        return true;


    var _energy = _building.energy;
    var _section_top = _bottom - 86;

    var _column_width =
        (_right - _left - 36)
        / 3;

    var _first_x = _left + 18;
    var _second_x = _first_x + _column_width;
    var _third_x = _second_x + _column_width;


    draw_set_color(c_dkgray);

    draw_line(
        _left + 18,
        _section_top,
        _right - 18,
        _section_top
    );


    draw_set_color(c_aqua);

    draw_text(
        _first_x,
        _section_top + 10,
        "ENERGY"
    );


    // ========================================================================
    // CONNECTION
    // ========================================================================

    var _connection_text = "DISCONNECTED";
    var _connection_color = c_red;

    if (_energy.connected)
    {
        _connection_text =
            "GRID "
            + string(_energy.network_id + 1);

        _connection_color =
            _energy.supplied
            ? c_lime
            : c_yellow;
    }


    draw_set_color(c_gray);
    draw_text(_first_x, _section_top + 32, "CONNECTION");

    draw_set_color(_connection_color);
    draw_text(_first_x, _section_top + 50, _connection_text);


    draw_set_color(c_gray);
    draw_text(_second_x, _section_top + 32, "ROLE");

    draw_set_color(c_white);
    draw_text(
        _second_x,
        _section_top + 50,
        scr_hud_energy_role_text(_energy.role)
    );


    // ========================================================================
    // ROLE-SPECIFIC INFORMATION
    // ========================================================================

    switch (_energy.role)
    {
        case EnergyRole.CONSUMER:
        {
            var _buffer_ratio =
                _energy.buffer.current
                / max(1, _energy.buffer.maximum);

            var _buffer_color = c_aqua;

            if (!_energy.connected)
                _buffer_color = c_red;
            else if (_buffer_ratio <= 0.2)
                _buffer_color = make_color_rgb(255, 100, 40);
            else if (_buffer_ratio <= 0.5)
                _buffer_color = c_yellow;


            draw_set_color(c_gray);
            draw_text(_third_x, _section_top + 32, "BUFFER");

            draw_set_color(_buffer_color);
            draw_text(
                _third_x,
                _section_top + 50,
                string_format(_energy.buffer.current, 0, 1)
                + " / "
                + string_format(_energy.buffer.maximum, 0, 1)
            );


            draw_set_color(c_gray);

            draw_text(
                _first_x,
                _section_top + 68,
                "IDLE "
                + string_format(
                    _energy.demand.idle_per_second,
                    0,
                    2
                )
                + "/s"
            );

            draw_text(
                _second_x,
                _section_top + 68,
                "SHOT/USE "
				+ string_format(
				    _energy.demand.activity_cost,
				    0,
				    2
				)
            );

            draw_text(
                _third_x,
                _section_top + 68,
                "INPUT "
                + string_format(
                    _energy.input_rate,
                    0,
                    1
                )
                + "/s"
            );
        }
        break;


        case EnergyRole.GENERATOR:
        {
            draw_set_color(c_gray);
            draw_text(_third_x, _section_top + 32, "OUTPUT");

            draw_set_color(c_lime);
            draw_text(
                _third_x,
                _section_top + 50,
                string_format(
                    _energy.generation_per_second,
                    0,
                    1
                )
                + "/s"
            );

            draw_set_color(c_gray);
            draw_text(
                _first_x,
                _section_top + 68,
                "LINK RANGE "
                + string(round(_energy.connection_range))
            );
        }
        break;


        case EnergyRole.NODE:
        {
            draw_set_color(c_gray);
            draw_text(_third_x, _section_top + 32, "LINK RANGE");

            draw_set_color(c_aqua);
            draw_text(
                _third_x,
                _section_top + 50,
                string(round(_energy.connection_range))
            );

            draw_set_color(c_gray);
            draw_text(
                _first_x,
                _section_top + 68,
                "NETWORK REVISION "
                + string(global.vtd_level.energy.revision)
            );
        }
        break;


        case EnergyRole.BATTERY:
        {
            var _battery_ratio =
                _energy.battery.current
                / max(1, _energy.battery.maximum);

            var _battery_color =
                _battery_ratio > 0.25
                ? c_lime
                : c_yellow;

            if (_battery_ratio <= 0)
                _battery_color = c_red;


            draw_set_color(c_gray);
            draw_text(_third_x, _section_top + 32, "STORED");

            draw_set_color(_battery_color);
            draw_text(
                _third_x,
                _section_top + 50,
                string_format(_energy.battery.current, 0, 1)
                + " / "
                + string_format(_energy.battery.maximum, 0, 1)
            );


            draw_set_color(c_gray);

            draw_text(
                _first_x,
                _section_top + 68,
                "CHARGE "
                + string_format(
                    _energy.battery.charge_rate,
                    0,
                    1
                )
                + "/s"
            );

            draw_text(
                _second_x,
                _section_top + 68,
                "DISCHARGE "
                + string_format(
                    _energy.battery.discharge_rate,
                    0,
                    1
                )
                + "/s"
            );

            draw_text(
                _third_x,
                _section_top + 68,
                string(round(_battery_ratio * 100))
                + "%"
            );
        }
        break;
    }


    draw_set_color(c_white);

    return true;
}

/// @description Creates reusable energy-priority controls.

function scr_hud_energy_controls_create()
{
    var _critical =
        scr_hud_button_create(
            "energy_critical",
            "CRITICAL",
            "FIRST"
        );

    _critical.data = EnergyPriority.CRITICAL;
    _critical.accent_color = c_red;


    var _high =
        scr_hud_button_create(
            "energy_high",
            "HIGH",
            "SECOND"
        );

    _high.data = EnergyPriority.HIGH;
    _high.accent_color = make_color_rgb(255, 150, 40);


    var _normal =
        scr_hud_button_create(
            "energy_normal",
            "NORMAL",
            "THIRD"
        );

    _normal.data = EnergyPriority.NORMAL;
    _normal.accent_color = c_aqua;


    var _low =
        scr_hud_button_create(
            "energy_low",
            "LOW",
            "LAST"
        );

    _low.data = EnergyPriority.LOW;
    _low.accent_color = c_gray;


    return
    {
        buttons:
        [
            _critical,
            _high,
            _normal,
            _low
        ]
    };
}


/// @description Updates energy-priority buttons for the selected consumer.

function scr_hud_energy_controls_update(
    _hud,
    _selected,
    _inspector_left,
    _tray_top
)
{
    if (!instance_exists(_selected))
        return false;


    var _controls =
        _hud.hud.selection_panel.energy_controls;

    var _is_consumer =
        variable_instance_exists(_selected, "energy")
        && is_struct(_selected.energy)
        && _selected.energy.participates
        && _selected.energy.role == EnergyRole.CONSUMER;


    var _button_x =
        _inspector_left - 190;

    var _button_y =
        _tray_top + 40;

    var _button_width = 174;
    var _button_height = 34;
    var _button_gap = 5;


    for (var i = 0; i < array_length(_controls.buttons); ++i)
    {
        var _button =
            _controls.buttons[i];

        scr_hud_button_bounds_set(
            _button,
            _button_x,
            _button_y
                + (i * (_button_height + _button_gap)),
            _button_width,
            _button_height
        );


        _button.enabled =
            _is_consumer;

        _button.selected =
            _is_consumer
            && _selected.energy.priority
                == _button.data;


        if (
            _is_consumer
            && scr_hud_button_update(_button)
        )
        {
            _selected.energy.priority =
                _button.data;

            show_debug_message(
                "ENERGY PRIORITY CHANGED: "
                + _selected.identity.name
                + " | "
                + scr_hud_energy_priority_text(
                    _selected.energy.priority
                )
            );
        }
    }


    return true;
}


/// @description Draws energy-priority controls.

function scr_hud_energy_controls_draw(
    _hud,
    _selected,
    _inspector_left,
    _tray_top
)
{
    if (!instance_exists(_selected))
        return false;


    var _is_consumer =
        variable_instance_exists(_selected, "energy")
        && is_struct(_selected.energy)
        && _selected.energy.participates
        && _selected.energy.role == EnergyRole.CONSUMER;


    draw_set_color(c_aqua);

    draw_text(
        _inspector_left - 190,
        _tray_top + 12,
        "ENERGY PRIORITY"
    );


    if (!_is_consumer)
    {
        draw_set_color(c_gray);

        draw_text_ext(
            _inspector_left - 190,
            _tray_top + 44,
            "THIS STRUCTURE DOES NOT USE CONSUMER PRIORITY.",
            18,
            174
        );

        return true;
    }


    var _buttons =
        _hud.hud.selection_panel
            .energy_controls.buttons;


    for (var i = 0; i < array_length(_buttons); ++i)
        scr_hud_button_draw(_buttons[i]);


    return true;
}