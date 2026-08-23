/// @description Generic resource-miner placement, extraction, and drawing.


/// @description Returns whether a miner definition can occupy a resource cell.

function scr_miner_placement_valid(
    _data,
    _cell_x,
    _cell_y
)
{
    if (!scr_building_data_valid(_data))
        return false;

    if (_data.identity.type != BuildingType.MINER)
        return false;

    if (!scr_building_cell_inside_map(_cell_x, _cell_y))
        return false;


    // Initial miners occupy exactly one resource cell.

    if (
        _data.footprint.width_cells != 1
        || _data.footprint.height_cells != 1
    )
    {
        return false;
    }


    if (
        scr_world_cell_type_get(_cell_x, _cell_y)
        != WorldCellType.RESOURCE
    )
    {
        return false;
    }


    var _resource_key = scr_world_cell_resource_get(
        _cell_x,
        _cell_y
    );


    if (_resource_key != _data.miner.resource_key)
        return false;


    var _node = scr_resource_node_at_cell(
        _cell_x,
        _cell_y
    );


    if (!instance_exists(_node))
        return false;

    if (_node.amount.depleted)
        return false;

    if (instance_exists(_node.claim.miner))
        return false;


    // Resource terrain is already blocked on grid_ground, so check building
    // occupancy directly instead of rejecting the terrain cell itself.

    if (instance_exists(scr_building_at_cell(_cell_x, _cell_y)))
        return false;


    var _cells =
    [
        {
            x: _cell_x,
            y: _cell_y
        }
    ];


    if (scr_building_footprint_entity_blocked(_cells))
        return false;


    return true;
}


/// @description Initializes one miner and claims its resource node.

function scr_miner_initialize(_miner)
{
    if (!instance_exists(_miner))
        return false;


    var _data = _miner.building_data;

    if (!variable_struct_exists(_data, "miner"))
        return false;

    if (!is_struct(_data.miner))
        return false;


    var _cell_x = _miner.footprint.origin.x;
    var _cell_y = _miner.footprint.origin.y;

    var _node = scr_resource_node_at_cell(
        _cell_x,
        _cell_y
    );


    if (!instance_exists(_node))
        return false;

    if (instance_exists(_node.claim.miner))
        return false;

    if (_node.identity.key != _data.miner.resource_key)
        return false;


    _miner.mining =
    {
        node: _node,
        resource_key: _data.miner.resource_key,

        rate_per_second:
            _data.miner.extraction_rate_per_second,

        extracting: false,
        total_extracted: 0
    };


    _miner.hopper =
    {
        resource_key: _data.miner.resource_key,
        current: 0,
        capacity: _data.miner.hopper_capacity
    };


    _miner.logistics =
    {
        // FUTURE:
        // A drone job will reserve this miner before collection.
        collection_reserved: false,
        assigned_drone: noone
    };


    _node.claim.miner = _miner;


    show_debug_message(
        "MINER CLAIMED: "
        + _node.identity.name
        + " | VEIN "
        + string(_node.identity.vein_id)
    );


    return true;
}

/// @description Extracts material and requests visible cargo collection.

function scr_miner_update(_miner)
{
    if (!instance_exists(_miner))
        return false;


    _miner.mining.extracting = false;


    if (_miner.BuildingState == BuildingState.ACTIVE)
    {
        var _node = _miner.mining.node;

        var _can_extract =
            instance_exists(_node)
            && !_node.amount.depleted
            && _miner.hopper.current < _miner.hopper.capacity;


        if (_can_extract)
        {
            // FUTURE:
            // Require active power.
            // Apply extraction upgrades.
            // Apply overclock modifiers.
            // Generate underground noise.

            var _fps = max(
                1,
                game_get_speed(gamespeed_fps)
            );

            var _requested =
                _miner.mining.rate_per_second
                / _fps;

            var _hopper_space =
                _miner.hopper.capacity
                - _miner.hopper.current;

            var _extracted = min(
                _requested,
                _hopper_space,
                _node.amount.current
            );


            if (_extracted > 0)
            {
                _node.amount.current = max(
                    0,
                    _node.amount.current
                    - _extracted
                );

                _miner.hopper.current = min(
                    _miner.hopper.capacity,
                    _miner.hopper.current
                    + _extracted
                );

                _miner.mining.total_extracted += _extracted;
                _miner.mining.extracting = true;
            }


            if (_node.amount.current <= 0)
            {
                _node.amount.current = 0;
                _node.amount.depleted = true;

                show_debug_message(
                    "RESOURCE DEPLETED: "
                    + _node.identity.name
                    + " | VEIN "
                    + string(_node.identity.vein_id)
                );


                // FUTURE:
                // Convert the cell back into dead terrain.
                // Let advanced miners continue through a vein.
            }
        }
    }


    // Collection can continue even if extraction has temporarily stopped.

    scr_logistics_miner_update(_miner);

    return true;
}


