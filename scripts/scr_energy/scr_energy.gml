/// @description Local energy networks, building buffers and energy distribution.

/// @description Creates one building's energy runtime.

function scr_energy_runtime_create(_data)
{
    var _participates =
        variable_struct_exists(_data, "energy")
        && is_struct(_data.energy);

    var _runtime =
    {
        participates: _participates,
        role: EnergyRole.NONE,
        priority: EnergyPriority.NORMAL,

        network_id: -1,
        connected: false,
        supplied: !_participates,
        registration_pending: false,

        connection_range: 0,
        generation_per_second: 0,
        input_rate: 0,

        demand:
		{
		    idle_per_second: 0,
		    activity_cost: 0,

		    activity_spent: 0,
		    activity_recent_per_second: 0
		},

        buffer:
        {
            current: 0,
            maximum: 0
        },

        battery:
        {
            current: 0,
            maximum: 0,
            charge_rate: 0,
            discharge_rate: 0
        }
    };

    if (!_participates)
        return _runtime;


    var _energy_data = _data.energy;

    if (variable_struct_exists(_energy_data, "role"))
        _runtime.role = _energy_data.role;

    if (variable_struct_exists(_energy_data, "priority"))
        _runtime.priority = _energy_data.priority;

    if (variable_struct_exists(_energy_data, "connection_range"))
        _runtime.connection_range = max(0, _energy_data.connection_range);

    if (variable_struct_exists(_energy_data, "generation_per_second"))
        _runtime.generation_per_second = max(0, _energy_data.generation_per_second);

    if (variable_struct_exists(_energy_data, "input_rate"))
        _runtime.input_rate = max(0, _energy_data.input_rate);

    if (variable_struct_exists(_energy_data, "idle_demand"))
        _runtime.demand.idle_per_second = max(0, _energy_data.idle_demand);

    if (variable_struct_exists(_energy_data, "activity_cost"))
        _runtime.demand.activity_cost = max(0, _energy_data.activity_cost);


    if (
        variable_struct_exists(_energy_data, "buffer")
        && is_struct(_energy_data.buffer)
    )
    {
        if (variable_struct_exists(_energy_data.buffer, "capacity"))
            _runtime.buffer.maximum = max(0, _energy_data.buffer.capacity);

        var _starting_ratio = 0;

        if (variable_struct_exists(_energy_data.buffer, "starting_ratio"))
            _starting_ratio = clamp(_energy_data.buffer.starting_ratio, 0, 1);

        _runtime.buffer.current =
            _runtime.buffer.maximum
            * _starting_ratio;
    }


    if (
        variable_struct_exists(_energy_data, "battery")
        && is_struct(_energy_data.battery)
    )
    {
        if (variable_struct_exists(_energy_data.battery, "capacity"))
            _runtime.battery.maximum = max(0, _energy_data.battery.capacity);

        if (variable_struct_exists(_energy_data.battery, "charge_rate"))
            _runtime.battery.charge_rate = max(0, _energy_data.battery.charge_rate);

        if (variable_struct_exists(_energy_data.battery, "discharge_rate"))
            _runtime.battery.discharge_rate = max(0, _energy_data.battery.discharge_rate);

        var _battery_ratio = 0;

        if (variable_struct_exists(_energy_data.battery, "starting_ratio"))
            _battery_ratio = clamp(_energy_data.battery.starting_ratio, 0, 1);

        _runtime.battery.current =
            _runtime.battery.maximum
            * _battery_ratio;
    }


    return _runtime;
}


/// @description Marks local energy topology for rebuilding.

function scr_energy_topology_dirty()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(global.vtd_level, "energy"))
        return false;

    global.vtd_level.energy.dirty = true;

    return true;
}


/// @description Returns whether two buildings may form an energy connection.

