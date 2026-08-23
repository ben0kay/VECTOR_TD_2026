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

/// @description Returns whether generation may place terrain in one cell.

function scr_world_generation_cell_allowed(
    _cell_x,
    _cell_y,
    _generation
)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return false;


    var _border = _generation.border_clearance_cells;

    if (
        _cell_x < _border
        || _cell_y < _border
        || _cell_x >= global.vtd_level.map.columns - _border
        || _cell_y >= global.vtd_level.map.rows - _border
    )
    {
        return false;
    }


    var _center_x = global.vtd_level.map.columns * 0.5;
    var _center_y = global.vtd_level.map.rows * 0.5;

    if (
        point_distance(
            _cell_x,
            _cell_y,
            _center_x,
            _center_y
        )
        < _generation.safe_radius_cells
    )
    {
        return false;
    }


    return (
        scr_world_cell_type_get(_cell_x, _cell_y)
        == WorldCellType.EMPTY
    );
}


/// @description Chooses separated cluster seed positions.

function scr_world_cluster_seeds_create(_generation)
{
    var _settings = _generation.clusters;
    var _target_count = irandom_range(
        _settings.count_min,
        _settings.count_max
    );

    var _seeds = [];
    var _attempts = 0;


    while (
        array_length(_seeds) < _target_count
        && _attempts < _settings.maximum_seed_attempts
    )
    {
        _attempts++;


        var _cell_x = irandom(
            global.vtd_level.map.columns - 1
        );

        var _cell_y = irandom(
            global.vtd_level.map.rows - 1
        );


        if (
            !scr_world_generation_cell_allowed(
                _cell_x,
                _cell_y,
                _generation
            )
        )
        {
            continue;
        }


        var _too_close = false;

        for (var i = 0; i < array_length(_seeds); ++i)
        {
            var _seed = _seeds[i];

            if (
                point_distance(
                    _cell_x,
                    _cell_y,
                    _seed.x,
                    _seed.y
                )
                < _settings.minimum_distance_cells
            )
            {
                _too_close = true;
                break;
            }
        }


        if (_too_close)
            continue;


        array_push(
            _seeds,
            {
                x: _cell_x,
                y: _cell_y
            }
        );
    }


    return _seeds;
}


/// @description Grows one irregular rock cluster from a seed.

function scr_world_cluster_grow(
    _seed_x,
    _seed_y,
    _target_size,
    _generation
)
{
    var _settings = _generation.clusters;

    var _open =
    [
        {
            x: _seed_x,
            y: _seed_y
        }
    ];

    var _placed = 0;

    var _directions =
    [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1]
    ];


    while (
        array_length(_open) > 0
        && _placed < _target_size
    )
    {
        var _index = irandom(array_length(_open) - 1);
        var _cell = _open[_index];

        array_delete(_open, _index, 1);


        if (
            !scr_world_generation_cell_allowed(
                _cell.x,
                _cell.y,
                _generation
            )
        )
        {
            continue;
        }


        // Generation writes the virtual blueprint directly.
        // Navigation and objects are created later in one realization pass.

        ds_grid_set(
            global.vtd_level.world.grid.cell_type,
            _cell.x,
            _cell.y,
            WorldCellType.DEAD
        );

        _placed++;


        for (var i = 0; i < array_length(_directions); ++i)
        {
            if (random(1) > _settings.growth_chance)
                continue;


            var _next_x =
                _cell.x + _directions[i][0];

            var _next_y =
                _cell.y + _directions[i][1];


            if (
                !scr_world_generation_cell_allowed(
                    _next_x,
                    _next_y,
                    _generation
                )
            )
            {
                continue;
            }


            array_push(
                _open,
                {
                    x: _next_x,
                    y: _next_y
                }
            );
        }
    }


    return _placed;
}


/// @description Realizes the completed world blueprint as terrain and navigation.

function scr_world_blueprint_realize()
{
    if (!global.vtd_level.world.ready)
        return false;


    var _columns = global.vtd_level.map.columns;
    var _rows = global.vtd_level.map.rows;
    var _placed = 0;


    for (var _cell_x = 0; _cell_x < _columns; ++_cell_x)
    {
        for (var _cell_y = 0; _cell_y < _rows; ++_cell_y)
        {
            var _cell_type = scr_world_cell_type_get(
                _cell_x,
                _cell_y
            );


            switch (_cell_type)
            {
                case WorldCellType.DEAD:
                {
                    var _position = scr_building_cell_to_position(
                        _cell_x,
                        _cell_y
                    );


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
                        show_debug_message(
                            "WORLD ERROR - dead-cell realization failed."
                        );

                        return false;
                    }


                    mp_grid_add_cell(
                        global.vtd_level.navigation.grid_ground,
                        _cell_x,
                        _cell_y
                    );

                    mp_grid_add_cell(
                        global.vtd_level.navigation.grid_breach,
                        _cell_x,
                        _cell_y
                    );

                    _placed++;
                }
                break;


                case WorldCellType.RESOURCE:
                {
                    // FUTURE:
                    // Create the appropriate resource-node representation.
                    // Resource terrain will also block ground and breach grids.
                }
                break;
            }
        }
    }


    global.vtd_level.navigation.revision++;


    show_debug_message(
        "WORLD TERRAIN REALIZED: "
        + string(_placed)
        + " DEAD CELLS"
    );


    return true;
}


/// @description Generates one cluster-style world blueprint.

function scr_world_clusters_generate(_generation)
{
    var _settings = _generation.clusters;
    var _seeds = scr_world_cluster_seeds_create(_generation);


    for (var i = 0; i < array_length(_seeds); ++i)
    {
        var _seed = _seeds[i];

        var _size = irandom_range(
            _settings.size_min,
            _settings.size_max
        );


        scr_world_cluster_grow(
            _seed.x,
            _seed.y,
            _size,
            _generation
        );
    }


    return true;
}


/// @description Generates and realizes one data-driven world.

function scr_world_generate(_world_key)
{
    if (!global.vtd_level.world.ready)
        return false;


    var _data = scr_world_data_get(_world_key);

    if (!scr_world_data_valid(_data))
        return false;


    var _generation = _data.generation;
    var _previous_seed = random_get_seed();

    var _seed = _generation.seed;

    if (_seed < 0)
        _seed = irandom(2147483646);


    random_set_seed(_seed);


    global.vtd_level.world.generation =
    {
        key: _data.identity.key,
        style: _generation.style,
        seed: _seed
    };


    var _generated = false;


    switch (_generation.style)
    {
        case WorldGenerationStyle.NONE:
        {
            _generated = true;
        }
        break;


        case WorldGenerationStyle.CLUSTERS:
        {
            _generated = scr_world_clusters_generate(
                _generation
            );
        }
        break;


        case WorldGenerationStyle.CAVERNS:
        {
            // FUTURE:
            // _generated = scr_world_caverns_generate(_generation);
            _generated = false;
        }
        break;
    }


    random_set_seed(_previous_seed);


    if (!_generated)
    {
        show_debug_message(
            "WORLD ERROR - generation failed: "
            + _world_key
        );

        return false;
    }


    if (!scr_world_blueprint_realize())
        return false;


    show_debug_message(
        "WORLD GENERATED: "
        + _data.identity.name
        + " | SEED "
        + string(_seed)
    );


    return true;
}