/// @description Grid-snapped building placement mode.


/// @description Initializes the build controller.

function scr_build_mode_initialize(
    _controller
)
{
    if (!instance_exists(_controller))
        return false;


    global.BuildState =
        BuildState.NONE;


    _controller.build =
    {
        selected_key:
            "",

        preview:
        {
            cell_x:
                -1,

            cell_y:
                -1,

            world_x:
                0,

            world_y:
                0,

            valid:
                false
        }
    };


    global.vtd_level.entities
        .build_controller =
        _controller;


    return true;
}

/// @description Shows the current capacity when placement is rejected.

function scr_build_limit_alert_push(_data)
{
    if (!is_struct(_data))
        return false;

    if (
        !variable_struct_exists(
            _data,
            "build_limit"
        )
    )
    {
        return false;
    }


    var _limit =
        _data.build_limit;

    if (!is_struct(_limit))
        return false;

    if (_limit.type == BuildLimitType.NONE)
        return false;


    var _entry =
        scr_build_limit_entry_get(
            _limit.type
        );

    if (!is_struct(_entry))
        return false;


    scr_hud_alert_push(
        HudAlertType.WARNING,
        "BUILD LIMIT REACHED",

        scr_build_limit_name(
            _limit.type
        )
        + "  "
        + string(_entry.used)
        + " / "
        + string(_entry.maximum),

        2.5
    );


    return true;
}


/// @description Cancels the current placement mode.

function scr_build_mode_cancel(
    _controller
)
{
    if (!instance_exists(_controller))
        return false;


    _controller.build.selected_key =
        "";

    _controller.build.preview.valid =
        false;

    global.BuildState =
        BuildState.NONE;


    return true;
}


/// @description Updates the snapped placement preview.

function scr_build_mode_preview_update(_controller)
{
    if (!instance_exists(_controller))
        return false;


    var _data = scr_building_data_get(
        _controller.build.selected_key
    );


    if (!scr_building_data_valid(_data))
        return false;


    var _mouse_cell = scr_building_position_to_cell(
        mouse_x,
        mouse_y
    );

    var _preview = _controller.build.preview;


    _preview.cell_x = _mouse_cell.x;
    _preview.cell_y = _mouse_cell.y;


    var _position = scr_building_cell_to_position(
        _preview.cell_x,
        _preview.cell_y
    );

    var _cell_size = global.vtd_level.map.cell_size;


    _preview.world_x =
        _position.x
        + (
            (_data.footprint.width_cells - 1)
            * _cell_size
            * 0.5
        );

    _preview.world_y =
        _position.y
        + (
            (_data.footprint.height_cells - 1)
            * _cell_size
            * 0.5
        );


    _preview.valid = scr_build_mode_placement_valid(
        _data,
        _preview.cell_x,
        _preview.cell_y
    );


    return true;
}

/// @description Begins placement for one building definition.

function scr_build_mode_begin(
    _controller,
    _building_key
)
{
    if (!instance_exists(_controller))
        return false;


    var _data =
        scr_building_data_get(
            _building_key
        );


    if (!scr_building_data_valid(_data))
        return false;


    // Reject the selection immediately when its category is full.

    if (!scr_build_limit_can_place(_data))
    {
        scr_build_limit_alert_push(
            _data
        );

        return false;
    }


    _controller.build.selected_key =
        _building_key;

    global.BuildState =
        BuildState.PLACING;


    return true;
}


/// @description Processes selected-building placement input.

function scr_build_mode_update(_controller)
{
    if (!instance_exists(_controller))
        return false;


    switch (global.BuildState)
    {
        case BuildState.NONE:
        {
            // The level HUD owns building selection.
        }
        break;


        case BuildState.PLACING:
        {
            scr_build_mode_preview_update(_controller);


            if (mouse_check_button_pressed(mb_right))
            {
                scr_build_mode_cancel(_controller);
                break;
            }


            // Never place a building through the permanent HUD.

            if (scr_hud_pointer_blocks_world())
                break;


            if (mouse_check_button_pressed(mb_left))
            {
                scr_build_mode_place(_controller);
                scr_build_mode_preview_update(_controller);
            }
        }
        break;
    }


    return true;
}


/// @description Draws the current placement preview.

function scr_build_mode_draw(
    _controller
)
{
    if (!instance_exists(_controller))
        return false;

    if (
        global.BuildState
        != BuildState.PLACING
    )
    {
        return true;
    }


    var _data =
        scr_building_data_get(
            _controller.build.selected_key
        );


    if (!scr_building_data_valid(_data))
        return false;


    var _preview =
        _controller.build.preview;

    var _cell_size =
        global.vtd_level.map.cell_size;

    var _width =
        _data.footprint.width_cells
        * _cell_size;

    var _height =
        _data.footprint.height_cells
        * _cell_size;


    var _color =
        c_red;


    if (_preview.valid)
    {
        _color =
            c_lime;
    }


    draw_set_color(
        _color
    );

    draw_set_alpha(
        0.35
    );

    draw_rectangle(
        _preview.world_x
            - (_width * 0.5),

        _preview.world_y
            - (_height * 0.5),

        _preview.world_x
            + (_width * 0.5),

        _preview.world_y
            + (_height * 0.5),

        true
    );


    draw_set_alpha(
        1
    );

    draw_rectangle(
        _preview.world_x
            - (_width * 0.5),

        _preview.world_y
            - (_height * 0.5),

        _preview.world_x
            + (_width * 0.5),

        _preview.world_y
            + (_height * 0.5),

        false
    );


    draw_set_color(
        c_white
    );


    return true;
}

/// @description Returns whether the selected definition may be placed.

function scr_build_mode_placement_valid(
    _data,
    _cell_x,
    _cell_y
)
{
    if (!scr_building_data_valid(_data))
        return false;


    // Capacity is tested before resources and terrain.

    if (!scr_build_limit_can_place(_data))
        return false;


    if (
        !scr_resource_cost_can_afford(
            _data.economy.cost
        )
    )
    {
        return false;
    }


    switch (_data.identity.type)
    {
        case BuildingType.FOUNDATION:
        {
            return scr_foundation_placement_valid(
                _data,
                _cell_x,
                _cell_y
            );
        }


        case BuildingType.MINER:
        {
            return scr_miner_placement_valid(
                _data,
                _cell_x,
                _cell_y
            );
        }


        default:
        {
            return scr_building_footprint_valid(
                _cell_x,
                _cell_y,
                _data.footprint.width_cells,
                _data.footprint.height_cells
            );
        }
    }
}