function scr_energy_connection_valid(_first, _second)
{
    if (!instance_exists(_first) || !instance_exists(_second))
        return false;

    if (!_first.energy.participates || !_second.energy.participates)
        return false;

    if (_first.BuildingState != BuildingState.ACTIVE)
        return false;

    if (_second.BuildingState != BuildingState.ACTIVE)
        return false;


    // Nodes form the backbone. Consumers cannot daisy-chain energy
    // through other consumers.

    if (
        _first.energy.role != EnergyRole.NODE
        && _second.energy.role != EnergyRole.NODE
    )
    {
        return false;
    }


    var _range =
        min(
            _first.energy.connection_range,
            _second.energy.connection_range
        );

    if (_range <= 0)
        return false;


    return point_distance(
        _first.x,
        _first.y,
        _second.x,
        _second.y
    ) <= _range;
}


/// @description Returns whether an array already contains an instance.

function scr_energy_array_contains(_array, _instance)
{
    for (var i = 0; i < array_length(_array); ++i)
    {
        if (_array[i] == _instance)
            return true;
    }

    return false;
}


/// @description Rebuilds every independent local energy network.

function scr_energy_networks_rebuild()
{
    if (!is_struct(global.vtd_level.energy))
        return false;


    var _system = global.vtd_level.energy;
    var _participants =
    scr_energy_participants_get();


    var _networks = [];
    var _next_network_id = 0;


    // Every unassigned node begins one connected-component search.

    for (var n = 0; n < array_length(_participants); ++n)
    {
        var _origin = _participants[n];

        if (_origin.energy.role != EnergyRole.NODE)
            continue;

        if (_origin.energy.network_id >= 0)
            continue;


        var _network =
        {
            id: _next_network_id,
            state: EnergyNetworkState.OFFLINE,
            color: scr_energy_network_color_get(_next_network_id),

            members: [],
            nodes: [],
            consumers: [],
            generators: [],
            batteries: [],

            generation: 0,
            demand: 0,
            net: 0,

            stored: 0,
            storage_maximum: 0
        };


        var _queue = [_origin];
        var _queue_index = 0;

        _origin.energy.network_id = _next_network_id;


        while (_queue_index < array_length(_queue))
        {
            var _current = _queue[_queue_index];
            ++_queue_index;

            array_push(_network.nodes, _current);
            array_push(_network.members, _current);


            for (var c = 0; c < array_length(_participants); ++c)
            {
                var _candidate = _participants[c];

                if (_candidate.energy.role != EnergyRole.NODE)
                    continue;

                if (_candidate.energy.network_id >= 0)
                    continue;

                if (!scr_energy_connection_valid(_current, _candidate))
                    continue;


                _candidate.energy.network_id = _next_network_id;
                array_push(_queue, _candidate);
            }
        }


        array_push(_networks, _network);
        ++_next_network_id;
    }


    // Attach generators, batteries and consumers to their closest node.

    for (var p = 0; p < array_length(_participants); ++p)
    {
        var _member = _participants[p];

        if (_member.energy.role == EnergyRole.NODE)
            continue;


        var _closest_node = noone;
        var _closest_distance = infinity;


        for (var q = 0; q < array_length(_participants); ++q)
        {
            var _node = _participants[q];

            if (_node.energy.role != EnergyRole.NODE)
                continue;

            if (_node.energy.network_id < 0)
                continue;

            if (!scr_energy_connection_valid(_member, _node))
                continue;


            var _distance =
                point_distance(
                    _member.x,
                    _member.y,
                    _node.x,
                    _node.y
                );

            if (_distance < _closest_distance)
            {
                _closest_distance = _distance;
                _closest_node = _node;
            }
        }


        if (!instance_exists(_closest_node))
            continue;


        var _network_id = _closest_node.energy.network_id;
        var _attached_network = _networks[_network_id];

        _member.energy.network_id = _network_id;
        _member.energy.connected = true;

        array_push(_attached_network.members, _member);


        switch (_member.energy.role)
        {
            case EnergyRole.GENERATOR:
                array_push(_attached_network.generators, _member);
            break;

            case EnergyRole.BATTERY:
                array_push(_attached_network.batteries, _member);
            break;

            case EnergyRole.CONSUMER:
                array_push(_attached_network.consumers, _member);
            break;
        }
    }


    // Nodes belonging to a completed network are connected.

    for (var network_index = 0; network_index < array_length(_networks); ++network_index)
    {
        var _completed_network = _networks[network_index];

        for (var node_index = 0; node_index < array_length(_completed_network.nodes); ++node_index)
            _completed_network.nodes[node_index].energy.connected = true;
    }


    _system.networks = _networks;
    _system.dirty = false;
    ++_system.revision;


    show_debug_message(
        "ENERGY NETWORKS REBUILT: "
        + string(array_length(_networks))
    );


    return true;
}


