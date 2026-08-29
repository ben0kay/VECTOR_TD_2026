/// @description Reveals a circular area in the fog grids.

function scr_fog_reveal_circle(
    _fog_controller,
    _world_x,
    _world_y,
    _world_radius
)
{
    if (!instance_exists(_fog_controller))
        return false;


    var _fog = _fog_controller.fog;

    var _cell_x =
        floor(_world_x / _fog.cell_size);

    var _cell_y =
        floor(_world_y / _fog.cell_size);

    var _cell_radius =
        max(
            1,
            ceil(_world_radius / _fog.cell_size)
        );


    ds_grid_set_disk(
        _fog.visible_grid,
        _cell_x,
        _cell_y,
        _cell_radius,
        1
    );

    ds_grid_set_disk(
        _fog.explored_grid,
        _cell_x,
        _cell_y,
        _cell_radius,
        1
    );


    return true;
}


/// @description Returns the current vision range of a friendly instance.

function scr_fog_revealer_range_get(_instance)
{
    if (!instance_exists(_instance))
        return 0;


    if (
        variable_instance_exists(_instance, "vision")
        && is_struct(_instance.vision)
        && variable_struct_exists(_instance.vision, "range")
    )
    {
        return max(0, _instance.vision.range);
    }


    switch (_instance.object_index)
    {
        case o_player:
            return 480;

        case o_cpu:
            return 420;

        case o_tower:
        {
            if (
                variable_instance_exists(_instance, "combat")
                && is_struct(_instance.combat)
            )
            {
                return _instance.combat.range;
            }

            return 280;
        }

        case o_miner:
            return 150;

        case o_storage:
            return 130;
    }


    return 110;
}


/// @description Rebuilds current visibility from friendly revealers.

function scr_fog_visibility_update(_fog_controller)
{
    if (!instance_exists(_fog_controller))
        return false;


    var _fog =
        _fog_controller.fog;


    ds_grid_clear(
        _fog.visible_grid,
        0
    );


    // ========================================================================
    // PLAYER
    // ========================================================================

    var _player =
        global.vtd_level.entities.player;


    if (instance_exists(_player))
    {
        scr_fog_reveal_circle(
            _fog_controller,
            _player.x,
            _player.y,
            scr_fog_revealer_range_get(
                _player
            )
        );
    }


    // ========================================================================
    // CPU
    // ========================================================================

    var _cpu =
        global.vtd_level.entities.cpu;


    if (instance_exists(_cpu))
    {
        scr_fog_reveal_circle(
            _fog_controller,
            _cpu.x,
            _cpu.y,
            scr_fog_revealer_range_get(
                _cpu
            )
        );
    }


    // ========================================================================
    // ACTIVE BUILDINGS
    // ========================================================================

    with (o_building_par)
    {
        if (
            variable_instance_exists(
                id,
                "BuildingState"
            )
            && BuildingState
                == BuildingState.ACTIVE
        )
        {
            scr_fog_reveal_circle(
                other.id,
                x,
                y,
                scr_fog_revealer_range_get(
                    id
                )
            );
        }
    }


    // ========================================================================
    // RENDER CACHE
    // ========================================================================
    //
    // Gameplay data has changed.
    // The surface will rebuild once during the next Draw event.

    _fog.render.dirty =
        true;


    return true;
}


/// @description Returns whether a world position is currently visible.

