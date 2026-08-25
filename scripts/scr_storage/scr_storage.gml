/// @description Multi-compartment physical storage runtime.

function scr_storage_level_entry_get(_resource_key) { return scr_resource_level_entry_get(_resource_key); }

function scr_storage_compartment_get(_storage, _resource_key)
{
    if (!instance_exists(_storage)) return undefined;
    if (!variable_instance_exists(_storage, "storage")) return undefined;

    var _compartments = _storage.storage.compartments;
    for (var i = 0; i < array_length(_compartments); ++i)
    {
        if (_compartments[i].resource_key == _resource_key) return _compartments[i];
    }
    return undefined;
}

/// @description Initializes every physical compartment in one storage building.
function scr_storage_initialize(_storage)
{
    if (!instance_exists(_storage)) return false;
    var _data = _storage.building_data;
    if (!variable_struct_exists(_data, "storage") || !is_struct(_data.storage)) return false;

    var _definitions = [];
    if (variable_struct_exists(_data.storage, "compartments")) _definitions = _data.storage.compartments;
    else if (variable_struct_exists(_data.storage, "resource_key"))
        _definitions = [{ resource_key: _data.storage.resource_key, capacity: _data.storage.capacity }];

    if (!is_array(_definitions) || array_length(_definitions) <= 0) return false;

    _storage.storage = { compartments: [], registered: false };

    for (var i = 0; i < array_length(_definitions); ++i)
    {
        var _definition = _definitions[i];
        if (!is_struct(_definition)) return false;

        var _resource_data = scr_resource_data_get(_definition.resource_key);
        if (!scr_resource_data_valid(_resource_data)) return false;

        var _compartment = {
            resource_key: _definition.resource_key,
            current: 0,
            capacity: max(0, _definition.capacity),
            incoming_reserved: 0,
            outgoing_reserved: 0
        };

        array_push(_storage.storage.compartments, _compartment);
        var _entry = scr_storage_level_entry_get(_compartment.resource_key);
        if (!is_struct(_entry)) return false;
        _entry.capacity += _compartment.capacity;
    }

    _storage.storage.registered = true;
    return true;
}

function scr_storage_available_space(_storage, _resource_key)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return 0;
    return max(0, _compartment.capacity - _compartment.current - _compartment.incoming_reserved);
}

function scr_storage_available_amount(_storage, _resource_key)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return 0;
    return max(0, _compartment.current - _compartment.outgoing_reserved);
}

function scr_storage_destination_valid(_storage, _resource_key)
{
    if (!instance_exists(_storage)) return false;
    if (_storage.BuildingState != BuildingState.ACTIVE) return false;
    return is_struct(scr_storage_compartment_get(_storage, _resource_key));
}

function scr_storage_reservation_create(_storage, _resource_key, _amount)
{
    if (!scr_storage_destination_valid(_storage, _resource_key)) return 0;
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    var _reserved = min(max(0, _amount), scr_storage_available_space(_storage, _resource_key));
    _compartment.incoming_reserved += _reserved;
    return _reserved;
}

function scr_storage_reservation_release(_storage, _resource_key, _amount)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return false;
    _compartment.incoming_reserved = max(0, _compartment.incoming_reserved - max(0, _amount));
    return true;
}

function scr_storage_outgoing_reservation_create(_storage, _resource_key, _amount)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment) || _storage.BuildingState != BuildingState.ACTIVE) return 0;
    var _reserved = min(max(0, _amount), scr_storage_available_amount(_storage, _resource_key));
    _compartment.outgoing_reserved += _reserved;
    return _reserved;
}

function scr_storage_outgoing_reservation_release(_storage, _resource_key, _amount)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return false;
    _compartment.outgoing_reserved = max(0, _compartment.outgoing_reserved - max(0, _amount));
    return true;
}

function scr_storage_reserved_withdraw(_storage, _resource_key, _amount)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return 0;
    var _removed = min(max(0, _amount), _compartment.outgoing_reserved, _compartment.current);
    _compartment.outgoing_reserved -= _removed;
    _compartment.current -= _removed;
    var _entry = scr_storage_level_entry_get(_resource_key);
    if (is_struct(_entry)) _entry.current = max(0, _entry.current - _removed);
    return _removed;
}

function scr_storage_withdraw(_storage, _resource_key, _amount)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return 0;
    var _removed = min(max(0, _amount), scr_storage_available_amount(_storage, _resource_key));
    _compartment.current -= _removed;
    var _entry = scr_storage_level_entry_get(_resource_key);
    if (is_struct(_entry)) _entry.current = max(0, _entry.current - _removed);
    return _removed;
}

function scr_storage_accepts(_storage, _resource_key)
{
    return scr_storage_destination_valid(_storage, _resource_key)
        && scr_storage_available_space(_storage, _resource_key) > 0;
}

