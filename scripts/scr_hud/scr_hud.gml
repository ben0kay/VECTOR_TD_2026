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


/// @description Processes level-HUD world selection input.

function scr_hud_selection_update(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (global.GameState != GameState.PLAYING)
        return true;

    if (global.LevelState != LevelState.PLAYING)
        return true;

    if (global.BuildState != BuildState.NONE)
        return true;

    if (_hud.hud.build_menu.open)
        return true;

    if (scr_hud_pointer_blocks_world())
        return true;


    if (mouse_check_button_pressed(mb_right))
    {
        _hud.hud.selection.target =
            noone;

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


    draw_set_color(c_aqua);

    draw_text(
        _left + 18,
        _top + 14,
        string_upper(_selected.identity.name)
    );


    draw_set_color(c_dkgray);

    draw_line(
        _left + 18,
        _top + 38,
        _right - 18,
        _top + 38
    );


    var _building_status =
        scr_hud_building_status_get(_selected);

    var _building_status_color = c_lime;


    if (_selected.BuildingState == BuildingState.DISABLED)
        _building_status_color = c_yellow;

    if (_selected.BuildingState == BuildingState.DESTROYED)
        _building_status_color = c_red;


    scr_hud_label_value_draw(
        _left + 18,
        _top + 50,
        "STATUS",
        _building_status,
        _building_status_color
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

            draw_line(
                _left + 18,
                _top + 98,
                _right - 18,
                _top + 98
            );


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

            var _miner_status_color = c_white;


            switch (_miner_status)
            {
                case "EXTRACTING":
                    _miner_status_color = c_lime;
                break;

                case "HOPPER FULL":
                    _miner_status_color = c_yellow;
                break;

                case "RESOURCE DEPLETED":
                case "NO RESOURCE NODE":
                    _miner_status_color = c_red;
                break;
            }


            scr_hud_label_value_draw(
                _left + 18,
                _top + 170,
                "OPERATION",
                _miner_status,
                _miner_status_color
            );


            var _drone_text = "NONE";

            if (instance_exists(_selected.logistics.assigned_drone))
                _drone_text = "ASSIGNED";


            scr_hud_label_value_draw(
                _left + 18,
                _top + 190,
                "CARGO DRONE",
                _drone_text,
                c_aqua
            );


            // FUTURE:
            // power state
            // overclocking
            // extraction upgrades
            // underground noise
        }
        break;


        case o_storage:
        {
            draw_set_color(c_dkgray);
            draw_line(_left + 18, _top + 98, _right - 18, _top + 98);

            var _compartments = _selected.storage.compartments;
            for (var i = 0; i < array_length(_compartments); ++i)
            {
                var _compartment = _compartments[i];
                var _resource_data = scr_resource_data_get(_compartment.resource_key);
                var _resource_name = scr_resource_data_valid(_resource_data)
                    ? _resource_data.identity.name
                    : _compartment.resource_key;
                var _resource_color = scr_resource_data_valid(_resource_data)
                    ? _resource_data.visual.color
                    : c_white;

                scr_hud_label_value_draw(
                    _left + 18,
                    _top + 110 + (i * 40),
                    string_upper(_resource_name),
                    string_format(_compartment.current, 0, 1)
                    + " / " + string_format(_compartment.capacity, 0, 1),
                    _resource_color
                );

                scr_hud_label_value_draw(
                    _left + 18,
                    _top + 130 + (i * 40),
                    "IN / OUT RESERVED",
                    string_format(_compartment.incoming_reserved, 0, 1)
                    + " / " + string_format(_compartment.outgoing_reserved, 0, 1),
                    c_aqua
                );
            }
        }
        break;
		
	case o_tower:
		{
    scr_hud_tower_selection_draw(_selected, _left, _top, _right);
		}
		break;


        case o_refinery:
        {
            scr_hud_refinery_inspector_draw(_selected, _left, _top);
        }
        break;
		
		case o_fabricator:
		{
		    scr_hud_fabricator_inspector_draw(
		        _selected,
		        _left,
		        _top
		    );
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

	scr_hud_energy_selection_draw(
    _selected,
    _left,
    _top,
    _right,
    _bottom
);

    return true;
}


/// @description Draws an animated vector window beside the selected object.

function scr_hud_vector_window_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _window = _hud.hud.window;
    var _selected = _hud.hud.selection.target;

    if (_window.line_progress <= 0)
        return true;


    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
	
	var _usable_bottom =
    _gui_height
    - _hud.hud.bottom.height;

    var _anchor_x = _gui_width * 0.5;
    var _anchor_y = _gui_height * 0.5;


    // ========================================================================
    // WORLD POSITION TO GUI POSITION
    // ========================================================================

    if (instance_exists(_selected))
    {
        var _camera = global.vtd_level.entities.camera;

        if (instance_exists(_camera))
        {
            var _camera_id = _camera.camera_runtime.id;

            var _view_x = camera_get_view_x(_camera_id);
            var _view_y = camera_get_view_y(_camera_id);
            var _view_width = camera_get_view_width(_camera_id);
            var _view_height = camera_get_view_height(_camera_id);


            _anchor_x =
                (_selected.x - _view_x)
                * (_gui_width / _view_width);

            _anchor_y =
                (_selected.y - _view_y)
                * (_gui_height / _view_height);
        }
    }


    // ========================================================================
    // WINDOW POSITION
    // ========================================================================

    var _screen_margin = 16;
    var _object_gap = 48;

    var _full_half_width = _window.width * 0.5;
    var _full_half_height = _window.height * 0.5;


    // Prefer the right side of the selected object.

    var _room_on_right =
        _anchor_x
        + _object_gap
        + _window.width
        <= _gui_width - _screen_margin;

    var _center_x;


    if (_room_on_right)
    {
        _center_x =
            _anchor_x
            + _object_gap
            + _full_half_width;
    }
    else
    {
        _center_x =
            _anchor_x
            - _object_gap
            - _full_half_width;
    }


    var _center_y = clamp(
    _anchor_y,
    _hud.hud.top.height
        + _screen_margin
        + _full_half_height,

    _usable_bottom
        - _screen_margin
        - _full_half_height
);


    _center_x = clamp(
        _center_x,
        _screen_margin + _full_half_width,
        _gui_width - _screen_margin - _full_half_width
    );


    // ========================================================================
    // ANIMATED BOUNDS
    // ========================================================================

    var _half_height =
        _full_half_height
        * _window.line_progress;

    var _half_width =
        _full_half_width
        * _window.panel_progress;

    var _left = _center_x - _half_width;
    var _right = _center_x + _half_width;
    var _top = _center_y - _half_height;
    var _bottom = _center_y + _half_height;


    // ========================================================================
    // OBJECT CONNECTION LINE
    // ========================================================================

    if (
        instance_exists(_selected)
        && _window.panel_progress > 0
    )
    {
        var _connection_x;


        if (_room_on_right)
            _connection_x = _left;
        else
            _connection_x = _right;


        draw_set_alpha(_window.panel_progress);
        draw_set_color(_window.color);

        draw_line(
            _anchor_x,
            _anchor_y,
            _connection_x,
            _center_y
        );


        // Small selection point.

        draw_circle(
            _anchor_x,
            _anchor_y,
            3,
            false
        );
    }


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


    // Vector corner accents.

    var _corner = 12;

    draw_line(_left, _top + _corner, _left + _corner, _top);
    draw_line(_right - _corner, _top, _right, _top + _corner);

    draw_line(
        _left,
        _bottom - _corner,
        _left + _corner,
        _bottom
    );

    draw_line(
        _right - _corner,
        _bottom,
        _right,
        _bottom - _corner
    );


    // ========================================================================
    // CONTENT
    // ========================================================================

    if (
        _window.panel_progress >= 0.9
        && instance_exists(_selected)
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
            _center_x - _full_half_width,
            _center_y - _full_half_height,
            _center_x + _full_half_width,
            _center_y + _full_half_height
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}

/// @description Returns readable building-state text.

function scr_hud_building_status_get(_building)
{
    if (!instance_exists(_building))
        return "OFFLINE";


    switch (_building.BuildingState)
    {
        case BuildingState.CONSTRUCTING:
            return "CONSTRUCTING";

        case BuildingState.ACTIVE:
            return "ACTIVE";

        case BuildingState.DISABLED:
            return "DISABLED";

        case BuildingState.DESTROYED:
            return "DESTROYED";
    }


    return "UNKNOWN";
}


/// @description Returns readable storage activity text.

function scr_hud_storage_status_get(_storage)
{
    if (!instance_exists(_storage))
        return "OFFLINE";

    if (!variable_instance_exists(_storage, "storage"))
        return "UNINITIALIZED";

    var _totals = scr_storage_totals_get(_storage);

    if (_totals.current >= _totals.capacity)
        return "FULL";

    if (_totals.incoming > 0 || _totals.outgoing > 0)
        return "DELIVERY INCOMING";

    if (_totals.current > 0)
        return "AVAILABLE";

    return "EMPTY";
}

/// @description Draws the expanded two-row level information bar.

function scr_hud_top_bar_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _gui_width =
        display_get_gui_width();

    var _height =
        _hud.hud.top.height;

    var _row_height =
        _hud.hud.top.row_height;



    // ========================================================================
    // RIGHT-HAND STATUS CELLS
    // ========================================================================

    var _time_width =
    130;

	var _cpu_width =
	    180;

	var _player_width =
	    180;

	var _right_width =
	    _player_width
	    + _cpu_width
	    + _time_width;

    var _right_x =
        _gui_width
        - _right_width;


    // ========================================================================
    // FIRST ROW — RESOURCES
    // ========================================================================

    var _draw_x =
        0;


    _draw_x =
        scr_hud_top_cell_draw(
            _draw_x,
            170,
            _row_height,
            "Credits",

            string(
                floor(
                    scr_resource_amount_get(
                        "resource_credits"
                    )
                )
            ),

            c_aqua,
            0
        );


    // Aggregate energy information. These totals summarize every independent
    // network and do not create a shared global energy pool.

    var _energy_totals =
        global.vtd_level.energy.totals;

    var _energy_color =
        _energy_totals.deficient_networks > 0
        ? c_red
        : c_lime;

    var _energy_text =
        string_format(
            _energy_totals.generation,
            0,
            1
        )
        + " IN | "
        + string_format(
            _energy_totals.demand,
            0,
            1
        )
        + " OUT";


    _draw_x =
        scr_hud_top_cell_draw(
            _draw_x,
            220,
            _row_height,
            "Energy",
            _energy_text,
            _energy_color,
            0
        );


    // ========================================================================
    // DATA-DRIVEN RAW RESOURCES
    // ========================================================================

    var _resource_width =
        240;

    var _hidden_resources =
        0;

    var _resource_keys =
        variable_struct_get_names(
            global.vtd.data.resources
        );


    for (
        var i = 0;
        i < array_length(_resource_keys);
        ++i
    )
    {
        var _resource_data =
            scr_resource_data_get(
                _resource_keys[i]
            );


        if (!scr_resource_data_valid(_resource_data))
            continue;

        if (
            _resource_data.identity.type != ResourceType.RAW_MATERIAL
        )
        {
            continue;
        }


        if (
            _draw_x + _resource_width
            > _right_x
        )
        {
            _hidden_resources++;
            continue;
        }


        var _entry =
            scr_resource_level_entry_get(
                _resource_data.identity.key
            );

        var _value =
            "0 / 0";


        if (is_struct(_entry))
        {
            _value =
                string(
                    floor(_entry.current)
                )
                + " / "
                + string(
                    floor(_entry.capacity)
                );

            if (variable_struct_exists(_resource_data.identity, "refined_key"))
            {
                var _refined_entry = scr_resource_level_entry_get(_resource_data.identity.refined_key);
                if (is_struct(_refined_entry))
                {
                    _value += " | R "
                        + string(floor(_refined_entry.current))
                        + "/"
                        + string(floor(_refined_entry.capacity));
                }
            }
        }


        _draw_x =
            scr_hud_top_cell_draw(
                _draw_x,
                _resource_width,
                _row_height,
                _resource_data.identity.name + " R/F",
                _value,
                _resource_data.visual.color,
                0
            );
    }


    if (
        _hidden_resources > 0
        && _draw_x + 72 <= _right_x
    )
    {
        scr_hud_top_cell_draw(
            _draw_x,
            72,
            _row_height,
            "More",
            "+" + string(_hidden_resources),
            c_gray,
            0
        );
    }


    // ========================================================================
// PLAYER HEALTH — FIRST ROW, RIGHT
// ========================================================================

var _player_text =
    "OFFLINE";

var _player_color =
    c_red;

var _player =
    global.vtd_level.entities.player;


if (instance_exists(_player))
{
    _player_text =
        string(
            ceil(_player.vitals.hp.current)
        )
        + " / "
        + string(
            ceil(_player.vitals.hp.maximum)
        );


    var _player_hp_ratio =
        _player.vitals.hp.current
        / max(
            1,
            _player.vitals.hp.maximum
        );


    _player_color =
        _player_hp_ratio > 0.5
        ? c_aqua
        : (
            _player_hp_ratio > 0.25
            ? c_yellow
            : c_red
        );
}


var _right_cell_x =
    _right_x;


_right_cell_x =
    scr_hud_top_cell_draw(
        _right_cell_x,
        _player_width,
        _row_height,
        "Player Integrity",
        _player_text,
        _player_color,
        0
    );


	// ========================================================================
	// CPU HEALTH — BESIDE PLAYER HEALTH
	// ========================================================================

	var _cpu_text =
	    "OFFLINE";

	var _cpu_color =
	    c_red;

	var _cpu =
	    global.vtd_level.entities.cpu;


	if (instance_exists(_cpu))
	{
	    _cpu_text =
	        string(
	            ceil(_cpu.vitals.hp.current)
	        )
	        + " / "
	        + string(
	            ceil(_cpu.vitals.hp.maximum)
	        );


	    var _cpu_hp_ratio =
	        _cpu.vitals.hp.current
	        / max(
	            1,
	            _cpu.vitals.hp.maximum
	        );


	    _cpu_color =
	        _cpu_hp_ratio > 0.5
	        ? c_lime
	        : (
	            _cpu_hp_ratio > 0.25
	            ? c_yellow
	            : c_red
	        );
	}


	_right_cell_x =
	    scr_hud_top_cell_draw(
	        _right_cell_x,
	        _cpu_width,
	        _row_height,
	        "CPU Integrity",
	        _cpu_text,
	        _cpu_color,
	        0
	    );


    // ========================================================================
    // ELAPSED TIME — FIRST ROW, FAR RIGHT
    // ========================================================================

    var _seconds =
        floor(
            global.vtd_level.time.seconds
        );

    var _minutes =
        floor(
            _seconds / 60
        );

    var _remaining_seconds =
        _seconds mod 60;

    var _time_text =
        string(_minutes)
        + ":"
        + (
            _remaining_seconds < 10
            ? "0"
            : ""
        )
        + string(_remaining_seconds);


    scr_hud_top_cell_draw(
        _right_cell_x,
        _time_width,
        _row_height,
        "Elapsed",
        _time_text,
        c_aqua,
        0
    );


    // ========================================================================
    // SECOND ROW — BUILD CAPACITY
    // ========================================================================

    var _limit_x =
        0;

    var _limit_width =
        180;

    var _limit_types =
    [
        BuildLimitType.TOWER,
        BuildLimitType.DEFENSE,
        BuildLimitType.ECONOMY,
        BuildLimitType.INFRASTRUCTURE,
		BuildLimitType.FOUNDATION
    ];

    var _limit_colors =
    [
        c_yellow,
        c_fuchsia,
        make_color_rgb(90, 210, 120),
        c_aqua,
		make_color_rgb(100, 150, 190)
    ];


    for (
        var i = 0;
        i < array_length(_limit_types);
        ++i
    )
    {
        var _limit_type =
            _limit_types[i];

        var _limit_entry =
            scr_build_limit_entry_get(
                _limit_type
            );

        var _limit_text =
            "0 / 0";

        var _limit_color =
            _limit_colors[i];


        if (is_struct(_limit_entry))
        {
            _limit_text =
                string(_limit_entry.used)
                + " / "
                + string(_limit_entry.maximum);


            if (
                _limit_entry.used
                > _limit_entry.maximum
            )
            {
                _limit_color =
                    c_red;
            }
        }


        _limit_x =
            scr_hud_top_cell_draw(
                _limit_x,
                _limit_width,
                _row_height,
                scr_build_limit_name(
                    _limit_type
                ),
                _limit_text,
                _limit_color,
                _row_height
            );
    }


    // ========================================================================
    // ENEMIES — SECOND ROW, BENEATH ELAPSED
    // ========================================================================

    scr_hud_top_cell_draw(
        _gui_width - _time_width,
        _time_width,
        _row_height,
        "Enemies",
        string(instance_number(o_enemy)),
        c_red,
        _row_height
    );


    draw_set_alpha(
        1
    );

    draw_set_color(
        c_white
    );

    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_top
    );


    return true;
}