/// @description Returns a consistent overlay color for one network.

function scr_energy_network_color_get(_network_id)
{
    var _colors =
    [
        c_aqua,
        c_lime,
        c_yellow,
        c_fuchsia,
        make_color_rgb(255, 140, 40),
        make_color_rgb(120, 140, 255)
    ];

    return _colors[_network_id mod array_length(_colors)];
}


/// @description Sorts network consumers by energy priority.

function scr_energy_consumers_sort(_first, _second)
{
    return _first.energy.priority - _second.energy.priority;
}


/// @description Supplies one consumer's internal buffer.

function scr_energy_consumer_fill(_consumer, _available, _delta)
{
    if (!instance_exists(_consumer))
        return _available;

    var _missing =
        max(
            0,
            _consumer.energy.buffer.maximum
            - _consumer.energy.buffer.current
        );

    var _input_limit =
        _consumer.energy.input_rate
        * _delta;

    var _received =
        min(
            _available,
            _missing,
            _input_limit
        );

    _consumer.energy.buffer.current += _received;

    return _available - _received;
}


/// @description Updates one independent energy network.

function scr_energy_network_update(_network, _delta)
{
    var _available = 0;
    var _generation_rate = 0;
    var _demand_rate = 0;


    // Generators produce directly into their local network.

    for (var g = 0; g < array_length(_network.generators); ++g)
    {
        var _generator = _network.generators[g];

        if (!instance_exists(_generator))
            continue;

        _generation_rate +=
            _generator.energy.generation_per_second;
    }

    _available =
        _generation_rate
        * _delta;


    // Idle demand is consumed from each building's private buffer.

    for (var c = 0; c < array_length(_network.consumers); ++c)
    {
        var _consumer = _network.consumers[c];

        if (!instance_exists(_consumer))
            continue;

        var _idle_rate =
            _consumer.energy.demand.idle_per_second;

        var _idle_cost =
            _idle_rate
            * _delta;

        var _activity_rate =
	    scr_energy_activity_rate_update(
	        _consumer,
	        _delta
	    );

	_demand_rate +=
	    _idle_rate
	    + _activity_rate;


        if (_consumer.energy.buffer.current >= _idle_cost)
        {
            _consumer.energy.buffer.current -= _idle_cost;
            _consumer.energy.supplied = true;
        }
        else
        {
            _consumer.energy.buffer.current = 0;
            _consumer.energy.supplied = false;
        }
    }


    // Critical consumers fill before lower-priority consumers.

    array_sort(
        _network.consumers,
        scr_energy_consumers_sort
    );


    for (var fill_index = 0; fill_index < array_length(_network.consumers); ++fill_index)
    {
        _available =
            scr_energy_consumer_fill(
                _network.consumers[fill_index],
                _available,
                _delta
            );
    }


    // Batteries discharge into unfinished building buffers.

    if (_available <= 0)
    {
        for (var b = 0; b < array_length(_network.batteries); ++b)
        {
            var _battery = _network.batteries[b];

            if (!instance_exists(_battery))
                continue;

            var _discharge =
                min(
                    _battery.energy.battery.current,
                    _battery.energy.battery.discharge_rate * _delta
                );

            if (_discharge <= 0)
                continue;

            _battery.energy.battery.current -= _discharge;
            _available += _discharge;


            for (var refill_index = 0; refill_index < array_length(_network.consumers); ++refill_index)
            {
                _available =
                    scr_energy_consumer_fill(
                        _network.consumers[refill_index],
                        _available,
                        _delta
                    );

                if (_available <= 0)
                    break;
            }


            if (_available <= 0)
                break;
        }
    }


    // Remaining generation charges network batteries.

    if (_available > 0)
    {
        for (var charge_index = 0; charge_index < array_length(_network.batteries); ++charge_index)
        {
            var _charge_battery = _network.batteries[charge_index];

            if (!instance_exists(_charge_battery))
                continue;

            var _battery_space =
                _charge_battery.energy.battery.maximum
                - _charge_battery.energy.battery.current;

            var _charge =
                min(
                    _available,
                    _battery_space,
                    _charge_battery.energy.battery.charge_rate * _delta
                );

            _charge_battery.energy.battery.current += _charge;
            _available -= _charge;

            if (_available <= 0)
                break;
        }
    }


    // Refresh supplied state after network distribution.

    for (var supplied_index = 0; supplied_index < array_length(_network.consumers); ++supplied_index)
    {
        var _supplied_consumer = _network.consumers[supplied_index];

        if (!instance_exists(_supplied_consumer))
            continue;

        _supplied_consumer.energy.supplied =
            _supplied_consumer.energy.buffer.current > 0
            || _supplied_consumer.energy.demand.idle_per_second <= 0;
    }


    _network.generation = _generation_rate;
    _network.demand = _demand_rate;
    _network.net = _generation_rate - _demand_rate;

    _network.stored = 0;
    _network.storage_maximum = 0;


    for (var stored_index = 0; stored_index < array_length(_network.batteries); ++stored_index)
    {
        var _stored_battery = _network.batteries[stored_index];

        if (!instance_exists(_stored_battery))
            continue;

        _network.stored +=
            _stored_battery.energy.battery.current;

        _network.storage_maximum +=
            _stored_battery.energy.battery.maximum;
    }


    if (_generation_rate <= 0 && _network.stored <= 0)
        _network.state = EnergyNetworkState.OFFLINE;
    else if (_network.net < 0 && _network.stored > 0)
        _network.state = EnergyNetworkState.BATTERY;
    else if (_network.net < 0)
        _network.state = EnergyNetworkState.DEFICIT;
    else if (_network.net > 0)
        _network.state = EnergyNetworkState.SURPLUS;
    else
        _network.state = EnergyNetworkState.BALANCED;


    return true;
}

