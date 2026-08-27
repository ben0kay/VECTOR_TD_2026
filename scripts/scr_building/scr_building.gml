/// @description Generic building initialization, footprint, and drawing.

/// @description Initializes one generic building runtime.

function scr_building_initialize(_building)
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
            + string(_building.building_key)
        );

        return false;
    }


    _building.building_data =
        _data;


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


    _building.footprint =
    {
        width_cells:
            _data.footprint.width_cells,

        height_cells:
            _data.footprint.height_cells,

        origin:
        {
            x: -1,
            y: -1
        },

        cells: [],
        reserved: false
    };


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


    // ========================================================================
	// FOUNDATION SUPPORT
	// ========================================================================

	var _foundation_coverage =
	    scr_foundation_building_coverage_get(
	        _building
	    );

	var _foundation_hp_multiplier =
	    scr_foundation_building_modifier_get(
	        _building,
	        "building_hp"
	    );

	var _foundation_fire_rate_multiplier =
	    scr_foundation_building_modifier_get(
	        _building,
	        "tower_fire_rate"
	    );


	var _hp_maximum =
	    _data.vitals.hp_maximum
	    * _foundation_hp_multiplier;


	_building.foundation =
	{
	    coverage:
	        _foundation_coverage,

	    fully_supported:
	        _foundation_coverage >= 1,

	    hp_multiplier:
	        _foundation_hp_multiplier,

	    tower_fire_rate_multiplier:
	        _foundation_fire_rate_multiplier
	};


    // ========================================================================
	// VITALS
	// ========================================================================

	var _initial_hp =
	    max(
	        1,
	        _hp_maximum * 0.1
	    );


	// Buildings default to shield capacity equal to 25% maximum HP.
	// Individual definitions may override this, including setting it to zero.

	var _shield_maximum =
	    _hp_maximum * 0.25;


	if (
	    variable_struct_exists(
	        _data.vitals,
	        "shield_maximum"
	    )
	)
	{
	    _shield_maximum =
	        max(
	            0,
	            _data.vitals.shield_maximum
	        );
	}


	_building.vitals =
	{
	    hp:
	    {
	        current:
	            _initial_hp,

	        maximum:
	            _hp_maximum
	    },

	    shield:
	    {
	        enabled: false,

	        current: 0,
	        maximum: _shield_maximum,

	        source: noone,

	        field_remaining_seconds: 0,

	        regeneration_delay_seconds: 3,
	        regeneration_delay_remaining: 0,

	        hit_flash: 0,

	        color:
	            make_color_rgb(
	                90,
	                180,
	                255
	            )
	    }
	};


    // ========================================================================
    // CONSTRUCTION
    // ========================================================================

    var _construction_seconds =
        max(
            0,
            _data.construction.time_seconds
        );


    _building.construction =
    {
        progress_seconds:
            0,

        duration_seconds:
            _construction_seconds,

        percent:
            0,

        hp_remaining:
            max(
                0,
                _hp_maximum
                - _initial_hp
            ),

        complete:
            false
    };


    _building.BuildingState =
        BuildingState.CONSTRUCTING;


    // ========================================================================
    // ENERGY
    // ========================================================================

    _building.energy =
        scr_energy_runtime_create(
            _data
        );


    if (!is_struct(_building.energy))
    {
        show_debug_message(
            "BUILDING ERROR - energy runtime failed: "
            + _building.identity.key
        );

        return false;
    }


    // ========================================================================
    // BUILD CAPACITY
    // ========================================================================
    //
    // Capacity is reserved immediately. An unfinished building therefore
    // cannot be used to bypass its category limit.

    if (!scr_build_limit_register(_building))
    {
        show_debug_message(
            "BUILDING ERROR - capacity registration failed: "
            + _building.identity.key
        );

        return false;
    }


    // ========================================================================
    // INSTANT CONSTRUCTION
    // ========================================================================

    if (_construction_seconds <= 0)
    {
        scr_building_construction_complete(
            _building
        );
    }


    show_debug_message(
        "BUILDING CREATED: "
        + _building.identity.name
    );


    return true;
}

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

    if (!global.vtd_level.world.ready)
        return false;


    var _cells = scr_building_footprint_cells_get(
        _cell_x,
        _cell_y,
        _width_cells,
        _height_cells
    );


    for (var i = 0; i < array_length(_cells); ++i)
    {
        var _cell = _cells[i];


        if (!scr_building_cell_inside_map(_cell.x, _cell.y))
            return false;


        // Permanent terrain and resources reject construction.

        if (!scr_world_cell_buildable(_cell.x, _cell.y))
            return false;


        // Buildings and other temporary ground blockers also reject it.

        if (
            mp_grid_get_cell(
                global.vtd_level.navigation.grid_ground,
                _cell.x,
                _cell.y
            )
            != 0
        )
        {
            return false;
        }
    }


    if (scr_building_footprint_entity_blocked(_cells))
        return false;


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


    var _valid = false;


    switch (_building.identity.type)
    {
        case BuildingType.MINER:
        {
            _valid = scr_miner_placement_valid(
                _building.building_data,
                _cell_x,
                _cell_y
            );
        }
        break;


        default:
        {
            _valid = scr_building_footprint_valid(
                _cell_x,
                _cell_y,
                _building.footprint.width_cells,
                _building.footprint.height_cells
            );
        }
        break;
    }


    if (!_valid)
        return false;


    var _cells = scr_building_footprint_cells_get(
        _cell_x,
        _cell_y,
        _building.footprint.width_cells,
        _building.footprint.height_cells
    );


    for (var i = 0; i < array_length(_cells); ++i)
    {
        var _cell = _cells[i];

        mp_grid_add_cell(
            global.vtd_level.navigation.grid_ground,
            _cell.x,
            _cell.y
        );
    }


    _building.footprint.origin.x = _cell_x;
    _building.footprint.origin.y = _cell_y;
    _building.footprint.cells = _cells;
    _building.footprint.reserved = true;


    global.vtd_level.navigation.revision++;


    return true;
}