/// @description Draws the permanent lower HUD and taller contextual inspector.

function scr_hud_bottom_bar_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _tray_height = _hud.hud.bottom.height;
    var _tray_top = _gui_height - _tray_height;

    var _inspector_width =
        _hud.hud.bottom.inspector_width;

    var _inspector_height =
        _hud.hud.bottom.inspector_height;

    var _inspector_left =
        _gui_width - _inspector_width;

    var _inspector_top =
        _gui_height - _inspector_height;



    if (_hud.hud.build_menu.open)
    {
        scr_hud_build_preview_inspector_draw(
            _hud,
            _inspector_left,
            _inspector_top,
            _gui_width,
            _gui_height
        );
    }
    else if (instance_exists(_hud.hud.selection.target))
    {
        scr_hud_selection_content_draw(
            _hud,
            _inspector_left,
            _inspector_top,
            _gui_width,
            _gui_height
        );
    }
    else
    {
        draw_set_color(c_aqua);

        draw_text(
            _inspector_left + 16,
            _inspector_top + 12,
            "STRUCTURE INSPECTOR"
        );

        draw_set_color(c_dkgray);

        draw_line(
            _inspector_left + 16,
            _inspector_top + 36,
            _gui_width - 16,
            _inspector_top + 36
        );

        draw_set_color(c_gray);

        draw_text(
            _inspector_left + 16,
            _inspector_top + 54,
            "Select a structure for information."
        );
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}