/// @description Draws one miner with compact visual status feedback.

function scr_miner_draw(_miner)
{
    if (!instance_exists(_miner))
        return false;


    var _cell_size = global.vtd_level.map.cell_size;
    var _half = _cell_size * 0.5;

    var _left = _miner.x - _half;
    var _top = _miner.y - _half;
    var _right = _miner.x + _half;
    var _bottom = _miner.y + _half;

    var _node = _miner.mining.node;
    var _resource_color = c_gray;


    if (instance_exists(_node))
        _resource_color = _node.visual.color;


    // ========================================================================
    // STATUS
    // ========================================================================

    var _status_color = c_gray;


    if (!instance_exists(_node))
    {
        _status_color = c_red;
    }
    else if (_node.amount.depleted)
    {
        _status_color = c_red;
    }
    else if (_miner.hopper.current >= _miner.hopper.capacity)
    {
        _status_color = c_yellow;
    }
    else if (_miner.mining.extracting)
    {
        _status_color = c_lime;
    }


    // ========================================================================
    // BODY
    // ========================================================================

    draw_set_color(c_dkgray);

    draw_rectangle(
        _left + 3,
        _top + 3,
        _right - 3,
        _bottom - 3,
        true
    );


    draw_set_color(_status_color);

    draw_rectangle(
        _left + 2,
        _top + 2,
        _right - 2,
        _bottom - 2,
        false
    );


    draw_set_color(_resource_color);

    draw_circle(
        _miner.x,
        _miner.y,
        _cell_size * 0.27,
        false
    );


    // ========================================================================
    // DRILL
    // ========================================================================

    var _drill_angle = 0;

    if (_miner.mining.extracting)
        _drill_angle = global.vtd.tick * 8;


    draw_line_width(
        _miner.x + lengthdir_x(8, _drill_angle),
        _miner.y + lengthdir_y(8, _drill_angle),
        _miner.x + lengthdir_x(8, _drill_angle + 180),
        _miner.y + lengthdir_y(8, _drill_angle + 180),
        3
    );

    draw_line_width(
        _miner.x + lengthdir_x(8, _drill_angle + 90),
        _miner.y + lengthdir_y(8, _drill_angle + 90),
        _miner.x + lengthdir_x(8, _drill_angle + 270),
        _miner.y + lengthdir_y(8, _drill_angle + 270),
        3
    );


    // ========================================================================
    // HOPPER BAR
    // ========================================================================

    var _hopper_percent = clamp(
        _miner.hopper.current
        / _miner.hopper.capacity,
        0,
        1
    );

    var _bar_left = _left + 4;
    var _bar_right = _right - 4;
    var _bar_top = _bottom - 6;
    var _bar_bottom = _bottom - 3;


    draw_set_color(c_black);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_right,
        _bar_bottom,
        true
    );


    draw_set_color(_resource_color);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left
            + ((_bar_right - _bar_left) * _hopper_percent),
        _bar_bottom,
        true
    );


    draw_set_color(c_white);

    return true;
}


/// @description Releases miner, node, and logistics reservations.

function scr_miner_cleanup(_miner)
{
    if (!instance_exists(_miner))
        return false;


    if (
        variable_instance_exists(_miner, "logistics")
        && is_struct(_miner.logistics)
        && instance_exists(_miner.logistics.assigned_drone)
    )
    {
        instance_destroy(
            _miner.logistics.assigned_drone
        );

        _miner.logistics.assigned_drone = noone;
        _miner.logistics.collection_reserved = false;
    }


    if (
        variable_instance_exists(_miner, "mining")
        && is_struct(_miner.mining)
    )
    {
        var _node = _miner.mining.node;


        if (
            instance_exists(_node)
            && _node.claim.miner == _miner
        )
        {
            _node.claim.miner = noone;
        }
    }


    return true;
}