/// @description Releases an instance's footprint from the ground grid.

function scr_building_footprint_release(_building)
{
    if (!instance_exists(_building))
        return false;

    if (!_building.footprint.reserved)
        return true;


    var _released_cells = _building.footprint.cells;


    // Mark the building unreserved before refreshing. This prevents
    // scr_building_at_cell() from finding the building being released.

    _building.footprint.cells = [];
    _building.footprint.reserved = false;


    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && global.vtd_level.navigation.ready
    )
    {
        for (var i = 0; i < array_length(_released_cells); ++i)
        {
            var _cell = _released_cells[i];

            scr_navigation_cell_refresh(
                _cell.x,
                _cell.y
            );
        }


        global.vtd_level.navigation.revision++;
    }


    return true;
}

/// @description Applies shield and health damage to one building.

function scr_building_damage(
    _building,
    _damage
)
{
    if (!instance_exists(_building))
        return false;

    if (!is_struct(_damage))
        return false;

    if (_building.BuildingState == BuildingState.DESTROYED)
        return false;

    if (_damage.amount <= 0)
        return false;


    var _remaining_damage =
        _damage.amount;

    var _shield =
        _building.vitals.shield;


    // ========================================================================
    // FIELD SHIELD
    // ========================================================================

    if (
        scr_building_shield_active(_building)
        && _shield.current > 0
    )
    {
        var _shield_damage =
            min(
                _shield.current,
                _remaining_damage
            );


        _shield.current -=
            _shield_damage;

        _remaining_damage -=
            _shield_damage;

        _shield.hit_flash = 1;

        _shield.regeneration_delay_remaining =
            _shield.regeneration_delay_seconds;


        if (_shield.current <= 0)
        {
            _shield.current = 0;

            scr_effect_shockwave_create(
                _building.x,
                _building.y,
                max(
                    _building.footprint.width_cells,
                    _building.footprint.height_cells
                )
                * global.vtd_level.map.cell_size,
                _shield.color,
                EnemyMovementLayer.GROUND
            );

            // The field remains connected and may regenerate later.
        }
    }


    // ========================================================================
    // STRUCTURAL HEALTH
    // ========================================================================

    if (_remaining_damage > 0)
    {
        _building.vitals.hp.current =
            max(
                0,
                _building.vitals.hp.current
                - _remaining_damage
            );

        _shield.regeneration_delay_remaining =
            _shield.regeneration_delay_seconds;
    }


    if (_building.vitals.hp.current <= 0)
    {
        _building.BuildingState =
            BuildingState.DESTROYED;

        instance_destroy(_building);
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
        true
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
	// CONSTRUCTION OVERLAY
	// ========================================================================

	if (_building.BuildingState == BuildingState.CONSTRUCTING)
	{
	    var _construction_percent =
	        _building.construction.percent;

	    var _scan_y =
	        lerp(
	            _bottom,
	            _top,
	            _construction_percent
	        );


	    // Unfinished upper section.

	    draw_set_color(c_black);
	    draw_set_alpha(0.65);

	    draw_rectangle(
	        _left,
	        _top,
	        _right,
	        _scan_y,
	        true
	    );


	    // Moving vector construction scan.

	    draw_set_color(c_aqua);
	    draw_set_alpha(0.9);

	    draw_line(
	        _left,
	        _scan_y,
	        _right,
	        _scan_y
	    );


	    // Construction progress bar.

	    draw_set_alpha(1);
	    draw_set_color(c_dkgray);

	    draw_rectangle(
	        _left,
	        _bottom + 4,
	        _right,
	        _bottom + 8,
	        false
	    );

	    draw_set_color(c_aqua);

	    draw_rectangle(
	        _left,
	        _bottom + 4,
	        _left
	        + ((_right - _left)
	        * _construction_percent),
	        _bottom + 8,
	        false
	    );


	    draw_set_alpha(1);
	}


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


/// @description Returns the initialized building occupying one grid cell.

function scr_building_at_cell(_cell_x, _cell_y)
{
    var _building_count =
        instance_number(
            o_building_par
        );


    for (var i = 0; i < _building_count; ++i)
    {
        var _building =
            instance_find(
                o_building_par,
                i
            );

        if (!instance_exists(_building))
            continue;


        // A building is visible to instance searches while its Create event
        // is still running. Ignore it until its runtime is initialized.

        if (!variable_instance_exists(_building, "BuildingState"))
            continue;

        if (!variable_instance_exists(_building, "footprint"))
            continue;

        if (!is_struct(_building.footprint))
            continue;


        if (_building.BuildingState == BuildingState.DESTROYED)
            continue;

        if (!_building.footprint.reserved)
            continue;

        if (!is_array(_building.footprint.cells))
            continue;


        for (
            var cell_index = 0;
            cell_index < array_length(_building.footprint.cells);
            ++cell_index
        )
        {
            var _cell =
                _building.footprint.cells[cell_index];

            if (!is_struct(_cell))
                continue;

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

/// @description Completes construction and activates one building.

function scr_building_construction_complete(_building)
{
    if (!instance_exists(_building))
        return false;


    _building.vitals.hp.current =
        min(
            _building.vitals.hp.maximum,
            _building.vitals.hp.current
            + _building.construction.hp_remaining
        );


    _building.construction.progress_seconds =
        _building.construction.duration_seconds;

    _building.construction.percent =
        1;

    _building.construction.hp_remaining =
        0;

    _building.construction.complete =
        true;


    _building.BuildingState =
        BuildingState.ACTIVE;


    if (_building.energy.participates)
    {
        _building.energy.registration_pending =
            true;

        scr_energy_topology_dirty();
    }


    // A future capacity hub only applies its bonus after construction.

    scr_build_limit_hub_activate(
        _building
    );


    // ========================================================================
    // COMPLETION FEEDBACK
    // ========================================================================

    var _completion_color =
        c_aqua;

    if (
        is_struct(_building.visual)
        && variable_struct_exists(
            _building.visual,
            "color"
        )
    )
    {
        _completion_color =
            _building.visual.color;
    }


    scr_particles_construction_complete(
        _building.x,
        _building.y,
        _completion_color
    );


    show_debug_message(
        "BUILDING ACTIVE: "
        + _building.identity.name
    );


    return true;
}


/// @description Updates one generic building construction lifecycle.

function scr_building_update(_building)
{
    if (!instance_exists(_building))
        return false;


    switch (_building.BuildingState)
    {
        case BuildingState.CONSTRUCTING:
        {
            var _fps =
                max(
                    1,
                    game_get_speed(gamespeed_fps)
                );

            var _delta =
                1 / _fps;

            var _previous_percent =
                _building.construction.percent;


            _building.construction.progress_seconds =
                min(
                    _building.construction.duration_seconds,
                    _building.construction.progress_seconds + _delta
                );

            _building.construction.percent =
                clamp(
                    _building.construction.progress_seconds
                    / max(
                        0.001,
                        _building.construction.duration_seconds
                    ),
                    0,
                    1
                );


            var _percent_added =
                _building.construction.percent
                - _previous_percent;

            var _hp_added =
                _building.construction.hp_remaining
                * _percent_added
                / max(
                    0.001,
                    1 - _previous_percent
                );


            _building.vitals.hp.current =
                min(
                    _building.vitals.hp.maximum,
                    _building.vitals.hp.current + _hp_added
                );

            _building.construction.hp_remaining =
                max(
                    0,
                    _building.construction.hp_remaining - _hp_added
                );


            if (_building.construction.percent >= 1)
            {
                scr_building_construction_complete(
                    _building
                );
            }
        }
        break;


        case BuildingState.ACTIVE:
        {
            // Category objects run their own active behaviour.
        }
        break;


        case BuildingState.DISABLED:
        {
            // FUTURE:
            // manual shutdown
            // power shortage
            // EMP effects
        }
        break;


        case BuildingState.DESTROYED:
        {
            // Destruction cleanup belongs to scr_building_damage().
        }
        break;
    }


    return true;
}

/// @description Releases resources owned by one building.

function scr_building_cleanup(_building)
{
    if (!instance_exists(_building))
        return false;


    // Release used capacity and any bonus supplied by a hub.

    scr_build_limit_unregister(
        _building
    );


    if (
        variable_instance_exists(
            _building,
            "energy"
        )
        && is_struct(_building.energy)
        && _building.energy.participates
    )
    {
        scr_energy_topology_dirty();
    }


    scr_building_footprint_release(
        _building
    );


    return true;
}