/// @description Draws live enemy-pressure information.

function scr_hud_pressure_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (!variable_struct_exists(global.vtd_level.entities, "spawner"))
        return true;


    var _spawner =
        global.vtd_level.entities.spawner;

    if (!instance_exists(_spawner))
        return true;


    var _runtime = _spawner.spawner;
    var _data = _runtime.data;

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _bottom_top =
        _gui_height - _hud.hud.bottom.height;

    var _x =
        _gui_width
        - _hud.hud.bottom.inspector_width
        - 300;

    var _y = _bottom_top + 14;


    draw_set_color(c_aqua);
    draw_text(_x, _y, "ENEMY PRESSURE");


    // ========================================================================
    // CURRENT PRESSURE STATE
    // ========================================================================

    if (_runtime.time.grace_remaining > 0)
    {
        draw_set_color(c_lime);

        draw_text(
            _x,
            _y + 24,
            "GRACE PERIOD // "
            + string(ceil(
                _runtime.time.grace_remaining
            ))
            + "s"
        );
    }
    else
    {
        draw_set_color(c_red);
        draw_text(_x, _y + 24, "PRESSURE ACTIVE");
    }


    // ========================================================================
    // POPULATION
    // ========================================================================

    draw_set_color(c_white);

    draw_text(
        _x,
        _y + 48,
        "ENEMIES  "
        + string(instance_number(o_enemy))
        + " / "
        + string(_data.maximum_alive_enemies)
    );

    draw_text(
        _x,
        _y + 68,
        "QUEUED   "
        + string(array_length(_runtime.queue))
        + " / "
        + string(_data.maximum_queued_enemies)
    );

    draw_text(
        _x,
        _y + 88,
        "KILLS    "
        + string(global.vtd_level.combat.kills)
    );


    // ========================================================================
    // ACTIVE WAVE WARNING
    // ========================================================================

    if (_runtime.waves.warning.active)
    {
        var _warning =
            _runtime.waves.warning;

        draw_set_color(c_red);

        draw_text(
            _x,
            _y + 116,
            "INBOUND  "
            + _warning.wave_name
        );

        draw_text(
            _x,
            _y + 136,
            scr_enemy_spawner_side_name(
                _warning.side
            )
            + " // "
            + string(ceil(_warning.remaining))
            + "s"
        );
    }
    else
    {
        draw_set_color(c_gray);

        draw_text(
            _x,
            _y + 116,
            "NEXT CLUSTER  "
            + string(max(
                0,
                ceil(_runtime.clusters.timer)
            ))
            + "s"
        );

        draw_text(
            _x,
            _y + 136,
            "NEXT WAVE     "
            + string(max(
                0,
                ceil(_runtime.waves.timer)
            ))
            + "s"
        );
    }


    // ========================================================================
    // LAST MAJOR EVENTS
    // ========================================================================

    draw_set_color(c_gray);

    var _last_event = "NONE";

    if (_runtime.waves.last_name != "")
        _last_event = _runtime.waves.last_name;

    if (_runtime.milestones.last_name != "")
        _last_event = _runtime.milestones.last_name;

    draw_text(
        _x,
        _y + 162,
        "LAST EVENT  "
        + _last_event
    );

    draw_text(
        _x,
        _y + 186,
        "G: END GRACE   M: FORCE WAVE"
    );


    draw_set_color(c_white);

    return true;
}

