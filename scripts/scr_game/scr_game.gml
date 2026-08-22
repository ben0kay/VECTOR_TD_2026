/// @description Core game and level initialization functions.


/// @description Creates the persistent game runtime.

function scr_game_initialize()
{
    global.vtd =
    {
        tick:
            0,

        GameState:
            GameState.BOOT,

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


    // Enemy and building definitions will be registered here later.
    //
    // FUTURE:
    // scr_enemy_data_initialize();
    // scr_building_data_initialize();


    global.vtd.GameState =
        GameState.PLAYING;

    show_debug_message(
        "VECTOR TD 2026 - GAME INITIALIZED"
    );

    return true;
}


/// @description Creates the runtime belonging to the current level.

function scr_level_initialize()
{
    var _cell_size =
        global.vtd.settings.grid_cell_size;

    var _columns =
        ceil(
            room_width / _cell_size
        );

    var _rows =
        ceil(
            room_height / _cell_size
        );


    global.vtd_level =
    {
        state:
            LevelState.INITIALIZING,

        time:
        {
            frames:
                0,

            seconds:
                0
        },

        map:
        {
            width:
                room_width,

            height:
                room_height,

            cell_size:
                _cell_size,

            columns:
                _columns,

            rows:
                _rows
        },

        navigation:
        {
            ready:
                false,

            revision:
                0,

            // Normal ground enemies use this grid.
            grid_ground:
                -1,

            // Breaching enemies use this to discover routes through
            // buildings while still respecting terrain.
            grid_breach:
                -1
        },

        entities:
        {
            player:
                noone,

            cpu:
                noone
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

    global.vtd_level.navigation.ready =
        true;

    global.vtd_level.state =
        LevelState.PLAYING;


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


    var _navigation =
        global.vtd_level.navigation;


    if (_navigation.ready)
    {
        mp_grid_destroy(
            _navigation.grid_ground
        );

        mp_grid_destroy(
            _navigation.grid_breach
        );

        _navigation.grid_ground =
            -1;

        _navigation.grid_breach =
            -1;

        _navigation.ready =
            false;
    }


    global.vtd_level.state =
        LevelState.EXITING;

    global.vtd_level =
        undefined;


    show_debug_message(
        "VECTOR TD 2026 - LEVEL CLEANED UP"
    );

    return true;
}