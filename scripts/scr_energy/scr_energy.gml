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
            activity_cost: 0
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
    var _participants = [];
    var _building_count = instance_number(o_building_par);


    // Reset assignments and collect active participants.

    for (var i = 0; i < _building_count; ++i)
    {
        var _building = instance_find(o_building_par, i);

        if (!instance_exists(_building))
            continue;

        if (!_building.energy.participates)
            continue;


        _building.energy.network_id = -1;
        _building.energy.connected = false;


        if (_building.BuildingState == BuildingState.ACTIVE)
            array_push(_participants, _building);
    }


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

        _demand_rate += _idle_rate;


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


/// @description Updates every local network and aggregate HUD totals.

function scr_energy_update()
{
    if (!GAMEPLAY_ACTIVE)
        return false;

    var _system = global.vtd_level.energy;

    if (_system.dirty)
        scr_energy_networks_rebuild();


    var _delta =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _system.totals.generation = 0;
    _system.totals.demand = 0;
    _system.totals.stored = 0;
    _system.totals.storage_maximum = 0;
    _system.totals.deficient_networks = 0;


    for (var i = 0; i < array_length(_system.networks); ++i)
    {
        var _network = _system.networks[i];

        scr_energy_network_update(
            _network,
            _delta
        );

        _system.totals.generation += _network.generation;
        _system.totals.demand += _network.demand;
        _system.totals.stored += _network.stored;
        _system.totals.storage_maximum += _network.storage_maximum;

        if (
            _network.state == EnergyNetworkState.DEFICIT
            || _network.state == EnergyNetworkState.OFFLINE
        )
        {
            ++_system.totals.deficient_networks;
        }
    }


    _system.totals.net =
        _system.totals.generation
        - _system.totals.demand;


    return true;
}


/// @description Attempts to pay an activity cost from one building's buffer.

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

    return true;
}