/// @description Returns the display color belonging to an alert type.

/// @description Draws the threatened map edge during a wave warning.

function scr_hud_wave_warning_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (!variable_struct_exists(
        global.vtd_level.entities,
        "spawner"
    ))
    {
        return true;
    }


    var _spawner =
        global.vtd_level.entities.spawner;

    if (!instance_exists(_spawner))
        return true;


    var _warning =
        _spawner.spawner.waves.warning;

    if (!_warning.active)
        return true;


    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _world_top =
        _hud.hud.top.height;

    var _world_bottom =
        _gui_height
        - _hud.hud.bottom.height;

    var _pulse =
        0.5
        + (sin(global.vtd.tick * 8) * 0.35);


    draw_set_alpha(_pulse);
    draw_set_color(c_red);


    switch (_warning.side)
    {
        case SpawnSide.TOP:
            draw_line_width(
                0,
                _world_top + 5,
                _gui_width,
                _world_top + 5,
                5
            );
        break;

        case SpawnSide.RIGHT:
            draw_line_width(
                _gui_width - 5,
                _world_top,
                _gui_width - 5,
                _world_bottom,
                5
            );
        break;

        case SpawnSide.BOTTOM:
            draw_line_width(
                0,
                _world_bottom - 5,
                _gui_width,
                _world_bottom - 5,
                5
            );
        break;

        case SpawnSide.LEFT:
            draw_line_width(
                5,
                _world_top,
                5,
                _world_bottom,
                5
            );
        break;
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

function scr_hud_top_cell_static_draw(
    _x,
    _width,
    _height,
    _label,
    _color,
    _y = 0
)
{
    var _left = _x;
    var _right = _x + _width;

    var _top = _y;
    var _bottom = _y + _height;

    var _middle_y =
        _top + (_height * 0.5);

    var _corner = 8;


    draw_set_alpha(0.22);
    draw_set_color(c_black);

    draw_rectangle(
        _left + 2,
        _top + 2,
        _right - 2,
        _bottom - 2,
        false
    );


    draw_set_alpha(0.72);
    draw_set_color(c_aqua);


    draw_line(
        _left + _corner,
        _top + 2,
        _right - _corner,
        _top + 2
    );

    draw_line(
        _left + _corner,
        _bottom - 2,
        _right - _corner,
        _bottom - 2
    );

    draw_line(
        _left + 2,
        _top + _corner,
        _left + 2,
        _bottom - _corner
    );

    draw_line(
        _right - 2,
        _top + _corner,
        _right - 2,
        _bottom - _corner
    );


    draw_line(
        _left + 2,
        _top + _corner,
        _left + _corner,
        _top + 2
    );

    draw_line(
        _right - _corner,
        _top + 2,
        _right - 2,
        _top + _corner
    );

    draw_line(
        _left + 2,
        _bottom - _corner,
        _left + _corner,
        _bottom - 2
    );

    draw_line(
        _right - _corner,
        _bottom - 2,
        _right - 2,
        _bottom - _corner
    );


    draw_set_alpha(0.45);

    draw_line(
        _left + _corner + 8,
        _top + 6,
        _left + _corner + 30,
        _top + 6
    );

    draw_line(
        _right - _corner - 30,
        _bottom - 6,
        _right - _corner - 8,
        _bottom - 6
    );


    draw_set_alpha(0.90);
    draw_set_color(_color);

    draw_line_width(
        _left + 12,
        _top + 12,
        _left + 12,
        _bottom - 12,
        2
    );


    draw_line(
        _left + 22,
        _middle_y,
        _left + 27,
        _middle_y - 5
    );

    draw_line(
        _left + 27,
        _middle_y - 5,
        _left + 32,
        _middle_y
    );

    draw_line(
        _left + 32,
        _middle_y,
        _left + 27,
        _middle_y + 5
    );

    draw_line(
        _left + 27,
        _middle_y + 5,
        _left + 22,
        _middle_y
    );


    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(_color);

    draw_text(
        _left + 40,
        _top + 10,
        string_upper(_label)
    );


    return _right;
}

function scr_hud_static_surface_build(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _surface_data =
        _hud.hud.static_surface;


    if (surface_exists(_surface_data.surface_id))
    {
        surface_free(
            _surface_data.surface_id
        );
    }


    _surface_data.surface_id =
        surface_create(
            _gui_width,
            _gui_height
        );


    if (!surface_exists(_surface_data.surface_id))
        return false;


    _surface_data.width =
        _gui_width;

    _surface_data.height =
        _gui_height;


    surface_set_target(
        _surface_data.surface_id
    );

    draw_clear_alpha(
        c_black,
        0
    );


    var _top =
        _hud.hud.top;

    var _top_height =
        _top.height;

    var _row_height =
        _top.row_height;


    draw_set_alpha(
        _top.background_alpha
    );

    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _top_height,
        false
    );


    draw_set_alpha(1);
    draw_set_color(_top.color);

    draw_line(
        0,
        _top_height,
        _gui_width,
        _top_height
    );


    draw_set_color(c_dkgray);

    draw_line(
        0,
        _row_height,
        _gui_width,
        _row_height
    );


    var _time_width = 130;
    var _cpu_width = 180;
    var _player_width = 180;

    var _right_width =
        _player_width
        + _cpu_width
        + _time_width;

    var _right_x =
        _gui_width
        - _right_width;


    var _draw_x = 0;


    _draw_x =
        scr_hud_top_cell_static_draw(
            _draw_x,
            170,
            _row_height,
            "Credits",
            c_aqua,
            0
        );


    _draw_x =
        scr_hud_top_cell_static_draw(
            _draw_x,
            220,
            _row_height,
            "Energy",
            c_lime,
            0
        );


    var _resource_width = 240;

    var _resource_keys =
        variable_struct_get_names(
            global.vtd.data.resources
        );


    for (
        var i = 0;
        i < array_length(_resource_keys);
        ++i
    )
    {
        var _resource_data =
            scr_resource_data_get(
                _resource_keys[i]
            );


        if (!scr_resource_data_valid(_resource_data))
            continue;

        if (
            _resource_data.identity.type
            != ResourceType.RAW_MATERIAL
        )
        {
            continue;
        }


        if (
            _draw_x + _resource_width
            > _right_x
        )
        {
            continue;
        }


        _draw_x =
            scr_hud_top_cell_static_draw(
                _draw_x,
                _resource_width,
                _row_height,
                _resource_data.identity.name + " R/F",
                _resource_data.visual.color,
                0
            );
    }


    var _right_cell_x =
        _right_x;


    _right_cell_x =
        scr_hud_top_cell_static_draw(
            _right_cell_x,
            _player_width,
            _row_height,
            "Player Integrity",
            c_aqua,
            0
        );


    _right_cell_x =
        scr_hud_top_cell_static_draw(
            _right_cell_x,
            _cpu_width,
            _row_height,
            "CPU Integrity",
            c_lime,
            0
        );


    scr_hud_top_cell_static_draw(
        _right_cell_x,
        _time_width,
        _row_height,
        "Elapsed",
        c_aqua,
        0
    );


    var _limit_types =
    [
        BuildLimitType.TOWER,
        BuildLimitType.DEFENSE,
        BuildLimitType.ECONOMY,
        BuildLimitType.INFRASTRUCTURE,
        BuildLimitType.FOUNDATION
    ];

    var _limit_colors =
    [
        c_yellow,
        c_fuchsia,
        make_color_rgb(90, 210, 120),
        c_aqua,
        make_color_rgb(100, 150, 190)
    ];


    var _limit_x = 0;
    var _limit_width = 180;


    for (
        var i = 0;
        i < array_length(_limit_types);
        ++i
    )
    {
        _limit_x =
            scr_hud_top_cell_static_draw(
                _limit_x,
                _limit_width,
                _row_height,
                scr_build_limit_name(
                    _limit_types[i]
                ),
                _limit_colors[i],
                _row_height
            );
    }


    scr_hud_top_cell_static_draw(
        _gui_width - _time_width,
        _time_width,
        _row_height,
        "Enemies",
        c_red,
        _row_height
    );


    var _bottom =
        _hud.hud.bottom;

    var _tray_top =
        _gui_height
        - _bottom.height;

    var _inspector_left =
        _gui_width
        - _bottom.inspector_width;

    var _inspector_top =
        _gui_height
        - _bottom.inspector_height;


    draw_set_alpha(
        _bottom.background_alpha
    );

    draw_set_color(c_black);


    draw_rectangle(
        0,
        _tray_top,
        _inspector_left,
        _gui_height,
        false
    );


    draw_rectangle(
        _inspector_left,
        _inspector_top,
        _gui_width,
        _gui_height,
        false
    );


    draw_set_alpha(1);

    draw_set_color(
        _bottom.color
    );


    draw_line(
        0,
        _tray_top,
        _inspector_left,
        _tray_top
    );


    draw_line(
        _inspector_left,
        _inspector_top,
        _gui_width,
        _inspector_top
    );


    draw_line(
        _inspector_left,
        _inspector_top,
        _inspector_left,
        _gui_height
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);


    surface_reset_target();


    return true;
}

