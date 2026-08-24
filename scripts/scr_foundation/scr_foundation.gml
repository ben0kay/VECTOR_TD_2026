/// @description Returns the foundation occupying one cell.

function scr_foundation_at_cell(_cell_x, _cell_y)
{
    if (!scr_building_cell_inside_map(_cell_x, _cell_y))
        return noone;

    if (!global.vtd_level.world.ready)
        return noone;


    var _foundation =
        ds_grid_get(
            global.vtd_level.world.grid.foundation,
            _cell_x,
            _cell_y
        );


    if (!instance_exists(_foundation))
        return noone;


    return _foundation;
}


/// @description Returns whether a foundation may occupy one cell.

function scr_foundation_placement_valid(
    _data,
    _cell_x,
    _cell_y
)
{
    if (!scr_building_data_valid(_data))
        return false;


    var _cells =
        scr_building_footprint_cells_get(
            _cell_x,
            _cell_y,
            _data.footprint.width_cells,
            _data.footprint.height_cells
        );


    for (var i = 0; i < array_length(_cells); ++i)
    {
        var _cell = _cells[i];

        if (!scr_building_cell_inside_map(_cell.x, _cell.y))
            return false;

        if (!scr_world_cell_buildable(_cell.x, _cell.y))
            return false;

        if (instance_exists(scr_foundation_at_cell(_cell.x, _cell.y)))
            return false;


        // Foundations must be installed before ordinary buildings.
        // They do not retrofit underneath an existing structure.

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


/// @description Initializes one non-solid foundation instance.

function scr_foundation_initialize(_foundation)
{
    if (!instance_exists(_foundation))
        return false;

    if (!variable_instance_exists(_foundation, "building_key"))
        return false;


    var _data =
        scr_building_data_get(
            _foundation.building_key
        );

    if (!scr_building_data_valid(_data))
        return false;

    if (_data.identity.type != BuildingType.FOUNDATION)
        return false;


    _foundation.building_data = _data;
    _foundation.BuildingState = BuildingState.CONSTRUCTING;

    _foundation.identity =
    {
        key: _data.identity.key,
        name: _data.identity.name,
        type: _data.identity.type
    };

    _foundation.visual =
    {
        color: _data.visual.color
    };

    _foundation.footprint =
    {
        width_cells: _data.footprint.width_cells,
        height_cells: _data.footprint.height_cells,

        origin:
        {
            x: _foundation.placement_cell_x,
            y: _foundation.placement_cell_y
        },

        cells:
            scr_building_footprint_cells_get(
                _foundation.placement_cell_x,
                _foundation.placement_cell_y,
                _data.footprint.width_cells,
                _data.footprint.height_cells
            ),

        reserved: false
    };


    // Foundation tiles currently have durability for construction feedback,
    // but ordinary enemies do not target them.

    _foundation.vitals =
    {
        hp:
        {
            current: max(1, _data.vitals.hp_maximum * 0.1),
            maximum: _data.vitals.hp_maximum
        }
    };


    _foundation.construction =
    {
        progress_seconds: 0,
        duration_seconds: max(0, _data.construction.time_seconds),
        percent: 0,
        hp_remaining: _data.vitals.hp_maximum * 0.9,
        complete: false
    };


    if (
        !scr_foundation_placement_valid(
            _data,
            _foundation.placement_cell_x,
            _foundation.placement_cell_y
        )
    )
    {
        return false;
    }


    for (
        var i = 0;
        i < array_length(_foundation.footprint.cells);
        ++i
    )
    {
        var _cell =
            _foundation.footprint.cells[i];

        ds_grid_set(
            global.vtd_level.world.grid.foundation,
            _cell.x,
            _cell.y,
            _foundation
        );
    }


    _foundation.footprint.reserved = true;


    if (_foundation.construction.duration_seconds <= 0)
    {
        _foundation.construction.progress_seconds = 0;
        _foundation.construction.percent = 1;
        _foundation.construction.hp_remaining = 0;
        _foundation.construction.complete = true;
        _foundation.BuildingState = BuildingState.ACTIVE;
        _foundation.vitals.hp.current = _foundation.vitals.hp.maximum;
    }


    return true;
}


/// @description Updates one foundation's construction lifecycle.

function scr_foundation_update(_foundation)
{
    if (!instance_exists(_foundation))
        return false;


    switch (_foundation.BuildingState)
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
                _foundation.construction.percent;


            _foundation.construction.progress_seconds =
                min(
                    _foundation.construction.duration_seconds,
                    _foundation.construction.progress_seconds + _delta
                );

            _foundation.construction.percent =
                clamp(
                    _foundation.construction.progress_seconds
                    / max(0.001, _foundation.construction.duration_seconds),
                    0,
                    1
                );


            // Construction adds HP gradually without healing damage already
            // inflicted during construction.

            var _percent_added =
                _foundation.construction.percent
                - _previous_percent;

            var _hp_added =
                _foundation.construction.hp_remaining
                * _percent_added
                / max(
                    0.001,
                    1 - _previous_percent
                );

            _foundation.vitals.hp.current =
                min(
                    _foundation.vitals.hp.maximum,
                    _foundation.vitals.hp.current + _hp_added
                );

            _foundation.construction.hp_remaining =
                max(
                    0,
                    _foundation.construction.hp_remaining - _hp_added
                );


            if (_foundation.construction.percent >= 1)
            {
                _foundation.construction.complete = true;
                _foundation.BuildingState = BuildingState.ACTIVE;

                show_debug_message(
                    "FOUNDATION COMPLETE: "
                    + _foundation.identity.name
                );
            }
        }
        break;


        case BuildingState.ACTIVE:
        {
            // FUTURE:
            // powered floors
            // repair floors
            // environmental protection
        }
        break;
    }


    return true;
}