/// @description Updates every local network, HUD totals and grid alerts.

function scr_energy_update()
{
    if (!GAMEPLAY_ACTIVE)
        return false;


    var _system =
        global.vtd_level.energy;


    scr_energy_alert_runtime_ensure();


    if (_system.dirty)
        scr_energy_networks_rebuild();


    var _delta =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _system.alerts.cooldown_remaining =
        max(
            0,
            _system.alerts.cooldown_remaining
            - _delta
        );


    _system.totals.generation = 0;
    _system.totals.demand = 0;
    _system.totals.stored = 0;
    _system.totals.storage_maximum = 0;
    _system.totals.deficient_networks = 0;


    for (
        var network_index = 0;
        network_index < array_length(_system.networks);
        ++network_index
    )
    {
        var _network =
            _system.networks[network_index];


        scr_energy_network_update(
            _network,
            _delta
        );


        _system.totals.generation +=
            _network.generation;

        _system.totals.demand +=
            _network.demand;

        _system.totals.stored +=
            _network.stored;

        _system.totals.storage_maximum +=
            _network.storage_maximum;


        if (
            _network.state == EnergyNetworkState.DEFICIT
            || _network.state == EnergyNetworkState.OFFLINE
        )
        {
            ++_system.totals.deficient_networks;
        }


        scr_energy_network_alert_update(
            _network
        );
    }


    _system.totals.net =
        _system.totals.generation
        - _system.totals.demand;


    return true;
}

/// @description Pays an activity cost from a building's private buffer.

function scr_energy_activity_consume(_building, _cost = undefined)
{
    if (!instance_exists(_building))
        return false;

    if (!_building.energy.participates)
        return true;

    if (_building.BuildingState != BuildingState.ACTIVE)
        return false;

    if (is_undefined(_cost))
        _cost = _building.energy.demand.activity_cost;

    _cost = max(0, _cost);

    if (_cost <= 0)
        return true;

    if (_building.energy.buffer.current < _cost)
        return false;


    _building.energy.buffer.current -= _cost;

    _building.energy.demand.activity_spent +=
        _cost;


    return true;
}

