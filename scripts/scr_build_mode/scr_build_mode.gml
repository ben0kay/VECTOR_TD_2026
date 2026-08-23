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


    _controller.build.selected_key =
        _building_key;

    global.BuildState =
        BuildState.PLACING;


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


/// @description Creates the selected building at the preview position.

function scr_build_mode_place(_controller)
{
    if (!instance_exists(_controller))
        return noone;


    var _build = _controller.build;
    var _preview = _build.preview;

    if (!_preview.valid)
        return noone;


    var _data = scr_building_data_get(_build.selected_key);

    if (!scr_building_data_valid(_data))
        return noone;


    var _object = noone;

    switch (_data.identity.type)
    {
        case BuildingType.WALL:
            _object = o_wall;
        break;

        case BuildingType.TOWER:
            _object = o_tower;
        break;

        case BuildingType.MINER:
            _object = o_miner;
        break;

        case BuildingType.STORAGE:
            _object = o_storage;
        break;

        case BuildingType.REFINERY:
        {
            // FUTURE:
            // _object = o_refinery;
        }
        break;

        case BuildingType.POWER_GENERATOR:
        {
            // FUTURE:
            // _object = o_power_generator;
        }
        break;

        case BuildingType.POWER_NODE:
        {
            // FUTURE:
            // _object = o_power_node;
        }
        break;

        case BuildingType.SUPPORT:
        {
            // FUTURE:
            // _object = o_support_building;
        }
        break;
    }


    if (_object == noone)
        return noone;


    var _building = instance_create_layer(
        _preview.world_x,
        _preview.world_y,
        "Instances",
        _object,
        {
            building_key: _build.selected_key,
            placement_cell_x: _preview.cell_x,
            placement_cell_y: _preview.cell_y
        }
    );


    if (!instance_exists(_building))
        return noone;


    show_debug_message(
        "BUILD PLACED: "
        + _data.identity.name
    );


    return _building;
}


/// @description Processes build-mode input.

function scr_build_mode_update(_controller)
{
    if (!instance_exists(_controller))
        return false;


    switch (global.BuildState)
    {
        case BuildState.NONE:
        {
            if (keyboard_check_pressed(ord("B")))
                scr_build_mode_begin(_controller, "wall_basic");

            else if (keyboard_check_pressed(ord("T")))
                scr_build_mode_begin(_controller, "tower_basic");

            else if (keyboard_check_pressed(ord("Y")))
                scr_build_mode_begin(_controller, "tower_anti_air");

            else if (keyboard_check_pressed(ord("1")))
                scr_build_mode_begin(_controller, "miner_carbon");

            else if (keyboard_check_pressed(ord("2")))
                scr_build_mode_begin(_controller, "miner_silicon");

            else if (keyboard_check_pressed(ord("3")))
                scr_build_mode_begin(_controller, "miner_copper");

            else if (keyboard_check_pressed(ord("4")))
                scr_build_mode_begin(_controller, "storage_carbon");

            else if (keyboard_check_pressed(ord("5")))
                scr_build_mode_begin(_controller, "storage_silicon");

            else if (keyboard_check_pressed(ord("6")))
                scr_build_mode_begin(_controller, "storage_copper");
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


            if (keyboard_check_pressed(ord("B")))
                scr_build_mode_begin(_controller, "wall_basic");

            else if (keyboard_check_pressed(ord("T")))
                scr_build_mode_begin(_controller, "tower_basic");

            else if (keyboard_check_pressed(ord("Y")))
                scr_build_mode_begin(_controller, "tower_anti_air");

            else if (keyboard_check_pressed(ord("1")))
                scr_build_mode_begin(_controller, "miner_carbon");

            else if (keyboard_check_pressed(ord("2")))
                scr_build_mode_begin(_controller, "miner_silicon");

            else if (keyboard_check_pressed(ord("3")))
                scr_build_mode_begin(_controller, "miner_copper");

            else if (keyboard_check_pressed(ord("4")))
                scr_build_mode_begin(_controller, "storage_carbon");

            else if (keyboard_check_pressed(ord("5")))
                scr_build_mode_begin(_controller, "storage_silicon");

            else if (keyboard_check_pressed(ord("6")))
                scr_build_mode_begin(_controller, "storage_copper");


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

/// @description Returns whether the selected building can occupy a footprint.

function scr_build_mode_placement_valid(
    _data,
    _cell_x,
    _cell_y
)
{
    if (!scr_building_data_valid(_data))
        return false;


    switch (_data.identity.type)
    {
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