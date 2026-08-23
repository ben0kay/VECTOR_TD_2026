/// @description Resource storage initialization, delivery, drawing, and cleanup.


/// @description Returns or creates one level resource inventory entry.

function scr_storage_level_entry_get(_resource_key)
{
    if (!variable_global_exists("vtd_level"))
        return undefined;

    if (!is_struct(global.vtd_level))
        return undefined;


    if (!variable_struct_exists(global.vtd_level.resources, "entries"))
        global.vtd_level.resources.entries = {};


    var _entries = global.vtd_level.resources.entries;


    if (!variable_struct_exists(_entries, _resource_key))
    {
        variable_struct_set(
            _entries,
            _resource_key,
            {
                key: _resource_key,
                current: 0,
                capacity: 0
            }
        );
    }


    return variable_struct_get(_entries, _resource_key);
}


/// @description Initializes one data-driven storage building.

function scr_storage_initialize(_storage)
{
    if (!instance_exists(_storage))
        return false;


    var _data = _storage.building_data;

    if (!variable_struct_exists(_data, "storage"))
        return false;

    if (!is_struct(_data.storage))
        return false;


    var _resource_data =
        scr_resource_data_get(_data.storage.resource_key);

    if (!scr_resource_data_valid(_resource_data))
        return false;


    _storage.storage =
{
    resource_key: _data.storage.resource_key,

    current: 0,
    capacity: _data.storage.capacity,

    incoming_reserved: 0,
    registered: false
};


    var _entry =
        scr_storage_level_entry_get(
            _storage.storage.resource_key
        );

    if (!is_struct(_entry))
        return false;


    _entry.capacity += _storage.storage.capacity;
    _storage.storage.registered = true;


    show_debug_message(
        "STORAGE REGISTERED: "
        + _storage.identity.name
        + " | CAPACITY "
        + string(_storage.storage.capacity)
    );


    return true;
}

/// @description Returns unoccupied and unreserved storage capacity.

function scr_storage_available_space(_storage)
{
    if (!instance_exists(_storage))
        return 0;

    if (!variable_instance_exists(_storage, "storage"))
        return 0;


    return max(
        0,
        _storage.storage.capacity
        - _storage.storage.current
        - _storage.storage.incoming_reserved
    );
}


/// @description Returns whether an existing cargo destination remains valid.

function scr_storage_destination_valid(
    _storage,
    _resource_key
)
{
    if (!instance_exists(_storage))
        return false;

    if (!variable_instance_exists(_storage, "storage"))
        return false;

    if (_storage.BuildingState != BuildingState.ACTIVE)
        return false;

    return _storage.storage.resource_key == _resource_key;
}


/// @description Reserves storage space for incoming cargo.

function scr_storage_reservation_create(
    _storage,
    _resource_key,
    _amount
)
{
    if (!scr_storage_accepts(_storage, _resource_key))
        return 0;


    var _reserved = min(
        max(0, _amount),
        scr_storage_available_space(_storage)
    );


    _storage.storage.incoming_reserved += _reserved;

    return _reserved;
}


/// @description Releases a previous incoming-cargo reservation.

function scr_storage_reservation_release(
    _storage,
    _amount
)
{
    if (!instance_exists(_storage))
        return false;

    if (!variable_instance_exists(_storage, "storage"))
        return false;


    _storage.storage.incoming_reserved = max(
        0,
        _storage.storage.incoming_reserved
        - max(0, _amount)
    );


    return true;
}

/// @description Returns whether storage can reserve more of a resource.

function scr_storage_accepts(
    _storage,
    _resource_key
)
{
    if (!scr_storage_destination_valid(
        _storage,
        _resource_key
    ))
    {
        return false;
    }


    return scr_storage_available_space(_storage) > 0;
}


/// @description Returns the nearest compatible storage with free capacity.