/// @description Adds default energy data to operational buildings.

function scr_energy_consumer_data_defaults_apply()
{
    var _keys =
        variable_struct_get_names(
            global.vtd.data.buildings
        );

    for (var i = 0; i < array_length(_keys); ++i)
    {
        var _data =
            variable_struct_get(
                global.vtd.data.buildings,
                _keys[i]
            );

        if (!is_struct(_data))
            continue;

        if (variable_struct_exists(_data, "energy"))
            continue;


        switch (_data.identity.type)
        {
            case BuildingType.TOWER:
            {
				
				var _activity_cost = 2;

				if (
				    variable_struct_exists(_data, "tower")
				    && variable_struct_exists(_data.tower, "weapon")
				    && variable_struct_exists(
				        _data.tower.weapon,
				        "energy_cost"
				    )
				)
				{
				    _activity_cost =
				        max(
				            0,
				            _data.tower.weapon.energy_cost
				        );
				}
                _data.energy =
                {
                    role: EnergyRole.CONSUMER,
                    priority: EnergyPriority.HIGH,

                    connection_range: 320,
                    generation_per_second: 0,

                    input_rate: 8,
                    idle_demand: 0.25,
                    activity_cost: _activity_cost,

                    buffer:
                    {
                        capacity: 20,
                        starting_ratio: 0
                    }
                };
            }
            break;


            case BuildingType.MINER:
            {
                _data.energy =
                {
                    role: EnergyRole.CONSUMER,
                    priority: EnergyPriority.NORMAL,

                    connection_range: 320,
                    generation_per_second: 0,

                    input_rate: 6,
                    idle_demand: 1,
                    activity_cost: 2,

                    buffer:
                    {
                        capacity: 15,
                        starting_ratio: 0
                    }
                };
            }
            break;


            case BuildingType.STORAGE:
            {
                _data.energy =
                {
                    role: EnergyRole.CONSUMER,
                    priority: EnergyPriority.LOW,

                    connection_range: 320,
                    generation_per_second: 0,

                    input_rate: 2,
                    idle_demand: 0.1,
                    activity_cost: 0,

                    buffer:
                    {
                        capacity: 5,
                        starting_ratio: 0
                    }
                };
            }
            break;
        }
    }


    show_debug_message(
        "VECTOR TD 2026 - ENERGY CONSUMER DEFAULTS APPLIED"
    );


    return true;
}

/// @description Returns the closest connected node belonging to a member.

function scr_energy_member_node_get(_member, _network)
{
    if (!instance_exists(_member))
        return noone;

    var _closest = noone;
    var _closest_distance = infinity;


    for (var i = 0; i < array_length(_network.nodes); ++i)
    {
        var _node = _network.nodes[i];

        if (!instance_exists(_node))
            continue;

        if (!scr_energy_connection_valid(_member, _node))
            continue;

        var _distance =
            point_distance(
                _member.x,
                _member.y,
                _node.x,
                _node.y
            );

        if (_distance < _closest_distance)
        {
            _closest = _node;
            _closest_distance = _distance;
        }
    }


    return _closest;
}


/// @description Draws every visible local energy network.

