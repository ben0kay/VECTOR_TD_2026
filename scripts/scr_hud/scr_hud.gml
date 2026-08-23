/// @description Level HUD selection and reusable vector-window functions.


/// @description Returns the building underneath a world position.

function scr_hud_building_at_position(_world_x, _world_y)
{
    var _selected = noone;
    var _selected_distance = infinity;
    var _building_count = instance_number(o_building_par);


    // This scan only happens when the player clicks.

    for (var i = 0; i < _building_count; ++i)
    {
        var _building = instance_find(o_building_par, i);

        if (!instance_exists(_building))
            continue;

        if (!variable_instance_exists(_building, "footprint"))
            continue;

        if (!_building.footprint.reserved)
            continue;


        var _cell_size = global.vtd_level.map.cell_size;

        var _left =
            _building.footprint.origin.x
            * _cell_size;

        var _top =
            _building.footprint.origin.y
            * _cell_size;

        var _right =
            _left
            + (_building.footprint.width_cells * _cell_size);

        var _bottom =
            _top
            + (_building.footprint.height_cells * _cell_size);


        if (
            _world_x < _left
            || _world_x > _right
            || _world_y < _top
            || _world_y > _bottom
        )
        {
            continue;
        }


        var _distance = point_distance(
            _world_x,
            _world_y,
            _building.x,
            _building.y
        );


        if (_distance < _selected_distance)
        {
            _selected = _building;
            _selected_distance = _distance;
        }
    }


    return _selected;
}


/// @description Processes level-HUD selection input.

function scr_hud_selection_update(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (global.GameState != GameState.PLAYING)
        return true;

    if (global.LevelState != LevelState.PLAYING)
        return true;


    // Build mode owns the mouse while placing something.

    if (global.BuildState != BuildState.NONE)
        return true;


    if (mouse_check_button_pressed(mb_right))
    {
        _hud.hud.selection.target = noone;
        return true;
    }


    if (mouse_check_button_pressed(mb_left))
    {
        _hud.hud.selection.target =
            scr_hud_building_at_position(
                mouse_x,
                mouse_y
            );
    }


    return true;
}


/// @description Updates the staged vector-window opening animation.

function scr_hud_vector_window_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _window = _hud.hud.window;
    var _opening = instance_exists(_hud.hud.selection.target);


    if (_opening)
    {
        // First grow the central vertical line.

        _window.line_progress = min(
            1,
            _window.line_progress
            + _window.line_speed
        );


        // Then open the panel outward from its centre.

        if (_window.line_progress >= 1)
        {
            _window.panel_progress = min(
                1,
                _window.panel_progress
                + _window.panel_speed
            );
        }
    }
    else
    {
        // Closing reverses the order: panel first, then central line.

        _window.panel_progress = max(
            0,
            _window.panel_progress
            - _window.panel_speed
        );


        if (_window.panel_progress <= 0)
        {
            _window.line_progress = max(
                0,
                _window.line_progress
                - _window.line_speed
            );
        }
    }


    return true;
}


/// @description Returns readable miner activity text.

function scr_hud_miner_status_get(_miner)
{
    if (!instance_exists(_miner))
        return "OFFLINE";

    if (!variable_instance_exists(_miner, "mining"))
        return "UNINITIALIZED";


    var _node = _miner.mining.node;


    if (!instance_exists(_node))
        return "NO RESOURCE NODE";

    if (_node.amount.depleted)
        return "RESOURCE DEPLETED";

    if (_miner.hopper.current >= _miner.hopper.capacity)
        return "HOPPER FULL";

    if (_miner.mining.extracting)
        return "EXTRACTING";

    return "IDLE";
}


/// @description Draws one label and value inside a HUD panel.

function scr_hud_label_value_draw(
    _x,
    _y,
    _label,
    _value,
    _value_color = c_white
)
{
    draw_set_color(c_gray);
    draw_text(_x, _y, _label);

    draw_set_color(_value_color);
    draw_text(_x + 112, _y, string(_value));
}


/// @description Draws information belonging to the selected object.

