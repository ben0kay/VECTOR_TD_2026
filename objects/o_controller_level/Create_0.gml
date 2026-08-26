/// @description Creates the runtime belonging to the current level.

function scr_level_initialize()
{
    global.LevelState = LevelState.INITIALIZING;
    global.CameraState = CameraState.FOLLOW_PLAYER;


    var _world_key = "world_test";

    var _world_data =
        scr_world_data_get(_world_key);

    if (!scr_world_data_valid(_world_data))
    {
        show_debug_message(
            "LEVEL ERROR - invalid world definition: "
            + _world_key
        );

        return false;
    }


    var _cell_size =
        global.vtd.settings.grid_cell_size;

    var _columns =
        ceil(room_width / _cell_size);

    var _rows =
        ceil(room_height / _cell_size);


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


        // ====================================================================
        // SPATIAL COLLISION
        // ====================================================================
        //
        // This exists only while a gameplay level is active.
        //
        // Smaller cells:
        // - fewer enemies checked by each projectile
        // - more sectors
        // - more frequent enemy sector changes
        //
        // Larger cells:
        // - more enemies checked by each projectile
        // - fewer sectors
        // - less frequent enemy sector changes

        spatial_collision:
        {
            settings:
            {
                cell_size: 256,

                // Starting safety radius before enemies register.
                // Runtime automatically increases this for larger enemies.

                initial_enemy_radius: 32,

                // Extra safety padding around projectile queries.

                query_padding: 4,

                // Reserved for a future sector debug overlay.

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


    global.vtd_level.navigation.ready =
        true;


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
    // SPATIAL COLLISION
    // ========================================================================

    if (!scr_spatial_collision_initialize())
    {
        show_debug_message(
            "LEVEL ERROR - spatial collision initialization failed."
        );

        return false;
    }


    global.LevelState =
        LevelState.PLAYING;


    show_debug_message(
        "VECTOR TD 2026 - LEVEL INITIALIZED"
    );


    return true;
}