function scr_energy_overlay_draw()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level.energy))
        return false;


    var _system = global.vtd_level.energy;
    var _mode = _system.overlay.mode;

    if (_mode == EnergyOverlayMode.OFF)
        return true;


    for (var n = 0; n < array_length(_system.networks); ++n)
    {
        var _network = _system.networks[n];
        var _color = _network.color;


        switch (_network.state)
        {
            case EnergyNetworkState.OFFLINE:
                _color = c_gray;
            break;

            case EnergyNetworkState.DEFICIT:
                _color = c_red;
            break;

            case EnergyNetworkState.BATTERY:
                _color = make_color_rgb(255, 150, 40);
            break;
        }


        draw_set_alpha(0.7);
        draw_set_color(_color);


        // Draw node-to-node backbone connections once.

        for (var i = 0; i < array_length(_network.nodes); ++i)
        {
            var _first = _network.nodes[i];

            if (!instance_exists(_first))
                continue;

            for (var j = i + 1; j < array_length(_network.nodes); ++j)
            {
                var _second = _network.nodes[j];

                if (
                    instance_exists(_second)
                    && scr_energy_connection_valid(_first, _second)
                )
                {
                    draw_line(
                        _first.x,
                        _first.y,
                        _second.x,
                        _second.y
                    );
                }
            }
        }


        // Attach each non-node member to its closest valid node.

        for (var m = 0; m < array_length(_network.members); ++m)
        {
            var _member = _network.members[m];

            if (!instance_exists(_member))
                continue;

            if (_member.energy.role == EnergyRole.NODE)
                continue;

            var _node =
                scr_energy_member_node_get(
                    _member,
                    _network
                );

            if (!instance_exists(_node))
                continue;

            draw_line(
                _member.x,
                _member.y,
                _node.x,
                _node.y
            );
        }


        // Detailed mode also exposes each node's connection radius.

        if (_mode == EnergyOverlayMode.DETAILED)
        {
            draw_set_alpha(0.15);

            for (var r = 0; r < array_length(_network.nodes); ++r)
            {
                var _range_node = _network.nodes[r];

                if (!instance_exists(_range_node))
                    continue;

                draw_circle(
                    _range_node.x,
                    _range_node.y,
                    _range_node.energy.connection_range,
                    false
                );
            }


            draw_set_alpha(1);

            if (array_length(_network.nodes) > 0)
            {
                var _label_node = _network.nodes[0];

                if (instance_exists(_label_node))
                {
                    draw_text(
                        _label_node.x + 14,
                        _label_node.y + 14,
                        "GRID "
                        + string(_network.id + 1)
                        + " | IN "
                        + string_format(_network.generation, 0, 1)
                        + " | OUT "
                        + string_format(_network.demand, 0, 1)
                        + " | BAT "
                        + string(floor(_network.stored))
                        + "/"
                        + string(floor(_network.storage_maximum))
                    );
                }
            }
        }
    }


    // Draw private building capacitors after network lines so the bars
	// remain clearly visible above the overlay.

	scr_energy_buffers_draw(
	    _mode == EnergyOverlayMode.DETAILED
	);


	draw_set_alpha(1);
	draw_set_color(c_white);

	return true;
}

/// @description Draws one building's internal energy-buffer bar.

function scr_energy_buffer_draw(_building, _detailed = false)
{
    if (!instance_exists(_building))
        return false;

    if (!_building.energy.participates)
        return false;

    if (_building.energy.buffer.maximum <= 0)
        return false;


    var _ratio =
        clamp(
            _building.energy.buffer.current
            / _building.energy.buffer.maximum,
            0,
            1
        );


    var _cell_size =
        global.vtd_level.map.cell_size;

    var _building_half_width =
        (_building.footprint.width_cells * _cell_size)
        * 0.5;

    var _building_half_height =
        (_building.footprint.height_cells * _cell_size)
        * 0.5;


    var _bar_width = 7;

    var _bar_height =
        max(
            24,
            (_building_half_height * 2) - 10
        );

    var _left =
        _building.x
        + _building_half_width
        + 5;

    var _right =
        _left
        + _bar_width;

    var _top =
        _building.y
        - (_bar_height * 0.5);

    var _bottom =
        _building.y
        + (_bar_height * 0.5);

    var _fill_top =
        lerp(
            _bottom,
            _top,
            _ratio
        );


    var _color = c_aqua;

    if (!_building.energy.connected)
        _color = c_red;
    else if (_ratio <= 0.2)
        _color = make_color_rgb(255, 100, 40);
    else if (_ratio <= 0.5)
        _color = c_yellow;


    // Dark capacitor background.

    draw_set_alpha(0.8);
    draw_set_color(c_black);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    // Stored energy.

    draw_set_alpha(0.9);
    draw_set_color(_color);

    draw_rectangle(
        _left + 1,
        _fill_top,
        _right - 1,
        _bottom - 1,
        false
    );


    // Vector outline and capacity marks.

    draw_set_alpha(1);
    draw_set_color(_color);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        true
    );

    draw_line(
        _left,
        _building.y,
        _right,
        _building.y
    );


    if (_detailed)
    {
        draw_text(
            _right + 4,
            _top,
            string_format(
                _building.energy.buffer.current,
                0,
                1
            )
            + "/"
            + string_format(
                _building.energy.buffer.maximum,
                0,
                1
            )
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws internal buffers for every participating building.

function scr_energy_buffers_draw(_detailed = false)
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

        scr_energy_buffer_draw(
            _building,
            _detailed
        );
    }


    return true;
}