/// @description Draws one flat vector foundation tile.

function scr_foundation_draw(_foundation)
{
    if (!instance_exists(_foundation))
        return false;


    var _cell_size =
        global.vtd_level.map.cell_size;

    var _width =
        _foundation.footprint.width_cells
        * _cell_size;

    var _height =
        _foundation.footprint.height_cells
        * _cell_size;

    var _left =
        _foundation.x - (_width * 0.5);

    var _top =
        _foundation.y - (_height * 0.5);

    var _right =
        _foundation.x + (_width * 0.5);

    var _bottom =
        _foundation.y + (_height * 0.5);

    var _percent =
        _foundation.construction.percent;


    draw_set_color(_foundation.visual.color);

    draw_set_alpha(
        lerp(
            0.2,
            0.6,
            _percent
        )
    );

    draw_rectangle(
        _left + 2,
        _top + 2,
        _right - 2,
        _bottom - 2,
        true
    );


    draw_set_alpha(0.8);

    draw_rectangle(
        _left + 2,
        _top + 2,
        _right - 2,
        _bottom - 2,
        false
    );


    // Structural cross-bracing.

    draw_set_alpha(0.35);

    draw_line(
        _left + 6,
        _top + 6,
        _right - 6,
        _bottom - 6
    );

    draw_line(
        _right - 6,
        _top + 6,
        _left + 6,
        _bottom - 6
    );


    if (_foundation.BuildingState == BuildingState.CONSTRUCTING)
    {
        draw_set_alpha(1);
        draw_set_color(c_dkgray);

        draw_rectangle(
            _left,
            _top - 6,
            _right,
            _top - 3,
            false
        );

        draw_set_color(c_aqua);

        draw_rectangle(
            _left,
            _top - 6,
            _left + ((_right - _left) * _percent),
            _top - 3,
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Releases foundation cells during destruction or room cleanup.

function scr_foundation_cleanup(_foundation)
{
    if (!instance_exists(_foundation))
        return false;

    if (!_foundation.footprint.reserved)
        return true;


    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && global.vtd_level.world.ready
    )
    {
        for (
            var i = 0;
            i < array_length(_foundation.footprint.cells);
            ++i
        )
        {
            var _cell =
                _foundation.footprint.cells[i];

            if (
                scr_foundation_at_cell(_cell.x, _cell.y)
                == _foundation
            )
            {
                ds_grid_set(
                    global.vtd_level.world.grid.foundation,
                    _cell.x,
                    _cell.y,
                    noone
                );
            }
        }
    }


    _foundation.footprint.reserved = false;
    _foundation.footprint.cells = [];

    return true;
}


/// @description Returns whether every cell beneath a building has a foundation.

function scr_foundation_building_coverage_get(_building)
{
    if (!instance_exists(_building))
        return 0;

    if (!is_array(_building.footprint.cells))
        return 0;


    var _cell_count =
        array_length(
            _building.footprint.cells
        );

    if (_cell_count <= 0)
        return 0;


    var _covered = 0;


    for (var i = 0; i < _cell_count; ++i)
    {
        var _cell =
            _building.footprint.cells[i];

        var _foundation =
            scr_foundation_at_cell(
                _cell.x,
                _cell.y
            );

        if (
            instance_exists(_foundation)
            && _foundation.BuildingState
                == BuildingState.ACTIVE
        )
        {
            _covered++;
        }
    }


    return _covered / _cell_count;
}