function scr_hud_static_surface_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _surface =
        _hud.hud.static_surface;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();


    if (
        !surface_exists(_surface.surface_id)
        || _surface.width != _gui_width
        || _surface.height != _gui_height
    )
    {
        if (!scr_hud_static_surface_build(_hud))
            return false;
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_surface(
        _surface.surface_id,
        0,
        0
    );


    return true;
}

function scr_hud_top_cell_draw(
    _x,
    _width,
    _height,
    _label,
    _value,
    _color,
    _y = 0
)
{
    draw_set_alpha(1);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(c_white);

    draw_text(
        _x + 40,
        _y + 30,
        _value
    );


    return _x + _width;
}
/// @description Pushes resource-gain feedback into the level HUD.

function scr_hud_resource_gain_push(
    _resource_key,
    _amount
)
{
    if (_amount <= 0)
        return false;

    if (!variable_global_exists("vtd_level"))
        return false;

    if (!variable_struct_exists(global.vtd_level.entities, "hud"))
        return false;


    var _hud =
        global.vtd_level.entities.hud;

    if (!instance_exists(_hud))
        return false;


    var _feedback =
        _hud.hud.resource_feedback;


    if (
        _feedback.resource_key
        == _resource_key
        && _feedback.remaining > 0
    )
    {
        _feedback.amount += _amount;
    }
    else
    {
        _feedback.resource_key =
            _resource_key;

        _feedback.amount =
            _amount;
    }


    _feedback.remaining =
        _feedback.duration;


    return true;
}

/// @description Updates the temporary resource-gain HUD feedback.

function scr_hud_resource_feedback_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _feedback =
        _hud.hud.resource_feedback;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _feedback.remaining =
        max(
            0,
            _feedback.remaining
            - (1 / _fps)
        );


    return true;
}

/// @description Draws temporary resource-gain feedback in the top HUD.

function scr_hud_resource_feedback_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _feedback =
        _hud.hud.resource_feedback;

    if (_feedback.remaining <= 0)
        return true;


    var _progress =
        _feedback.remaining
        / max(0.01, _feedback.duration);

    var _alpha =
        clamp(
            _progress * 2,
            0,
            1
        );


    var _resource_data =
        scr_resource_data_get(
            _feedback.resource_key
        );

    var _color = c_lime;

    if (scr_resource_data_valid(_resource_data))
        _color = _resource_data.visual.color;


    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);

    draw_set_alpha(_alpha);
    draw_set_color(_color);

    draw_text(
        158,
        22,
        "+"
        + string(
            floor(_feedback.amount)
        )
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);


    return true;
}

/// @description Draws progression and combat information for a selected tower.