function scr_storage_nearest_get(
    _source_x,
    _source_y,
    _resource_key
)
{
    var _closest = noone;
    var _closest_distance = infinity;
    var _count = instance_number(o_storage);


    // Only called when a drone needs a destination.

    for (var i = 0; i < _count; ++i)
    {
        var _storage = instance_find(o_storage, i);

        if (!scr_storage_accepts(_storage, _resource_key))
            continue;


        var _distance = point_distance(
            _source_x,
            _source_y,
            _storage.x,
            _storage.y
        );


        if (_distance < _closest_distance)
        {
            _closest = _storage;
            _closest_distance = _distance;
        }
    }


    return _closest;
}


/// @description Deposits reserved cargo and returns its remainder.

function scr_storage_receive(
    _storage,
    _resource_key,
    _amount,
    _reserved_amount
)
{
    if (!scr_storage_destination_valid(
        _storage,
        _resource_key
    ))
    {
        return _amount;
    }


    scr_storage_reservation_release(
        _storage,
        _reserved_amount
    );


    if (_amount <= 0)
        return 0;


    var _space =
        _storage.storage.capacity
        - _storage.storage.current;

    var _attempt = min(
        _amount,
        max(0, _reserved_amount)
    );

    var _accepted = min(
        _attempt,
        _space
    );


    _storage.storage.current += _accepted;


    var _entry =
        scr_storage_level_entry_get(_resource_key);

    if (is_struct(_entry))
        _entry.current += _accepted;


    return max(
        0,
        _amount - _accepted
    );
}


/// @description Draws one resource-specific storage building.

function scr_storage_draw(_storage)
{
    if (!instance_exists(_storage))
        return false;


    var _cell_size = global.vtd_level.map.cell_size;

    var _width =
        _storage.footprint.width_cells
        * _cell_size;

    var _height =
        _storage.footprint.height_cells
        * _cell_size;

    var _left = _storage.x - (_width * 0.5);
    var _right = _storage.x + (_width * 0.5);
    var _top = _storage.y - (_height * 0.5);
    var _bottom = _storage.y + (_height * 0.5);


    var _resource_data =
        scr_resource_data_get(
            _storage.storage.resource_key
        );

    var _resource_color = _storage.visual.color;

    if (scr_resource_data_valid(_resource_data))
        _resource_color = _resource_data.visual.color;


    // Inner storage chamber.

    draw_set_color(c_black);

    draw_rectangle(
        _left + 10,
        _top + 10,
        _right - 10,
        _bottom - 10,
        false
    );


    draw_set_color(_resource_color);

    draw_rectangle(
        _left + 14,
        _top + 14,
        _right - 14,
        _bottom - 14,
        true
    );


    // Capacity bar.

    var _percent = clamp(
        _storage.storage.current
        / max(1, _storage.storage.capacity),
        0,
        1
    );

    var _bar_left = _left + 10;
    var _bar_right = _right - 10;
    var _bar_top = _bottom - 9;
    var _bar_bottom = _bottom - 4;


    draw_set_color(c_black);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_right,
        _bar_bottom,
        false
    );


    draw_set_color(_resource_color);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left
            + ((_bar_right - _bar_left) * _percent),
        _bar_bottom,
        false
    );


    draw_set_color(c_white);

    return true;
}


/// @description Removes stored resources and capacity during destruction.

function scr_storage_cleanup(_storage)
{
    if (!instance_exists(_storage))
        return false;

    if (!variable_instance_exists(_storage, "storage"))
        return true;

    if (!_storage.storage.registered)
        return true;


    var _entry =
        scr_storage_level_entry_get(
            _storage.storage.resource_key
        );


    if (is_struct(_entry))
    {
        // Destroying storage currently destroys the resources inside it.

        _entry.current = max(
            0,
            _entry.current
            - _storage.storage.current
        );

        _entry.capacity = max(
            0,
            _entry.capacity
            - _storage.storage.capacity
        );
    }


    _storage.storage.registered = false;

    return true;
}