function scr_hud_selection_content_draw(
    _hud,
    _left,
    _top,
    _right,
    _bottom
)
{
    var _selected = _hud.hud.selection.target;

    if (!instance_exists(_selected))
        return false;


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);


    // ========================================================================
    // GENERIC BUILDING INFORMATION
    // ========================================================================

    draw_set_color(c_aqua);
    draw_text(_left + 18, _top + 14, string_upper(_selected.identity.name));

    draw_set_color(c_dkgray);
    draw_line(_left + 18, _top + 38, _right - 18, _top + 38);


    scr_hud_label_value_draw(
        _left + 18,
        _top + 50,
        "STATUS",
        string(_selected.BuildingState),
        c_lime
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 70,
        "INTEGRITY",
        string(ceil(_selected.vitals.hp.current))
        + " / "
        + string(ceil(_selected.vitals.hp.maximum)),
        c_white
    );


    // ========================================================================
    // MINER INFORMATION
    // ========================================================================

    switch (_selected.object_index)
    {
        case o_miner:
        {
            var _node = _selected.mining.node;
            var _resource_color = c_white;
            var _resource_name = _selected.mining.resource_key;
            var _node_amount = "UNAVAILABLE";


            if (instance_exists(_node))
            {
                _resource_color = _node.visual.color;
                _resource_name = _node.identity.name;

                _node_amount =
                    string(floor(_node.amount.current))
                    + " / "
                    + string(floor(_node.amount.maximum));
            }


            draw_set_color(c_dkgray);
            draw_line(_left + 18, _top + 98, _right - 18, _top + 98);


            scr_hud_label_value_draw(
                _left + 18,
                _top + 110,
                "RESOURCE",
                _resource_name,
                _resource_color
            );


            scr_hud_label_value_draw(
                _left + 18,
                _top + 130,
                "DEPOSIT",
                _node_amount,
                _resource_color
            );


            scr_hud_label_value_draw(
                _left + 18,
                _top + 150,
                "HOPPER",
                string_format(_selected.hopper.current, 0, 1)
                + " / "
                + string_format(_selected.hopper.capacity, 0, 1),
                _resource_color
            );


            var _miner_status =
                scr_hud_miner_status_get(_selected);

            var _status_color = c_white;

            switch (_miner_status)
            {
                case "EXTRACTING":
                    _status_color = c_lime;
                break;

                case "HOPPER FULL":
                    _status_color = c_yellow;
                break;

                case "RESOURCE DEPLETED":
                case "NO RESOURCE NODE":
                    _status_color = c_red;
                break;
            }


            scr_hud_label_value_draw(
                _left + 18,
                _top + 170,
                "OPERATION",
                _miner_status,
                _status_color
            );


            // FUTURE:
            // power-network state
            // assigned cargo drone
            // extraction modifiers
            // overclock state
            // underground noise
        }
        break;


        default:
        {
            draw_set_color(c_gray);

            draw_text(
                _left + 18,
                _top + 116,
                "Additional building information will appear here."
            );
        }
        break;
    }


    return true;
}


/// @description Draws the reusable animated vector information window.

function scr_hud_vector_window_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _window = _hud.hud.window;

    if (_window.line_progress <= 0)
        return true;


    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _center_x =
        _gui_width
        - _window.margin_right
        - (_window.width * 0.5);

    var _center_y =
        _gui_height * 0.5;

    var _half_height =
        (_window.height * 0.5)
        * _window.line_progress;

    var _half_width =
        (_window.width * 0.5)
        * _window.panel_progress;

    var _left = _center_x - _half_width;
    var _right = _center_x + _half_width;
    var _top = _center_y - _half_height;
    var _bottom = _center_y + _half_height;


    // ========================================================================
    // CENTRAL OPENING LINE
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(_window.color);

    draw_line_width(
        _center_x,
        _center_y - _half_height,
        _center_x,
        _center_y + _half_height,
        2
    );


    if (_window.panel_progress <= 0)
        return true;


    // ========================================================================
    // PANEL BODY
    // ========================================================================

    draw_set_alpha(
        _window.background_alpha
        * _window.panel_progress
    );

    draw_set_color(c_black);
    draw_rectangle(_left, _top, _right, _bottom, false);


    draw_set_alpha(1);
    draw_set_color(_window.color);
    draw_rectangle(_left, _top, _right, _bottom, true);


    // Small vector corner accents.

    var _corner = 12;

    draw_line(_left, _top + _corner, _left + _corner, _top);
    draw_line(_right - _corner, _top, _right, _top + _corner);
    draw_line(_left, _bottom - _corner, _left + _corner, _bottom);
    draw_line(_right - _corner, _bottom, _right, _bottom - _corner);


    // Content appears only after the shell has nearly finished opening.

    if (
        _window.panel_progress >= 0.9
        && instance_exists(_hud.hud.selection.target)
    )
    {
        var _content_alpha = clamp(
            (_window.panel_progress - 0.9) / 0.1,
            0,
            1
        );

        draw_set_alpha(_content_alpha);

        scr_hud_selection_content_draw(
            _hud,
            _center_x - (_window.width * 0.5),
            _center_y - (_window.height * 0.5),
            _center_x + (_window.width * 0.5),
            _center_y + (_window.height * 0.5)
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}