function scr_hud_tower_selection_draw(
    _tower,
    _left,
    _top,
    _right
)
{
    if (!instance_exists(_tower))
        return false;


    draw_set_color(c_dkgray);

    draw_line(
        _left + 18,
        _top + 98,
        _right - 18,
        _top + 98
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 110,
        "RANK",
        string(_tower.progression.rank)
        + " / "
        + string(_tower.progression.maximum_rank),
        c_yellow
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 130,
        "KILLS",
        _tower.progression.kills,
        c_white
    );


    var _experience_text =
        "MAXIMUM";

    if (
        _tower.progression.rank
        < _tower.progression.maximum_rank
    )
    {
        _experience_text =
            string(_tower.progression.experience)
            + " / "
            + string(_tower.progression.next_experience);
    }


    scr_hud_label_value_draw(
        _left + 18,
        _top + 150,
        "EXPERIENCE",
        _experience_text,
        c_aqua
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 170,
        "DAMAGE",
        string_format(
            _tower.combat.weapon.damage,
            0,
            1
        ),
        c_white
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 190,
        "RANGE",
        string_format(
            _tower.combat.range,
            0,
            1
        ),
        c_white
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 210,
        "FIRE DELAY",
        string_format(
            _tower.combat.weapon.cooldown.duration,
            0,
            3
        )
        + "s",
        c_white
    );


    // FUTURE:
    // targeting-mode controls
    // rank progress bar
    // overclock control
    // local-research bonuses
    // persistent-upgrade bonuses


    return true;
}

/// @description Creates the reusable selected-building control panel.

function scr_hud_selection_panel_create()
{
    var _closest =
        scr_hud_button_create(
            "target_closest",
            "CLOSEST",
            "NEAREST"
        );

    _closest.data =
        TowerTargetMode.CLOSEST;


    var _furthest =
        scr_hud_button_create(
            "target_furthest",
            "FURTHEST",
            "DISTANT"
        );

    _furthest.data =
        TowerTargetMode.FURTHEST;


    var _lowest_hp =
        scr_hud_button_create(
            "target_lowest_hp",
            "LOWEST HP",
            "WEAKEST"
        );

    _lowest_hp.data =
        TowerTargetMode.LOWEST_HP;


    var _highest_hp =
        scr_hud_button_create(
            "target_highest_hp",
            "HIGHEST HP",
            "STRONGEST"
        );

    _highest_hp.data =
        TowerTargetMode.HIGHEST_HP;


    var _upgrade =
        scr_hud_button_create(
            "action_upgrade",
            "UPGRADE",
            "FUTURE"
        );

    _upgrade.enabled = false;


    var _repair =
        scr_hud_button_create(
            "action_repair",
            "REPAIR",
            "FUTURE"
        );

    _repair.enabled = false;


    var _sell =
        scr_hud_button_create(
            "action_sell",
            "SELL",
            "50% REFUND"
        );

    _sell.accent_color = c_lime;


    var _disable =
        scr_hud_button_create(
            "action_disable",
            "DISABLE",
            "FUTURE"
        );

    _disable.enabled = false;
    _disable.accent_color = c_red;


    var _continuous =
        scr_hud_button_create(
            "attack_continuous",
            "CONTINUOUS",
            "DEFAULT"
        );

    _continuous.enabled = false;
    _continuous.selected = true;


    var _burst =
        scr_hud_button_create(
            "attack_burst",
            "BURST FIRE",
            "FUTURE"
        );

    _burst.enabled = false;

	var _energy_controls =
    scr_hud_energy_controls_create();

    return
    {
        target_buttons:
        [
            _closest,
            _furthest,
            _lowest_hp,
            _highest_hp
        ],

        action_buttons:
        {
            upgrade: _upgrade,
            repair: _repair,
            sell: _sell,
            disable: _disable
        },

        attack_buttons:
        [
            _continuous,
            _burst
        ],
		
		energy_controls:
		_energy_controls,

        sell:
        {
            armed: false,
            target: noone,

            remaining: 0,
            confirmation_seconds: 2
        },

        previous_target: noone
    };
}

/// @description Returns readable information about a tower targeting mode.

function scr_hud_tower_target_mode_description(_mode)
{
    switch (_mode)
    {
        case TowerTargetMode.CLOSEST:
            return "Targets the nearest valid enemy inside range.";

        case TowerTargetMode.FURTHEST:
            return "Targets the most distant valid enemy inside range.";

        case TowerTargetMode.LOWEST_HP:
            return "Targets the valid enemy with the least remaining health.";

        case TowerTargetMode.HIGHEST_HP:
            return "Targets the valid enemy with the most remaining health.";
    }


    return "Unknown targeting priority.";
}

/// @description Refunds a percentage of one building's original cost.

function scr_hud_building_refund(
    _building,
    _fraction
)
{
    if (!instance_exists(_building))
        return false;

    if (!variable_instance_exists(_building, "building_data"))
        return false;

    if (!is_struct(_building.building_data))
        return false;

    if (!variable_struct_exists(_building.building_data, "economy"))
        return false;


    var _cost =
        _building.building_data.economy.cost;

    if (!is_array(_cost))
        return false;


    var _refund_fraction =
        clamp(
            _fraction,
            0,
            1
        );


    for (var i = 0; i < array_length(_cost); ++i)
    {
        var _entry = _cost[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "resource_key"))
            continue;

        if (!variable_struct_exists(_entry, "amount"))
            continue;


        var _refund =
            floor(
                _entry.amount
                * _refund_fraction
            );


        if (_refund <= 0)
            continue;


        scr_resource_amount_add(
            _entry.resource_key,
            _refund
        );


        scr_hud_resource_gain_push(
            _entry.resource_key,
            _refund
        );
    }


    return true;
}

/// @description Sells a player building and refunds part of its construction cost.

function scr_hud_building_sell(
    _hud,
    _building
)
{
    if (!instance_exists(_hud))
        return false;

    if (!instance_exists(_building))
        return false;

    if (_building.identity.type == BuildingType.CPU)
        return false;

    if (_building.BuildingState == BuildingState.DESTROYED)
        return false;


    var _building_name =
        _building.identity.name;


    // Refund before destruction so physical storage capacity still exists
    // if future buildings refund raw materials.

    scr_hud_building_refund(
        _building,
        0.5
    );


    _hud.hud.selection.target =
        noone;

    _hud.hud.selection_panel.sell.armed =
        false;

    _hud.hud.selection_panel.sell.target =
        noone;

    _hud.hud.selection_panel.sell.remaining =
        0;


    _building.BuildingState =
        BuildingState.DESTROYED;

    instance_destroy(
        _building
    );


    scr_hud_alert_push(
        HudAlertType.INFO,
        "STRUCTURE SOLD",
        string_upper(_building_name)
        + " // 50% REFUND",
        2
    );


    show_debug_message(
        "BUILDING SOLD: "
        + _building_name
    );


    return true;
}

/// @description Updates the selected-building contextual control panel.

