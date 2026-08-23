/// @description Core game and level initialization functions.


/// @description Creates the persistent game runtime.

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
        tick:
            0,

        settings:
        {
            view_width:
                1366,

            view_height:
                768,

            grid_cell_size:
                32
        },

        data:
        {
            enemies:
                {},

            buildings:
                {}
        },

        debug:
        {
            enabled:
                true
        }
    };


    // ========================================================================
    // DATA DEFINITIONS
    // ========================================================================

    scr_enemy_data_initialize();
    scr_building_data_initialize();


    // FUTURE:
    // scr_upgrade_data_initialize();
    // scr_resource_data_initialize();
    // scr_level_data_initialize();


    global.GameState =
        GameState.PLAYING;


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


    var _cell_size = global.vtd.settings.grid_cell_size;
    var _columns = ceil(room_width / _cell_size);
    var _rows = ceil(room_height / _cell_size);


    global.vtd_level =
    {
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

            // Terrain and buildings.
            grid_ground: -1,

            // Terrain only. Used by phasing and breach investigation.
            grid_breach: -1,

            // No ordinary obstacles. Used by flying enemies.
            grid_flying: -1
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
            // FUTURE:
            // credits
            // carbon
            // copper
            // silicon
        },

        waves:
        {
            // FUTURE:
            // baseline spawning
            // clusters
            // major waves
            // milestones
        },

        power:
        {
            // FUTURE:
            // local power networks
            // generators
            // nodes
            // consumers
            // batteries
        }
    };


    // ========================================================================
    // NAVIGATION
    // ========================================================================

    global.vtd_level.navigation.grid_ground = mp_grid_create(
        0,
        0,
        _columns,
        _rows,
        _cell_size,
        _cell_size
    );

    global.vtd_level.navigation.grid_breach = mp_grid_create(
        0,
        0,
        _columns,
        _rows,
        _cell_size,
        _cell_size
    );

    global.vtd_level.navigation.grid_flying = mp_grid_create(
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
        show_debug_message("LEVEL ERROR - world initialization failed.");
        return false;
    }


    // Temporary foundation test. Replace this with the selected level's
    // generator when CLUSTERS and CAVERNS are implemented.

    scr_world_test_cluster_create();


    global.LevelState = LevelState.PLAYING;

    show_debug_message("VECTOR TD 2026 - LEVEL INITIALIZED");

    return true;
}


/// @description Releases runtime data owned by the current level.

function scr_level_cleanup()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;


    global.LevelState = LevelState.EXITING;


    scr_world_cleanup();


    var _navigation = global.vtd_level.navigation;

    if (_navigation.ready)
    {
        if (_navigation.grid_ground >= 0)
            mp_grid_destroy(_navigation.grid_ground);

        if (_navigation.grid_breach >= 0)
            mp_grid_destroy(_navigation.grid_breach);

        if (_navigation.grid_flying >= 0)
            mp_grid_destroy(_navigation.grid_flying);


        _navigation.grid_ground = -1;
        _navigation.grid_breach = -1;
        _navigation.grid_flying = -1;
        _navigation.ready = false;
    }


    global.vtd_level = undefined;

    show_debug_message("VECTOR TD 2026 - LEVEL CLEANED UP");

    return true;
}