function scr_storage_nearest_get(_source_x, _source_y, _resource_key)
{
    var _closest = noone;
    var _closest_distance = infinity;
    var _count = instance_number(o_storage);

    for (var i = 0; i < _count; ++i)
    {
        var _storage = instance_find(o_storage, i);
        if (!scr_storage_accepts(_storage, _resource_key)) continue;
        var _distance = point_distance(_source_x, _source_y, _storage.x, _storage.y);
        if (_distance < _closest_distance) { _closest = _storage; _closest_distance = _distance; }
    }
    return _closest;
}

function scr_storage_nearest_source_get(_destination_x, _destination_y, _resource_key, _amount)
{
    var _closest = noone;
    var _closest_distance = infinity;
    var _count = instance_number(o_storage);

    for (var i = 0; i < _count; ++i)
    {
        var _storage = instance_find(o_storage, i);
        if (!instance_exists(_storage) || _storage.BuildingState != BuildingState.ACTIVE) continue;
        if (scr_storage_available_amount(_storage, _resource_key) <= 0) continue;
        var _distance = point_distance(_destination_x, _destination_y, _storage.x, _storage.y);
        if (_distance < _closest_distance) { _closest = _storage; _closest_distance = _distance; }
    }
    return _closest;
}

function scr_storage_receive(_storage, _resource_key, _amount, _reserved_amount)
{
    var _compartment = scr_storage_compartment_get(_storage, _resource_key);
    if (!is_struct(_compartment)) return _amount;
    scr_storage_reservation_release(_storage, _resource_key, _reserved_amount);
    var _accepted = min(max(0, _amount), max(0, _reserved_amount), _compartment.capacity - _compartment.current);
    _compartment.current += _accepted;
    var _entry = scr_storage_level_entry_get(_resource_key);
    if (is_struct(_entry)) _entry.current += _accepted;
    return max(0, _amount - _accepted);
}

function scr_storage_draw(_storage)
{
    if (!instance_exists(_storage)) return false;
    var _cell_size = global.vtd_level.map.cell_size;
    var _width = _storage.footprint.width_cells * _cell_size;
    var _height = _storage.footprint.height_cells * _cell_size;
    var _left = _storage.x - (_width * 0.5);
    var _right = _storage.x + (_width * 0.5);
    var _top = _storage.y - (_height * 0.5);
    var _bottom = _storage.y + (_height * 0.5);

    draw_set_color(c_black);
    draw_rectangle(_left + 10, _top + 10, _right - 10, _bottom - 10, false);

    var _compartments = _storage.storage.compartments;
    var _count = max(1, array_length(_compartments));
    var _bar_height = max(5, ((_height - 26) / _count) - 3);

    for (var i = 0; i < array_length(_compartments); ++i)
    {
        var _compartment = _compartments[i];
        var _data = scr_resource_data_get(_compartment.resource_key);
        var _color = scr_resource_data_valid(_data) ? _data.visual.color : _storage.visual.color;
        var _ratio = clamp(_compartment.current / max(1, _compartment.capacity), 0, 1);
        var _bar_top = _top + 14 + (i * (_bar_height + 3));
        draw_set_color(c_dkgray);
        draw_rectangle(_left + 14, _bar_top, _right - 14, _bar_top + _bar_height, false);
        draw_set_color(_color);
        draw_rectangle(_left + 14, _bar_top, _left + 14 + ((_width - 28) * _ratio), _bar_top + _bar_height, false);
    }
    draw_set_color(c_white);
    return true;
}

function scr_storage_cleanup(_storage)
{
    if (!instance_exists(_storage)) return false;
    if (!variable_instance_exists(_storage, "storage") || !_storage.storage.registered) return true;

    var _compartments = _storage.storage.compartments;
    for (var i = 0; i < array_length(_compartments); ++i)
    {
        var _compartment = _compartments[i];
        var _entry = scr_storage_level_entry_get(_compartment.resource_key);
        if (is_struct(_entry))
        {
            _entry.current = max(0, _entry.current - _compartment.current);
            _entry.capacity = max(0, _entry.capacity - _compartment.capacity);
        }
    }
    _storage.storage.registered = false;
    return true;
}

function scr_storage_totals_get(_storage)
{
    var _totals = { current: 0, capacity: 0, incoming: 0, outgoing: 0 };
    if (!instance_exists(_storage) || !variable_instance_exists(_storage, "storage")) return _totals;

    var _compartments = _storage.storage.compartments;
    for (var i = 0; i < array_length(_compartments); ++i)
    {
        _totals.current += _compartments[i].current;
        _totals.capacity += _compartments[i].capacity;
        _totals.incoming += _compartments[i].incoming_reserved;
        _totals.outgoing += _compartments[i].outgoing_reserved;
    }
    return _totals;
}