function scr_hud_selection_panel_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _panel =
        _hud.hud.selection_panel;

    var _selected =
        _hud.hud.selection.target;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    // ========================================================================
    // SELL CONFIRMATION TIMER
    // ========================================================================

    _panel.sell.remaining =
        max(
            0,
            _panel.sell.remaining
            - (1 / _fps)
        );


    if (_panel.sell.remaining <= 0)
    {
        _panel.sell.armed = false;
        _panel.sell.target = noone;
    }


    // A different selected building cancels the previous confirmation.

    if (_panel.previous_target != _selected)
    {
        _panel.previous_target = _selected;

        _panel.sell.armed = false;
        _panel.sell.target = noone;
        _panel.sell.remaining = 0;
    }


    if (!instance_exists(_selected))
        return true;

    if (_hud.hud.build_menu.open)
        return true;


    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _tray_top =
        _gui_height
        - _hud.hud.bottom.height;

    var _inspector_left =
        _gui_width
        - _hud.hud.bottom.inspector_width;


    // ========================================================================
    // TARGET PRIORITY BUTTONS
    // ========================================================================

    var _target_x = 210;
    var _target_y = _tray_top + 44;
    var _target_width = 105;
    var _target_height = 66;
    var _target_gap = 7;


    for (
        var i = 0;
        i < array_length(_panel.target_buttons);
        ++i
    )
    {
        var _button =
            _panel.target_buttons[i];

        scr_hud_button_bounds_set(
            _button,
            _target_x
                + (i * (_target_width + _target_gap)),
            _target_y,
            _target_width,
            _target_height
        );


        var _is_tower =
            _selected.object_index
            == o_tower;

        _button.enabled =
            _is_tower;

        _button.selected =
            _is_tower
            && _selected.targeting.mode
                == _button.data;


        if (
            _is_tower
            && scr_hud_button_update(_button)
        )
        {
            _selected.targeting.mode =
                _button.data;


            // Immediately abandon and reacquire using the new policy.

            _selected.targeting.target =
                noone;

            _selected.targeting.target =
                scr_tower_target_acquire(
                    _selected
                );


            show_debug_message(
                "TOWER TARGET MODE CHANGED: "
                + _selected.identity.name
                + " | "
                + string(_selected.targeting.mode)
            );
        }
    }


    // ========================================================================
    // ATTACK-BEHAVIOR PLACEHOLDERS
    // ========================================================================

    var _attack_x =
        _inspector_left - 190;

    var _attack_y =
        _tray_top + 44;


    for (
        var i = 0;
        i < array_length(_panel.attack_buttons);
        ++i
    )
    {
        scr_hud_button_bounds_set(
            _panel.attack_buttons[i],
            _attack_x,
            _attack_y + (i * 54),
            174,
            46
        );
    }


    // ========================================================================
    // ACTION BUTTONS
    // ========================================================================

    var _action_y =
        _gui_height - 52;

    var _action_x = 210;
    var _action_width = 140;
    var _action_height = 38;
    var _action_gap = 10;

    var _upgrade =
        _panel.action_buttons.upgrade;

    var _repair =
        _panel.action_buttons.repair;

    var _sell =
        _panel.action_buttons.sell;

    var _disable =
        _panel.action_buttons.disable;


    scr_hud_button_bounds_set(
        _upgrade,
        _action_x,
        _action_y,
        _action_width,
        _action_height
    );

    scr_hud_button_bounds_set(
        _repair,
        _action_x + (_action_width + _action_gap),
        _action_y,
        _action_width,
        _action_height
    );

    scr_hud_button_bounds_set(
        _sell,
        _action_x + ((_action_width + _action_gap) * 2),
        _action_y,
        _action_width,
        _action_height
    );

    scr_hud_button_bounds_set(
        _disable,
        _action_x + ((_action_width + _action_gap) * 3),
        _action_y,
        _action_width,
        _action_height
    );
	
	scr_hud_energy_controls_update(
    _hud,
    _selected,
    _inspector_left,
    _tray_top
);

    if (_selected.object_index == o_refinery)
    {
        scr_hud_refinery_controls_update(
            _hud,
            _selected,
            _inspector_left,
            _tray_top
        );
    }
	
	else if (_selected.object_index == o_fabricator)
{
    scr_hud_fabricator_controls_update(
        _hud,
        _selected,
        _inspector_left,
        _tray_top
    );
}


    _sell.enabled =
        _selected.identity.type
        != BuildingType.CPU;

	// ========================================================================
	// ENABLE / DISABLE
	// ========================================================================

	var _can_toggle =
	    _selected.identity.type != BuildingType.CPU
	    && (
	        _selected.BuildingState == BuildingState.ACTIVE
	        || _selected.BuildingState == BuildingState.DISABLED
	    );


	_disable.enabled =
	    _can_toggle;


	if (_selected.BuildingState == BuildingState.DISABLED)
	{
	    _disable.label = "ENABLE";
	    _disable.subtitle = "RESTORE";
	    _disable.accent_color = c_lime;
	}
	else
	{
	    _disable.label = "DISABLE";
	    _disable.subtitle = "HALT";
	    _disable.accent_color = c_red;
	}

    if (
        _panel.sell.armed
        && _panel.sell.target == _selected
    )
    {
        _sell.label =
            "CONFIRM SELL";

        _sell.subtitle =
            string_format(
                _panel.sell.remaining,
                0,
                1
            )
            + "s";

        _sell.accent_color =
            c_yellow;
    }
    else
    {
        _sell.label =
            "SELL";

        _sell.subtitle =
            "50% REFUND";

        _sell.accent_color =
            c_lime;
    }


    if (scr_hud_button_update(_sell))
    {
        if (
            _panel.sell.armed
            && _panel.sell.target == _selected
        )
        {
            scr_hud_building_sell(
                _hud,
                _selected
            );

            return true;
        }


        _panel.sell.armed =
            true;

        _panel.sell.target =
            _selected;

        _panel.sell.remaining =
            _panel.sell.confirmation_seconds;
    }
	
	if (
    _can_toggle
    && scr_hud_button_update(_disable)
	)
	{
	    switch (_selected.BuildingState)
	    {
	        case BuildingState.ACTIVE:
	        {
	            _selected.BuildingState =
	                BuildingState.DISABLED;

	            if (
	                variable_instance_exists(_selected, "energy")
	                && is_struct(_selected.energy)
	            )
	            {
	                _selected.energy.supplied = false;

	                _selected.energy.demand.activity_spent = 0;

	                _selected.energy.demand
	                    .activity_recent_per_second = 0;
	            }


	            scr_energy_topology_dirty();


	            scr_hud_alert_push(
	                HudAlertType.INFO,
	                "STRUCTURE DISABLED",
	                string_upper(_selected.identity.name),
	                1.5
	            );
	        }
	        break;


	        case BuildingState.DISABLED:
	        {
	            _selected.BuildingState =
	                BuildingState.ACTIVE;

	            scr_energy_topology_dirty();


	            scr_hud_alert_push(
	                HudAlertType.SUCCESS,
	                "STRUCTURE ENABLED",
	                string_upper(_selected.identity.name),
	                1.5
	            );
	        }
	        break;
	    }
	}


    // Right-clicking while the contextual panel is open deselects.

    if (
        mouse_check_button_pressed(mb_right)
        && scr_hud_pointer_blocks_world()
    )
    {
        _hud.hud.selection.target =
            noone;

        _panel.sell.armed =
            false;

        _panel.sell.target =
            noone;

        _panel.sell.remaining =
            0;
    }


    return true;
}

