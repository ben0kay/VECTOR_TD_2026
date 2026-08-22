/// @description Generic building initialization, footprint, and drawing.


/// @description Converts a cell into its world-centre position.

function scr_building_cell_to_position(
    _cell_x,
    _cell_y
)
{
    var _cell_size =
        global.vtd_level.map.cell_size;


    return
    {
        x:
            (_cell_x * _cell_size)
            + (_cell_size * 0.5),

        y:
            (_cell_y * _cell_size)
            + (_cell_size * 0.5)
    };
}


/// @description Converts a world position into a grid cell.

function scr_building_position_to_cell(
    _world_x,
    _world_y
)
{
    var _cell_size =
        global.vtd_level.map.cell_size;


    return
    {
        x:
            floor(
                _world_x / _cell_size
            ),

        y:
            floor(
                _world_y / _cell_size
            )
    };
}


/// @description Returns whether one cell exists inside the current map.

function scr_building_cell_inside_map(
    _cell_x,
    _cell_y
)
{
    return (
        _cell_x >= 0
        && _cell_y >= 0
        && _cell_x
            < global.vtd_level.map.columns
        && _cell_y
            < global.vtd_level.map.rows
    );
}


/// @description Returns every cell used by a building footprint.

function scr_building_footprint_cells_get(
    _cell_x,
    _cell_y,
    _width_cells,
    _height_cells
)
{
    var _cells =
        [];


    for (
        var _offset_y = 0;
        _offset_y < _height_cells;
        ++_offset_y
    )
    {
        for (
            var _offset_x = 0;
            _offset_x < _width_cells;
            ++_offset_x
        )
        {
            array_push(
                _cells,
                {
                    x:
                        _cell_x
                        + _offset_x,

                    y:
                        _cell_y
                        + _offset_y
                }
            );
        }
    }


    return _cells;
}


/// @description Returns whether a footprint overlaps a protected entity.

function scr_building_footprint_entity_blocked(
    _cells
)
{
    if (!is_array(_cells))
        return true;


    var _cell_size =
        global.vtd_level.map.cell_size;


    for (
        var i = 0;
        i < array_length(_cells);
        ++i
    )
    {
        var _cell =
            _cells[i];

        var _position =
            scr_building_cell_to_position(
                _cell.x,
                _cell.y
            );


        // Prevent placement directly over the CPU.

        var _cpu =
            global.vtd_level.entities.cpu;


        if (instance_exists(_cpu))
        {
            if (
                point_distance(
                    _position.x,
                    _position.y,
                    _cpu.x,
                    _cpu.y
                )
                <= _cpu.visual.radius
                    + (_cell_size * 0.5)
            )
            {
                return true;
            }
        }


        // Prevent placement directly over the player.

        var _player =
            global.vtd_level.entities.player;


        if (instance_exists(_player))
        {
            if (
                point_distance(
                    _position.x,
                    _position.y,
                    _player.x,
                    _player.y
                )
                <= _player.visual.radius
                    + (_cell_size * 0.5)
            )
            {
                return true;
            }
        }
    }


    return false;
}


/// @description Returns whether a footprint can be placed.

function scr_building_footprint_valid(
    _cell_x,
    _cell_y,
    _width_cells,
    _height_cells
)
{
    if (!is_struct(global.vtd_level))
        return false;

    if (!global.vtd_level.navigation.ready)
        return false;


    var _cells =
        scr_building_footprint_cells_get(
            _cell_x,
            _cell_y,
            _width_cells,
            _height_cells
        );


    for (
        var i = 0;
        i < array_length(_cells);
        ++i
    )
    {
        var _cell =
            _cells[i];


        if (
            !scr_building_cell_inside_map(
                _cell.x,
                _cell.y
            )
        )
        {
            return false;
        }


        // A value other than zero means the navigation cell is blocked.

        if (
            mp_grid_get_cell(
                global.vtd_level.navigation
                    .grid_ground,
                _cell.x,
                _cell.y
            )
            != 0
        )
        {
            return false;
        }
    }


    if (
        scr_building_footprint_entity_blocked(
            _cells
        )
    )
    {
        return false;
    }


    return true;
}


/// @description Reserves an instance's footprint on the ground grid.

function scr_building_footprint_reserve(
    _building,
    _cell_x,
    _cell_y
)
{
    if (!instance_exists(_building))
        return false;

    if (_building.footprint.reserved)
        return false;


    if (
        !scr_building_footprint_valid(
            _cell_x,
            _cell_y,
            _building.footprint.width_cells,
            _building.footprint.height_cells
        )
    )
    {
        return false;
    }


    var _cells =
        scr_building_footprint_cells_get(
            _cell_x,
            _cell_y,
            _building.footprint.width_cells,
            _building.footprint.height_cells
        );


    for (
        var i = 0;
        i < array_length(_cells);
        ++i
    )
    {
        var _cell =
            _cells[i];


        mp_grid_add_cell(
            global.vtd_level.navigation
                .grid_ground,
            _cell.x,
            _cell.y
        );
    }


    _building.footprint.origin.x =
        _cell_x;

    _building.footprint.origin.y =
        _cell_y;

    _building.footprint.cells =
        _cells;

    _building.footprint.reserved =
        true;


    global.vtd_level.navigation.revision++;


    return true;
}


/// @description Releases an instance's footprint from the ground grid.

