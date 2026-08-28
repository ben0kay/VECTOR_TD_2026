/// @description Initializes level fog-of-war grids.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}


var _cell_size =
    64;

var _columns =
    ceil(
        room_width
        / _cell_size
    );

var _rows =
    ceil(
        room_height
        / _cell_size
    );


fog =
{
    enabled:
        true,

    cell_size:
        _cell_size,

    columns:
        _columns,

    rows:
        _rows,


    // ========================================================================
    // GAMEPLAY GRIDS
    // ========================================================================

    visible_grid:
        ds_grid_create(
            _columns,
            _rows
        ),

    explored_grid:
        ds_grid_create(
            _columns,
            _rows
        ),


    // ========================================================================
    // UPDATE
    // ========================================================================

    update_timer:
        0,

    update_interval:
    {
        minimum: 3,
        maximum: 5
    },


    // ========================================================================
    // VISUAL
    // ========================================================================

    alpha:
    {
        explored: 0.55,
        unexplored: 1.0
    },


    // ========================================================================
    // CACHED RENDERING
    // ========================================================================
    //
    // The DS grids remain the gameplay authority.
    // This surface is only a cached visual representation.
    //
    // One surface pixel represents one fog cell.

    render:
    {
        surface: -1,
        dirty: true
    }
};


ds_grid_clear(
    fog.visible_grid,
    0
);

ds_grid_clear(
    fog.explored_grid,
    0
);


global.vtd_level.entities.fog =
    id;


scr_fog_visibility_update(
    id
);


show_debug_message(
    "VECTOR TD 2026 - FOG INITIALIZED"
);