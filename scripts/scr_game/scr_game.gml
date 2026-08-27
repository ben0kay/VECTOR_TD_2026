/// @description Core game and level initialization functions.

/// @description Creates the persistent game runtime.

function scr_game_initialize()
{
    global.GameState =
        GameState.BOOT;

    global.LevelState =
        LevelState.EXITING;

    global.CameraState =
        CameraState.FOLLOW_PLAYER;

    global.BuildState =
        BuildState.NONE;


    global.vtd =
    {
        tick: 0,

        settings:
        {
            // Shared internal resolution used by menus, gameplay and HUD.

            view_width: 1920,
            view_height: 1080,

            grid_cell_size: 32
        },

        data:
        {
            enemies: {},
            buildings: {},
            resources: {},
            recipes: {},
            worlds: {}
        },

        debug:
        {
            enabled: true
        },

        // FUTURE:
        // profile
        // save data
        // persistent upgrades
        // campaign progress
        // display and graphics settings
		
		profile: undefined,
    };


    // ========================================================================
    // DATA DEFINITIONS
    // ========================================================================

    scr_enemy_data_initialize();
    scr_building_data_initialize();
    scr_tower_data_initialize();
    scr_building_hub_data_initialize();

    scr_build_limit_data_defaults_apply();
    scr_energy_consumer_data_defaults_apply();

    scr_resource_data_initialize();
    scr_recipe_data_initialize();
    scr_world_data_initialize();
    scr_particles_initialize();


    // FUTURE:
    // scr_upgrade_data_initialize();
    // scr_research_data_initialize();
    // scr_boss_data_initialize();
    // scr_profile_system_initialize();

    show_debug_message(
        "VECTOR TD 2026 - GAME INITIALIZED"
    );


    return true;
}

/// @description Creates the runtime belonging to the current level.

function scr_level_initialize()
{
    global.LevelState = LevelState.INITIALIZING;
    global.CameraState = CameraState.FOLLOW_PLAYER;


    var _world_key = "world_test";

    var _world_data =
        scr_world_data_get(
            _world_key
        );

    if (!scr_world_data_valid(_world_data))
    {
        show_debug_message(
            "LEVEL ERROR - invalid world definition: "
            + _world_key
        );

        return false;
    }


    var _cell_size = global.vtd.settings.grid_cell_size;
    var _columns = ceil(room_width / _cell_size);
    var _rows = ceil(room_height / _cell_size);


    global.vtd_level =
    {
        identity:
        {
            world_key: _world_key
        },

        time:
        {
            frames: 0,
            seconds: 0
        },

        map:
        {
            width: room_width,
            height: room_height,
            cell_size: _cell_size,
            columns: _columns,
            rows: _rows
        },

        world: undefined,

        navigation:
        {
            ready: false,
            revision: 0,
            grid_ground: -1,
            grid_breach: -1,
            grid_flying: -1
        },


		spatial_collision:
		{
		    settings:
		    {
		        // Main spatial-grid tuning value.
		        cell_size: 256,

		        // Starting safety radius before enemies register.
		        // This increases automatically when larger enemies appear.
		        initial_enemy_radius: 32,

		        // Extra coverage used by spatial queries.
		        query_padding: 4,

		        debug_draw: false
		    },

		    runtime:
		    {
		        ready: false,

		        columns: 0,
		        rows: 0,

		        enemy_grid: -1,

		        maximum_enemy_radius: 32
		    }
		},
		
		
        entities:
        {
            player: noone,
            camera: noone,
            cpu: noone,
            build_controller: noone
        },

        resources:
        {
            entries: {}
        },

		upgrades:
		{
		    level:
		        scr_upgrade_level_runtime_create()
		},

        waves:
        {
            // FUTURE:
            // baseline spawning
            // clusters
            // major waves
            // milestones
        },

        build_limits:
            undefined,

        energy:
        {
            controller: noone,
            dirty: true,
            revision: 0,
            networks: [],

            overlay:
            {
                mode: EnergyOverlayMode.OFF
            },

            totals:
            {
                generation: 0,
                demand: 0,
                net: 0,
                stored: 0,
                storage_maximum: 0,
                deficient_networks: 0
            }
        }
    };


    // ========================================================================
    // BUILD CAPACITY
    // ========================================================================

    if (!scr_build_limits_initialize(_world_data))
    {
        show_debug_message(
            "LEVEL ERROR - build-limit initialization failed."
        );

        return false;
    }


    // ========================================================================
    // LEVEL ECONOMY
    // ========================================================================

    if (!scr_resource_level_initialize(_world_data))
    {
        show_debug_message(
            "LEVEL ERROR - resource initialization failed."
        );

        return false;
    }


    // ========================================================================
    // NAVIGATION
    // ========================================================================

    global.vtd_level.navigation.grid_ground =
        mp_grid_create(
            0,
            0,
            _columns,
            _rows,
            _cell_size,
            _cell_size
        );

    global.vtd_level.navigation.grid_breach =
        mp_grid_create(
            0,
            0,
            _columns,
            _rows,
            _cell_size,
            _cell_size
        );

    global.vtd_level.navigation.grid_flying =
        mp_grid_create(
            0,
            0,
            _columns,
            _rows,
            _cell_size,
            _cell_size
        );


    global.vtd_level.navigation.ready = true;


    // ========================================================================
    // WORLD
    // ========================================================================

    if (!scr_world_initialize())
    {
        show_debug_message(
            "LEVEL ERROR - world initialization failed."
        );

        return false;
    }


    if (!scr_world_generate(_world_key))
    {
        show_debug_message(
            "LEVEL ERROR - world generation failed."
        );

        return false;
    }
	
	// ========================================================================
	// ENEMY SPATIAL COLLISION
	// ========================================================================

	if (!scr_spatial_collision_initialize())
	{
	    show_debug_message(
	        "LEVEL ERROR - spatial collision initialization failed."
	    );

	    return false;
	}


    global.LevelState = LevelState.CHASSIS_SELECT;


    show_debug_message(
        "VECTOR TD 2026 - LEVEL INITIALIZED"
    );


    return true;
}

/// @description Releases runtime data owned by the current level.

function scr_level_cleanup()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;


    global.LevelState =
        LevelState.EXITING;


    // Release level-owned runtime grids.

    scr_spatial_collision_cleanup();
    scr_world_cleanup();


    var _navigation =
        global.vtd_level.navigation;


    if (_navigation.ready)
    {
        if (_navigation.grid_ground >= 0)
        {
            mp_grid_destroy(
                _navigation.grid_ground
            );
        }

        if (_navigation.grid_breach >= 0)
        {
            mp_grid_destroy(
                _navigation.grid_breach
            );
        }

        if (_navigation.grid_flying >= 0)
        {
            mp_grid_destroy(
                _navigation.grid_flying
            );
        }


        _navigation.grid_ground =
            -1;

        _navigation.grid_breach =
            -1;

        _navigation.grid_flying =
            -1;

        _navigation.ready =
            false;
    }


    global.vtd_level =
        undefined;


    show_debug_message(
        "VECTOR TD 2026 - LEVEL CLEANED UP"
    );


    return true;
}
