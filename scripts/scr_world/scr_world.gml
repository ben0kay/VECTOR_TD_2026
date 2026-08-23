/// @description World-cell storage, terrain placement, and test generation.


/// @description Creates the current level's world-cell grids.

function scr_world_initialize()
{
    if (!is_struct(global.vtd_level))
        return false;


    var _columns = global.vtd_level.map.columns;
    var _rows = global.vtd_level.map.rows;


    global.vtd_level.world =
    {
        ready: false,

        generation:
        {
            style: WorldGenerationStyle.NONE,
            seed: irandom(2147483646)
        },

        grid:
        {
            cell_type: ds_grid_create(_columns, _rows),
            resource_key: ds_grid_create(_columns, _rows)
        }
    };


    ds_grid_clear(
        global.vtd_level.world.grid.cell_type,
        WorldCellType.EMPTY
    );

    ds_grid_clear(
        global.vtd_level.world.grid.resource_key,
        ""
    );


    global.vtd_level.world.ready = true;

    show_debug_message("VECTOR TD 2026 - WORLD GRID INITIALIZED");

    return true;
}


/// @description Returns whether a world cell exists inside the map.

function scr_world_cell_inside(_cell_x, _cell_y)
{
    if (!is_struct(global.vtd_level))
        return false;

    return (
        _cell_x >= 0
        && _cell_y >= 0
        && _cell_x < global.vtd_level.map.columns
        && _cell_y < global.vtd_level.map.rows
    );
}


/// @description Returns the permanent terrain type occupying one cell.

function scr_world_cell_type_get(_cell_x, _cell_y)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return WorldCellType.DEAD;

    if (!global.vtd_level.world.ready)
        return WorldCellType.DEAD;


    return ds_grid_get(
        global.vtd_level.world.grid.cell_type,
        _cell_x,
        _cell_y
    );
}


/// @description Returns the resource key stored in one resource cell.

function scr_world_cell_resource_get(_cell_x, _cell_y)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return "";

    if (!global.vtd_level.world.ready)
        return "";


    return ds_grid_get(
        global.vtd_level.world.grid.resource_key,
        _cell_x,
        _cell_y
    );
}


/// @description Returns whether construction is allowed on a world cell.

function scr_world_cell_buildable(_cell_x, _cell_y)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return false;


    return (
        scr_world_cell_type_get(_cell_x, _cell_y)
        == WorldCellType.EMPTY
    );
}


/// @description Changes one terrain cell and refreshes navigation.

function scr_world_cell_set(
    _cell_x,
    _cell_y,
    _cell_type,
    _resource_key = ""
)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return false;

    if (!global.vtd_level.world.ready)
        return false;


    ds_grid_set(
        global.vtd_level.world.grid.cell_type,
        _cell_x,
        _cell_y,
        _cell_type
    );

    ds_grid_set(
        global.vtd_level.world.grid.resource_key,
        _cell_x,
        _cell_y,
        _resource_key
    );


    if (global.vtd_level.navigation.ready)
    {
        scr_navigation_cell_refresh(
            _cell_x,
            _cell_y
        );

        global.vtd_level.navigation.revision++;
    }


    return true;
}


/// @description Places one permanent dead terrain cell.

function scr_world_dead_cell_place(_cell_x, _cell_y)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return noone;

    if (
        scr_world_cell_type_get(_cell_x, _cell_y)
        != WorldCellType.EMPTY
    )
    {
        return noone;
    }


    var _position = scr_building_cell_to_position(
        _cell_x,
        _cell_y
    );


    if (
        !scr_world_cell_set(
            _cell_x,
            _cell_y,
            WorldCellType.DEAD
        )
    )
    {
        return noone;
    }


    var _dead_cell = instance_create_layer(
        _position.x,
        _position.y,
        "Instances",
        o_dead_cell,
        {
            world_cell_x: _cell_x,
            world_cell_y: _cell_y
        }
    );


    if (!instance_exists(_dead_cell))
    {
        scr_world_cell_set(
            _cell_x,
            _cell_y,
            WorldCellType.EMPTY
        );

        return noone;
    }


    return _dead_cell;
}


/// @description Creates a small temporary rock cluster for foundation testing.

function scr_world_test_cluster_create()
{
    if (!global.vtd_level.world.ready)
        return false;


    var _start_x = floor(global.vtd_level.map.columns * 0.25);
    var _start_y = floor(global.vtd_level.map.rows * 0.25);

    var _pattern =
    [
        [0, 0],
        [1, 0],
        [2, 0],
        [3, 0],

        [0, 1],
        [1, 1],
        [3, 1],

        [0, 2],
        [1, 2],
        [2, 2],
        [3, 2],

        [2, 3]
    ];


    for (var i = 0; i < array_length(_pattern); ++i)
    {
        scr_world_dead_cell_place(
            _start_x + _pattern[i][0],
            _start_y + _pattern[i][1]
        );
    }


    return true;
}


/// @description Releases grids owned by the current world runtime.

function scr_world_cleanup()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(global.vtd_level, "world"))
        return true;

    if (!is_struct(global.vtd_level.world))
        return true;


    var _world = global.vtd_level.world;

    _world.ready = false;


    if (ds_exists(_world.grid.cell_type, ds_type_grid))
        ds_grid_destroy(_world.grid.cell_type);

    if (ds_exists(_world.grid.resource_key, ds_type_grid))
        ds_grid_destroy(_world.grid.resource_key);


    _world.grid.cell_type = -1;
    _world.grid.resource_key = -1;


    return true;
}