/// @description Updates one consumer's recent activity-demand rate.

function scr_energy_activity_rate_update(_consumer, _delta)
{
    if (!instance_exists(_consumer))
        return 0;


    var _demand =
        _consumer.energy.demand;

    var _instant_rate =
        _demand.activity_spent
        / max(0.0001, _delta);


    // Smooth short spikes so cannon and sniper shots remain readable
    // in the HUD instead of appearing for only one frame.

    var _smoothing =
        clamp(
            _delta * 4,
            0,
            1
        );


    _demand.activity_recent_per_second =
        lerp(
            _demand.activity_recent_per_second,
            _instant_rate,
            _smoothing
        );


    _demand.activity_spent = 0;


    if (_demand.activity_recent_per_second < 0.01)
        _demand.activity_recent_per_second = 0;


    return _demand.activity_recent_per_second;
}

/// @description Ensures the energy-alert runtime exists.

function scr_energy_alert_runtime_ensure()
{
    var _system =
        global.vtd_level.energy;

    if (variable_struct_exists(_system, "alerts"))
        return true;


    _system.alerts =
    {
        cooldown_remaining: 0,
        cooldown_seconds: 3,

        // States are stored by a network's primary-node instance ID.
        states: {}
    };


    return true;
}


/// @description Returns a reasonably stable identifier for one local network.

function scr_energy_network_alert_key_get(_network)
{
    if (!is_struct(_network))
        return "";

    if (array_length(_network.nodes) <= 0)
        return "";


    var _lowest_id = infinity;


    for (var i = 0; i < array_length(_network.nodes); ++i)
    {
        var _node = _network.nodes[i];

        if (!instance_exists(_node))
            continue;

        _lowest_id =
            min(
                _lowest_id,
                real(_node.id)
            );
    }


    if (_lowest_id == infinity)
        return "";


    return "grid_"
        + string(floor(_lowest_id));
}


/// @description Returns readable local-network state text.

function scr_energy_network_state_text(_state)
{
    switch (_state)
    {
        case EnergyNetworkState.OFFLINE:
            return "OFFLINE";

        case EnergyNetworkState.DEFICIT:
            return "DEFICIT";

        case EnergyNetworkState.BATTERY:
            return "BATTERY SUPPORT";

        case EnergyNetworkState.BALANCED:
            return "BALANCED";

        case EnergyNetworkState.SURPLUS:
            return "SURPLUS";
    }


    return "UNKNOWN";
}


/// @description Sends one throttled energy-network alert.

function scr_energy_alert_send(
    _type,
    _title,
    _message
)
{
    var _alerts =
        global.vtd_level.energy.alerts;

    if (_alerts.cooldown_remaining > 0)
        return false;


    if (
        !scr_hud_alert_push(
            _type,
            _title,
            _message,
            2.5
        )
    )
    {
        return false;
    }


    _alerts.cooldown_remaining =
        _alerts.cooldown_seconds;


    return true;
}


/// @description Detects and reports important state changes in one network.