function scr_fog_position_visible(_world_x, _world_y)
{
    var _fog =
        global.vtd_level.entities.fog.fog;

    if (!_fog.enabled)
        return true;


    var _cell_x =
        floor(_world_x / _fog.cell_size);

    var _cell_y =
        floor(_world_y / _fog.cell_size);


    if (
        _cell_x < 0
        || _cell_y < 0
        || _cell_x >= _fog.columns
        || _cell_y >= _fog.rows
    )
    {
        return false;
    }


    return _fog.visible_grid[# _cell_x, _cell_y] > 0;
}

/// @description Returns whether a world position was previously explored.

function scr_fog_position_explored(_world_x, _world_y)
{
    if (!variable_global_exists("vtd_level"))
        return true;

    if (!is_struct(global.vtd_level))
        return true;

    if (!variable_struct_exists(global.vtd_level.entities, "fog"))
        return true;


    var _controller =
        global.vtd_level.entities.fog;

    if (!instance_exists(_controller))
        return true;

    if (!_controller.fog.enabled)
        return true;


    var _fog = _controller.fog;

    var _cell_x =
        floor(_world_x / _fog.cell_size);

    var _cell_y =
        floor(_world_y / _fog.cell_size);


    if (
        _cell_x < 0
        || _cell_y < 0
        || _cell_x >= _fog.columns
        || _cell_y >= _fog.rows
    )
    {
        return false;
    }


    return _fog.explored_grid[# _cell_x, _cell_y] > 0;
}


/// @description Updates fog input and staggered visibility.

function scr_fog_update(_fog_controller)
{
    if (!instance_exists(_fog_controller))
        return false;


    var _fog = _fog_controller.fog;


    // Debug toggle. Simulation continues while fog drawing is disabled.

    if (keyboard_check_pressed(ord("V")))
    {
        _fog.enabled = !_fog.enabled;

        show_debug_message(
            "FOG OF WAR: "
            + (_fog.enabled ? "ENABLED" : "DISABLED")
        );
    }


    if (!_fog.enabled)
        return true;


    _fog.update_timer--;


    if (_fog.update_timer <= 0)
    {
        scr_fog_visibility_update(
            _fog_controller
        );

        _fog.update_timer =
            irandom_range(
                _fog.update_interval.minimum,
                _fog.update_interval.maximum
            );
    }


    return true;
}

/// @description Draws the cached fog-of-war surface.

function scr_fog_draw(_fog_controller)
{
    if (!instance_exists(_fog_controller))
        return false;


    var _fog =
        _fog_controller.fog;


    if (!_fog.enabled)
        return true;


    var _render =
        _fog.render;


    // ========================================================================
    // CACHE REBUILD
    // ========================================================================
    //
    // Rebuild only when:
    //
    // - gameplay visibility changed;
    // - GameMaker discarded the surface;
    // - the surface has not been created yet.

    if (
        _render.dirty
        || !surface_exists(
            _render.surface
        )
    )
    {
        if (
            !scr_fog_surface_rebuild(
                _fog_controller
            )
        )
        {
            return false;
        }
    }


    // ========================================================================
    // DRAW
    // ========================================================================
    //
    // Stretch the tiny fog-grid surface across the world.
    //
    // Each surface pixel therefore occupies exactly one world fog cell.

    draw_set_alpha(1);

    draw_set_color(
        c_white
    );


    draw_surface_stretched(
        _render.surface,

        0,
        0,

        _fog.columns
            * _fog.cell_size,

        _fog.rows
            * _fog.cell_size
    );


    draw_set_alpha(1);

    draw_set_color(
        c_white
    );


    return true;
}

/// @description Rebuilds the cached low-resolution fog render surface.

function scr_fog_surface_rebuild(_fog_controller)
{
    if (!instance_exists(_fog_controller))
        return false;


    var _fog =
        _fog_controller.fog;

    var _render =
        _fog.render;


    // ========================================================================
    // SURFACE
    // ========================================================================
    //
    // One surface pixel represents one world fog cell.
    //
    // Example:
    //
    // 8192 x 8192 world
    // 64 pixel fog cells
    //
    // becomes only a:
    //
    // 128 x 128 surface.

    var _surface_width =
        _fog.columns;

    var _surface_height =
        _fog.rows;


    var _surface_valid =
        surface_exists(
            _render.surface
        );


    if (_surface_valid)
    {
        _surface_valid =
            surface_get_width(
                _render.surface
            )
            == _surface_width
            && surface_get_height(
                _render.surface
            )
            == _surface_height;
    }


    if (!_surface_valid)
    {
        if (
            surface_exists(
                _render.surface
            )
        )
        {
            surface_free(
                _render.surface
            );
        }


        _render.surface =
            surface_create(
                _surface_width,
                _surface_height
            );
    }


    if (
        !surface_exists(
            _render.surface
        )
    )
    {
        _render.surface =
            -1;

        _render.dirty =
            true;

        return false;
    }


    // ========================================================================
    // REBUILD
    // ========================================================================

    surface_set_target(
        _render.surface
    );


    // Visible cells are transparent.

    draw_clear_alpha(
        c_black,
        0
    );


    draw_set_color(
        c_black
    );


    for (
        var _cell_y = 0;
        _cell_y < _fog.rows;
        ++_cell_y
    )
    {
        for (
            var _cell_x = 0;
            _cell_x < _fog.columns;
            ++_cell_x
        )
        {
            // Fully visible cells remain transparent.

            if (
                _fog.visible_grid[# _cell_x,_cell_y] > 0
            )
            {
                continue;
            }


            var _explored =
                _fog.explored_grid[# _cell_x, _cell_y ] > 0;


            draw_set_alpha(
                _explored
                ? _fog.alpha.explored
                : _fog.alpha.unexplored
            );


            // One surface pixel = one fog cell.

            draw_point(
                _cell_x,
                _cell_y
            );
        }
    }


    surface_reset_target();


    draw_set_alpha(1);

    draw_set_color(
        c_white
    );


    _render.dirty =
        false;


    return true;
}


/// @description Releases all fog-owned runtime data.

function scr_fog_cleanup(_fog_controller)
{
    if (!instance_exists(_fog_controller))
        return false;


    if (
        variable_instance_exists(
            _fog_controller,
            "fog"
        )
    )
    {
        var _fog =
            _fog_controller.fog;


        // ====================================================================
        // GAMEPLAY GRIDS
        // ====================================================================

        if (
            ds_exists(
                _fog.visible_grid,
                ds_type_grid
            )
        )
        {
            ds_grid_destroy(
                _fog.visible_grid
            );
        }


        if (
            ds_exists(
                _fog.explored_grid,
                ds_type_grid
            )
        )
        {
            ds_grid_destroy(
                _fog.explored_grid
            );
        }


        // ====================================================================
        // RENDER SURFACE
        // ====================================================================

        if (
            surface_exists(
                _fog.render.surface
            )
        )
        {
            surface_free(
                _fog.render.surface
            );
        }


        _fog.render.surface =
            -1;

        _fog.render.dirty =
            true;
    }


    // ========================================================================
    // LEVEL REFERENCE
    // ========================================================================

    if (
        variable_global_exists(
            "vtd_level"
        )
        && is_struct(
            global.vtd_level
        )
        && variable_struct_exists(
            global.vtd_level.entities,
            "fog"
        )
        && global.vtd_level.entities.fog
            == _fog_controller
    )
    {
        global.vtd_level.entities.fog =
            noone;
    }


    return true;
}