function scr_building_footprint_release(
    _building
)
{
    if (!instance_exists(_building))
        return false;

    if (!_building.footprint.reserved)
        return true;


    // During room shutdown, the level controller may already have destroyed
    // the shared navigation grids.

    if (
        variable_global_exists(
            "vtd_level"
        )
        && is_struct(
            global.vtd_level
        )
        && global.vtd_level
            .navigation.ready
    )
    {
        for (
            var i = 0;
            i < array_length(
                _building.footprint.cells
            );
            ++i
        )
        {
            var _cell =
                _building.footprint.cells[i];


            mp_grid_clear_cell(
                global.vtd_level.navigation
                    .grid_ground,
                _cell.x,
                _cell.y
            );
        }


        global.vtd_level.navigation.revision++;
    }


    _building.footprint.cells =
        [];

    _building.footprint.reserved =
        false;


    return true;
}


/// @description Initializes one generic building parent instance.

function scr_building_initialize(
    _building
)
{
    if (!instance_exists(_building))
        return false;


    if (
        !variable_instance_exists(
            _building,
            "building_key"
        )
    )
    {
        show_debug_message(
            "BUILDING ERROR - building_key was not supplied."
        );

        return false;
    }


    var _data =
        scr_building_data_get(
            _building.building_key
        );


    if (!scr_building_data_valid(_data))
    {
        show_debug_message(
            "BUILDING ERROR - invalid definition: "
            + string(
                _building.building_key
            )
        );

        return false;
    }


    _building.building_data =
        _data;


    _building.BuildingState =
        BuildingState.ACTIVE;


    _building.identity =
    {
        key:
            _data.identity.key,

        name:
            _data.identity.name,

        type:
            _data.identity.type
    };


    _building.visual =
    {
        color:
            _data.visual.color
    };


    _building.vitals =
    {
        hp:
        {
            current:
                _data.vitals.hp_maximum,

            maximum:
                _data.vitals.hp_maximum
        }
    };


    _building.footprint =
    {
        width_cells:
            _data.footprint.width_cells,

        height_cells:
            _data.footprint.height_cells,

        origin:
        {
            x:
                -1,

            y:
                -1
        },

        cells:
            [],

        reserved:
            false
    };


    // The build controller supplies the intended origin cell.

    if (
        !variable_instance_exists(
            _building,
            "placement_cell_x"
        )
        || !variable_instance_exists(
            _building,
            "placement_cell_y"
        )
    )
    {
        show_debug_message(
            "BUILDING ERROR - placement cell was not supplied."
        );

        return false;
    }


    if (
        !scr_building_footprint_reserve(
            _building,
            _building.placement_cell_x,
            _building.placement_cell_y
        )
    )
    {
        show_debug_message(
            "BUILDING ERROR - footprint reservation failed: "
            + _building.identity.key
        );

        return false;
    }


    show_debug_message(
        "BUILDING CREATED: "
        + _building.identity.name
    );


    return true;
}


/// @description Applies damage to one building.

function scr_building_damage(
    _building,
    _damage
)
{
    if (!instance_exists(_building))
        return false;

    if (!is_struct(_damage))
        return false;

    if (
        _building.BuildingState
        == BuildingState.DESTROYED
    )
    {
        return false;
    }


    _building.vitals.hp.current =
        max(
            0,
            _building.vitals.hp.current
            - _damage.amount
        );


    if (_building.vitals.hp.current <= 0)
    {
        _building.BuildingState =
            BuildingState.DESTROYED;

        instance_destroy(
            _building
        );
    }


    return true;
}


/// @description Draws one generic vector building.

function scr_building_draw(_building)
{
    if (!instance_exists(_building))
        return false;


    var _cell_size =
        global.vtd_level.map.cell_size;

    var _width =
        _building.footprint.width_cells
        * _cell_size;

    var _height =
        _building.footprint.height_cells
        * _cell_size;

    var _left =
        _building.x - (_width * 0.5);

    var _top =
        _building.y - (_height * 0.5);

    var _right =
        _building.x + (_width * 0.5);

    var _bottom =
        _building.y + (_height * 0.5);


    draw_set_color(
        _building.visual.color
    );

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    draw_set_alpha(
        0.3
    );

    draw_rectangle(
        _left + 4,
        _top + 4,
        _right - 4,
        _bottom - 4,
        true
    );

    draw_set_alpha(
        1
    );


    // ========================================================================
    // HEALTH BAR
    // ========================================================================

    var _hp_percent =
        clamp(
            _building.vitals.hp.current
            / _building.vitals.hp.maximum,
            0,
            1
        );


    draw_set_color(
        c_dkgray
    );

    draw_rectangle(
        _left,
        _top - 8,
        _right,
        _top - 4,
        false
    );


    draw_set_color(
        c_lime
    );

    draw_rectangle(
        _left,
        _top - 8,
        _left
            + ((_right - _left)
            * _hp_percent),
        _top - 4,
        false
    );


    draw_set_color(
        c_white
    );


    return true;
}


/// @description Releases resources owned by one building.

function scr_building_cleanup(_building)
{
    if (!instance_exists(_building))
        return false;


    scr_building_footprint_release(
        _building
    );


    return true;
}

/// @description Returns the building occupying one grid cell.

function scr_building_at_cell(
    _cell_x,
    _cell_y
)
{
    var _building_count =
        instance_number(
            o_building_par
        );


    for (
        var i = 0;
        i < _building_count;
        ++i
    )
    {
        var _building =
            instance_find(
                o_building_par,
                i
            );


        if (!instance_exists(_building))
            continue;

        if (
            _building.BuildingState
            == BuildingState.DESTROYED
        )
        {
            continue;
        }

        if (!_building.footprint.reserved)
            continue;


        for (
            var j = 0;
            j < array_length(
                _building.footprint.cells
            );
            ++j
        )
        {
            var _cell =
                _building.footprint.cells[j];


            if (
                _cell.x == _cell_x
                && _cell.y == _cell_y
            )
            {
                return _building;
            }
        }
    }


    return noone;
}