function scr_energy_network_alert_update(_network)
{
    if (!is_struct(_network))
        return false;


    var _system =
        global.vtd_level.energy;

    var _alerts =
        _system.alerts;

    var _key =
        scr_energy_network_alert_key_get(
            _network
        );


    if (_key == "")
        return false;


    // The first observation establishes a baseline without producing
    // an alert when the level initially creates its networks.

    if (!variable_struct_exists(_alerts.states, _key))
    {
        variable_struct_set(
            _alerts.states,
            _key,
            {
                state: _network.state,
                stored: _network.stored
            }
        );

        return true;
    }


    var _record =
        variable_struct_get(
            _alerts.states,
            _key
        );

    var _previous_state =
        _record.state;

    var _previous_stored =
        _record.stored;


    // Store the new state even when the global alert throttle suppresses
    // its message. This prevents an old transition firing much later.

    _record.state =
        _network.state;

    _record.stored =
        _network.stored;


    // Battery depletion is more important than a general state change.

    var _battery_depleted =
        _previous_stored > 0
        && _network.stored <= 0
        && (
            _network.state == EnergyNetworkState.DEFICIT
            || _network.state == EnergyNetworkState.OFFLINE
        );


    if (_battery_depleted)
    {
        return scr_energy_alert_send(
            HudAlertType.DANGER,
            "BATTERY RESERVE DEPLETED",
            "GRID "
            + string(_network.id + 1)
            + " // LOAD SHEDDING EXPECTED"
        );
    }


    if (_previous_state == _network.state)
        return true;


    switch (_network.state)
    {
        case EnergyNetworkState.OFFLINE:
        {
            return scr_energy_alert_send(
                HudAlertType.DANGER,
                "ENERGY NETWORK OFFLINE",
                "GRID "
                + string(_network.id + 1)
                + " // NO ACTIVE SUPPLY"
            );
        }


        case EnergyNetworkState.DEFICIT:
        {
            return scr_energy_alert_send(
                HudAlertType.WARNING,
                "LOCAL GRID DEFICIT",
                "GRID "
                + string(_network.id + 1)
                + " // PRIORITY DISTRIBUTION ACTIVE"
            );
        }


        case EnergyNetworkState.BATTERY:
        {
            return scr_energy_alert_send(
                HudAlertType.WARNING,
                "BATTERY SUPPORT ACTIVE",
                "GRID "
                + string(_network.id + 1)
                + " // RESERVES DISCHARGING"
            );
        }


        case EnergyNetworkState.BALANCED:
        case EnergyNetworkState.SURPLUS:
        {
            var _previously_unhealthy =
                _previous_state == EnergyNetworkState.OFFLINE
                || _previous_state == EnergyNetworkState.DEFICIT
                || _previous_state == EnergyNetworkState.BATTERY;


            if (_previously_unhealthy)
            {
                return scr_energy_alert_send(
                    HudAlertType.SUCCESS,
                    "ENERGY NETWORK RECOVERED",
                    "GRID "
                    + string(_network.id + 1)
                    + " // "
                    + scr_energy_network_state_text(
                        _network.state
                    )
                );
            }
        }
        break;
    }


    return true;
}

/// @description Collects every active energy participant.

function scr_energy_participants_get()
{
    var _participants = [];


    var _building_count =
        instance_number(o_building_par);

    for (var i = 0; i < _building_count; ++i)
    {
        var _building =
            instance_find(
                o_building_par,
                i
            );

        if (!instance_exists(_building))
            continue;

        if (!_building.energy.participates)
            continue;


        _building.energy.network_id = -1;
        _building.energy.connected = false;
        _building.energy.supplied = false;


        if (_building.BuildingState == BuildingState.ACTIVE)
        {
            array_push(
                _participants,
                _building
            );
        }
    }


    var _foundation_count =
        instance_number(o_foundation);

    for (var i = 0; i < _foundation_count; ++i)
    {
        var _foundation =
            instance_find(
                o_foundation,
                i
            );

        if (!instance_exists(_foundation))
            continue;

        if (!_foundation.energy.participates)
            continue;


        _foundation.energy.network_id = -1;
        _foundation.energy.connected = false;
        _foundation.energy.supplied = false;


        if (_foundation.BuildingState == BuildingState.ACTIVE)
        {
            array_push(
                _participants,
                _foundation
            );
        }
    }


    return _participants;
}