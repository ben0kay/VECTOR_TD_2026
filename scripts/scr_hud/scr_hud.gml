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

    if (global.BuildState != BuildState.NONE)
        return true;

    if (scr_hud_pointer_blocks_world())
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
            var _resource_data =
                scr_resource_data_get(
                    _selected.storage.resource_key
                );

            var _resource_name =
                _selected.storage.resource_key;

            var _resource_color =
                _selected.visual.color;


            if (scr_resource_data_valid(_resource_data))
            {
                _resource_name =
                    _resource_data.identity.name;

                _resource_color =
                    _resource_data.visual.color;
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
                "CONTENTS",
                string_format(_selected.storage.current, 0, 1)
                + " / "
                + string_format(_selected.storage.capacity, 0, 1),
                _resource_color
            );


            scr_hud_label_value_draw(
                _left + 18,
                _top + 150,
                "INCOMING",
                string_format(
                    _selected.storage.incoming_reserved,
                    0,
                    1
                ),
                c_aqua
            );


            var _storage_status =
                scr_hud_storage_status_get(_selected);

            var _storage_status_color = c_white;


            switch (_storage_status)
            {
                case "DELIVERY INCOMING":
                    _storage_status_color = c_aqua;
                break;

                case "AVAILABLE":
                    _storage_status_color = c_lime;
                break;

                case "FULL":
                    _storage_status_color = c_yellow;
                break;
            }


            scr_hud_label_value_draw(
                _left + 18,
                _top + 170,
                "OPERATION",
                _storage_status,
                _storage_status_color
            );


            // FUTURE:
            // storage transfer rules
            // accepted-resource filters
            // priority settings
            // cargo ports
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

    if (_storage.storage.current >= _storage.storage.capacity)
        return "FULL";

    if (_storage.storage.incoming_reserved > 0)
        return "DELIVERY INCOMING";

    if (_storage.storage.current > 0)
        return "AVAILABLE";

    return "EMPTY";
}


/// @description Draws the permanent top resource bar.

function scr_hud_top_bar_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _gui_width = display_get_gui_width();
    var _height = _hud.hud.top.height;


    draw_set_alpha(_hud.hud.top.background_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_width, _height, false);


    draw_set_alpha(1);
    draw_set_color(_hud.hud.top.color);
    draw_line(0, _height, _gui_width, _height);


    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    draw_set_color(c_white);
    draw_text(16, _height * 0.5, "LEVEL RESOURCES");


    var _draw_x = 170;


    if (
        variable_struct_exists(
            global.vtd_level.resources,
            "entries"
        )
    )
    {
        var _entries = global.vtd_level.resources.entries;
        var _keys = variable_struct_get_names(_entries);


        for (var i = 0; i < array_length(_keys); ++i)
        {
            var _entry =
                variable_struct_get(
                    _entries,
                    _keys[i]
                );

            var _resource_data =
                scr_resource_data_get(_entry.key);

            var _name = _entry.key;
            var _color = c_white;


            if (scr_resource_data_valid(_resource_data))
            {
                _name = _resource_data.identity.name;
                _color = _resource_data.visual.color;
            }


            draw_set_color(_color);

            draw_text(
                _draw_x,
                _height * 0.5,
                string_upper(_name)
                + " "
                + string(floor(_entry.current))
                + " / "
                + string(floor(_entry.capacity))
            );


            _draw_x += 210;
        }
    }


    var _cpu = global.vtd_level.entities.cpu;


    if (instance_exists(_cpu))
    {
        draw_set_halign(fa_right);
        draw_set_color(c_aqua);

        draw_text(
            _gui_width - 16,
            _height * 0.5,
            "CPU "
            + string(ceil(_cpu.vitals.hp.current))
            + " / "
            + string(ceil(_cpu.vitals.hp.maximum))
        );
    }


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the permanent lower HUD and contextual inspector.

function scr_hud_bottom_bar_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _height =
        _hud.hud.bottom.height;

    var _top =
        _gui_height - _height;

    var _inspector_width =
        _hud.hud.bottom.inspector_width;

    var _inspector_left =
        _gui_width - _inspector_width;


    // ========================================================================
    // SHELL
    // ========================================================================

    draw_set_alpha(
        _hud.hud.bottom.background_alpha
    );

    draw_set_color(c_black);

    draw_rectangle(
        0,
        _top,
        _gui_width,
        _gui_height,
        false
    );


    draw_set_alpha(1);
    draw_set_color(_hud.hud.bottom.color);

    draw_line(
        0,
        _top,
        _gui_width,
        _top
    );

    draw_line(
        _inspector_left,
        _top,
        _inspector_left,
        _gui_height
    );


    // ========================================================================
    // BUILD DATABASE INSPECTOR
    // ========================================================================

    if (_hud.hud.build_menu.open)
    {
        scr_hud_build_preview_inspector_draw(
            _hud,
            _inspector_left,
            _top,
            _gui_width,
            _gui_height
        );
    }

    // ========================================================================
    // SELECTED WORLD STRUCTURE
    // ========================================================================

    else if (
        instance_exists(
            _hud.hud.selection.target
        )
    )
    {
        scr_hud_selection_content_draw(
            _hud,
            _inspector_left,
            _top,
            _gui_width,
            _gui_height
        );
    }

    // ========================================================================
    // EMPTY INSPECTOR
    // ========================================================================

    else
    {
        draw_set_color(c_aqua);

        draw_text(
            _inspector_left + 18,
            _top + 14,
            "STRUCTURE INSPECTOR"
        );

        draw_set_color(c_dkgray);

        draw_line(
            _inspector_left + 18,
            _top + 38,
            _gui_width - 18,
            _top + 38
        );

        draw_set_color(c_gray);

        draw_text(
            _inspector_left + 18,
            _top + 56,
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