/// @description Draws the selected-building controls in the bottom-left HUD.

function scr_hud_selection_panel_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _selected =
        _hud.hud.selection.target;

    if (!instance_exists(_selected))
        return true;

    if (_hud.hud.build_menu.open)
        return true;


    var _panel =
        _hud.hud.selection_panel;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _tray_top =
        _gui_height
        - _hud.hud.bottom.height;

    var _inspector_left =
        _gui_width
        - _hud.hud.bottom.inspector_width;


    // ========================================================================
    // SECTION SEPARATORS
    // ========================================================================

    draw_set_color(c_aqua);

    draw_line(
        0,
        _tray_top,
        _inspector_left,
        _tray_top
    );


    draw_set_color(c_dkgray);

    draw_line(
        194,
        _tray_top + 12,
        194,
        _gui_height - 14
    );

    draw_line(
        _inspector_left - 206,
        _tray_top + 12,
        _inspector_left - 206,
        _gui_height - 14
    );


    // ========================================================================
    // SELECTED STRUCTURE SUMMARY
    // ========================================================================

    draw_set_color(c_aqua);

    draw_text(
        16,
        _tray_top + 12,
        "SELECTED STRUCTURE"
    );


    scr_hud_building_preview_draw(
        _selected.building_data,
        78,
        _tray_top + 91,
        100
    );


    draw_set_color(
        _selected.visual.color
    );

    draw_text(
        16,
        _tray_top + 150,
        string_upper(
            _selected.identity.name
        )
    );


    var _hp_ratio =
        clamp(
            _selected.vitals.hp.current
            / max(
                1,
                _selected.vitals.hp.maximum
            ),
            0,
            1
        );


    draw_set_color(c_dkgray);

    draw_rectangle(
        16,
        _tray_top + 178,
        178,
        _tray_top + 186,
        false
    );


    draw_set_color(c_lime);

    draw_rectangle(
        16,
        _tray_top + 178,
        16 + (162 * _hp_ratio),
        _tray_top + 186,
        false
    );


    draw_set_color(c_white);

    draw_text(
        16,
        _tray_top + 192,
        string(ceil(_selected.vitals.hp.current))
        + " / "
        + string(ceil(_selected.vitals.hp.maximum))
    );


    // ========================================================================
    // CATEGORY-SPECIFIC CONTROLS
    // ========================================================================

    if (_selected.object_index == o_tower)
    {
        draw_set_color(c_aqua);

        draw_text(
            210,
            _tray_top + 12,
            "TARGET PRIORITY"
        );


        for (
            var i = 0;
            i < array_length(_panel.target_buttons);
            ++i
        )
        {
            scr_hud_button_draw(
                _panel.target_buttons[i]
            );
        }


        draw_set_color(c_aqua);

        draw_text(
            210,
            _tray_top + 120,
            string_upper(
                scr_hud_tower_target_mode_description(
                    _selected.targeting.mode
                )
            )
        );


        draw_set_color(c_gray);

        draw_text(
            210,
            _tray_top + 143,
            "RANK "
            + string(_selected.progression.rank)
            + "  //  KILLS "
            + string(_selected.progression.kills)
            + "  //  XP "
            + string(_selected.progression.experience)
        );
		
		scr_hud_tower_consumables_draw(
		    _selected,
		    210,
		    _tray_top + 172
		);


        // FUTURE:
        // attack behavior
        // overclock controls
        // manual targeting
    }
    else if (_selected.object_index == o_refinery)
    {
        scr_hud_refinery_controls_draw(
            _hud,
            _selected,
            _inspector_left,
            _tray_top
        );
    }
	
	else if (_selected.object_index == o_fabricator)
	{
	    scr_hud_fabricator_controls_draw(
	        _hud,
	        _selected,
	        _inspector_left,
	        _tray_top
	    );
	}
    else
    {
        draw_set_color(c_aqua);

        draw_text(
            210,
            _tray_top + 12,
            "STRUCTURE CONTROLS"
        );


        draw_set_color(c_gray);

        draw_text_ext(
            210,
            _tray_top + 44,
            "A specialized control interface for this building category will occupy this area.",
            18,
            max(
                200,
                _inspector_left - 440
            )
        );


        // FUTURE:
        // miner controls
        // storage filters
        // refinery recipes
        // generator output controls
        // battery reserve controls
    }


    // ========================================================================
    // ENERGY PRIORITY
    // ========================================================================

    scr_hud_energy_controls_draw(
        _hud,
        _selected,
        _inspector_left,
        _tray_top
    );


    // ========================================================================
    // ACTION BUTTONS
    // ========================================================================

    draw_set_color(c_dkgray);

    draw_line(
        210,
        _gui_height - 64,
        _inspector_left - 16,
        _gui_height - 64
    );


    scr_hud_button_draw(
        _panel.action_buttons.upgrade
    );

    scr_hud_button_draw(
        _panel.action_buttons.repair
    );

    scr_hud_button_draw(
        _panel.action_buttons.sell
    );

    scr_hud_button_draw(
        _panel.action_buttons.disable
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);


    return true;
}

/// @description Returns readable energy-priority text.

function scr_hud_energy_priority_text(_priority)
{
    switch (_priority)
    {
        case EnergyPriority.CRITICAL: return "CRITICAL";
        case EnergyPriority.HIGH:     return "HIGH";
        case EnergyPriority.NORMAL:   return "NORMAL";
        case EnergyPriority.LOW:      return "LOW";
    }

    return "UNKNOWN";
}

/// @description Draws live ammunition information for a selected tower.

function scr_hud_tower_consumables_draw(
    _tower,
    _x,
    _y
)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_instance_exists(_tower, "consumables"))
        return true;

    if (!is_array(_tower.consumables))
        return true;

    if (array_length(_tower.consumables) <= 0)
        return true;


    draw_set_color(c_aqua);

    draw_text(
        _x,
        _y,
        "AMMUNITION"
    );

    _y += 22;


    for (var i = 0; i < array_length(_tower.consumables); ++i)
    {
        var _entry = _tower.consumables[i];

        var _resource_data =
            scr_resource_data_get(
                _entry.resource_key
            );

        var _name = "UNKNOWN";
        var _color = c_white;

        if (scr_resource_data_valid(_resource_data))
        {
            _name =
                string_upper(
                    _resource_data.identity.name
                );

            _color =
                _resource_data.visual.color;
        }


        if (_entry.current <= 0)
            _color = c_red;
        else if (
            _entry.current
            <= _entry.maximum
            * _entry.request_threshold
        )
        {
            _color = c_yellow;
        }


        scr_hud_label_value_draw(
            _x,
            _y,
            _name,
            string(floor(_entry.current))
            + " / "
            + string(floor(_entry.maximum)),
            _color
        );

        _y += 20;
    }


    draw_set_color(c_white);

    return true;
}