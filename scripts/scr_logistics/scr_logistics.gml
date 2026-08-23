/// @description Miner collection requests and cargo-drone behaviour.


/// @description Initializes one cargo drone assigned to a miner.

function scr_logistics_drone_initialize(_drone)
{
    if (!instance_exists(_drone))
        return false;

    if (!variable_instance_exists(_drone, "source_miner"))
        return false;

    if (!instance_exists(_drone.source_miner))
        return false;


    var _source = _drone.source_miner;


    _drone.CargoDroneState =
        CargoDroneState.TO_SOURCE;


    _drone.assignment =
    {
        source: _source,
        destination: noone
    };


    _drone.movement =
    {
        speed: 8,
        arrival_distance: 12
    };


    _drone.cargo =
    {
        resource_key: _source.hopper.resource_key,
        current: 0,
        capacity: 40
    };


    var _resource_data =
        scr_resource_data_get(
            _drone.cargo.resource_key
        );


    _drone.visual =
    {
        draw_angle: 0,
        radius: 8,
        color: c_white
    };


    if (scr_resource_data_valid(_resource_data))
        _drone.visual.color = _resource_data.visual.color;


    _source.logistics.assigned_drone = _drone;
    _source.logistics.collection_reserved = true;


    return true;
}


/// @description Moves a cargo drone toward a world position.

function scr_logistics_drone_move_to(
    _drone,
    _target_x,
    _target_y
)
{
    var _distance = point_distance(
        _drone.x,
        _drone.y,
        _target_x,
        _target_y
    );


    if (_distance <= _drone.movement.arrival_distance)
        return true;


    var _direction = point_direction(
        _drone.x,
        _drone.y,
        _target_x,
        _target_y
    );


    _drone.visual.draw_angle = _direction;

    var _move_amount = min(
        _drone.movement.speed,
        _distance
    );

    _drone.x += lengthdir_x(_move_amount, _direction);
    _drone.y += lengthdir_y(_move_amount, _direction);


    return (
        point_distance(
            _drone.x,
            _drone.y,
            _target_x,
            _target_y
        )
        <= _drone.movement.arrival_distance
    );
}


/// @description Loads available material from the assigned miner.

function scr_logistics_drone_load(_drone)
{
    var _source = _drone.assignment.source;

    if (!instance_exists(_source))
        return false;


    var _space =
        _drone.cargo.capacity
        - _drone.cargo.current;

    var _loaded = min(
        _space,
        _source.hopper.current
    );


    if (_loaded <= 0)
        return false;


    _source.hopper.current -= _loaded;
    _drone.cargo.current += _loaded;


    return true;
}


/// @description Selects the nearest compatible storage destination.

function scr_logistics_drone_destination_find(_drone)
{
    var _storage = scr_storage_nearest_get(
        _drone.x,
        _drone.y,
        _drone.cargo.resource_key
    );


    _drone.assignment.destination = _storage;

    return instance_exists(_storage);
}


/// @description Processes one cargo drone's current state.

function scr_logistics_drone_update(_drone)
{
    if (!instance_exists(_drone))
        return false;


    var _source = _drone.assignment.source;


    switch (_drone.CargoDroneState)
    {
        case CargoDroneState.WAITING_SOURCE:
        {
            if (!instance_exists(_source))
            {
                instance_destroy(_drone);
                return false;
            }


            if (_source.hopper.current > 0)
                _drone.CargoDroneState = CargoDroneState.TO_SOURCE;
        }
        break;


        case CargoDroneState.TO_SOURCE:
        {
            if (!instance_exists(_source))
            {
                instance_destroy(_drone);
                return false;
            }


            if (
                scr_logistics_drone_move_to(
                    _drone,
                    _source.x,
                    _source.y
                )
            )
            {
                if (!scr_logistics_drone_load(_drone))
                {
                    _drone.CargoDroneState =
                        CargoDroneState.WAITING_SOURCE;

                    break;
                }


                if (scr_logistics_drone_destination_find(_drone))
                {
                    _drone.CargoDroneState =
                        CargoDroneState.TO_STORAGE;
                }
                else
                {
                    _drone.CargoDroneState =
                        CargoDroneState.WAITING_STORAGE;
                }
            }
        }
        break;


        case CargoDroneState.TO_STORAGE:
        {
            var _storage = _drone.assignment.destination;


            if (
                !scr_storage_accepts(
                    _storage,
                    _drone.cargo.resource_key
                )
            )
            {
                _drone.assignment.destination = noone;

                if (!scr_logistics_drone_destination_find(_drone))
                {
                    _drone.CargoDroneState =
                        CargoDroneState.WAITING_STORAGE;
                }

                break;
            }


            if (
                scr_logistics_drone_move_to(
                    _drone,
                    _storage.x,
                    _storage.y
                )
            )
            {
                _drone.cargo.current =
                    scr_storage_receive(
                        _storage,
                        _drone.cargo.resource_key,
                        _drone.cargo.current
                    );


                if (_drone.cargo.current > 0)
                {
                    _drone.assignment.destination = noone;
                    _drone.CargoDroneState =
                        CargoDroneState.WAITING_STORAGE;
                }
                else if (instance_exists(_source))
                {
                    _drone.assignment.destination = noone;
                    _drone.CargoDroneState =
                        CargoDroneState.TO_SOURCE;
                }
                else
                {
                    instance_destroy(_drone);
                    return false;
                }
            }
        }
        break;


        case CargoDroneState.WAITING_STORAGE:
        {
            // Avoid scanning every storage every frame.

            if (IFRAMES_30)
            {
                if (scr_logistics_drone_destination_find(_drone))
                {
                    _drone.CargoDroneState =
                        CargoDroneState.TO_STORAGE;
                }
            }
        }
        break;


        case CargoDroneState.DESTROYED:
        {
            instance_destroy(_drone);
            return false;
        }
        break;
    }


    return true;
}


/// @description Spawns a dedicated first-generation cargo drone for a miner.

function scr_logistics_drone_spawn(_miner)
{
    if (!instance_exists(_miner))
        return noone;

    if (instance_exists(_miner.logistics.assigned_drone))
        return _miner.logistics.assigned_drone;


    var _storage = scr_storage_nearest_get(
        _miner.x,
        _miner.y,
        _miner.hopper.resource_key
    );


    if (!instance_exists(_storage))
        return noone;


    var _drone = instance_create_layer(
        _miner.x,
        _miner.y,
        "Instances",
        o_cargo_drone,
        {
            source_miner: _miner
        }
    );


    return _drone;
}


/// @description Requests collection when a miner contains material.

function scr_logistics_miner_update(_miner)
{
    if (!instance_exists(_miner))
        return false;


    if (instance_exists(_miner.logistics.assigned_drone))
        return true;


    _miner.logistics.assigned_drone = noone;
    _miner.logistics.collection_reserved = false;


    if (_miner.hopper.current <= 0)
        return true;


    // Avoid searching for storage every frame while none exists.

    if (IFRAMES_30)
        scr_logistics_drone_spawn(_miner);


    return true;
}


/// @description Draws one vector-style cargo drone.

function scr_logistics_drone_draw(_drone)
{
    if (!instance_exists(_drone))
        return false;


    var _angle = _drone.visual.draw_angle;
    var _radius = _drone.visual.radius;


    draw_set_color(c_aqua);

    draw_line_width(
        _drone.x + lengthdir_x(_radius + 5, _angle + 180),
        _drone.y + lengthdir_y(_radius + 5, _angle + 180),
        _drone.x + lengthdir_x(_radius, _angle),
        _drone.y + lengthdir_y(_radius, _angle),
        2
    );


    draw_circle(
        _drone.x,
        _drone.y,
        _radius,
        false
    );


    if (_drone.cargo.current > 0)
    {
        draw_set_color(_drone.visual.color);

        draw_circle(
            _drone.x,
            _drone.y,
            4,
            false
        );
    }


    // Direction marker.

    draw_set_color(c_white);

    draw_line(
        _drone.x,
        _drone.y,
        _drone.x + lengthdir_x(_radius + 3, _angle),
        _drone.y + lengthdir_y(_radius + 3, _angle)
    );


    return true;
}


/// @description Releases a cargo drone's miner assignment.

function scr_logistics_drone_cleanup(_drone)
{
    if (!instance_exists(_drone))
        return false;

    if (!variable_instance_exists(_drone, "assignment"))
        return true;


    var _source = _drone.assignment.source;


    if (
        instance_exists(_source)
        && _source.logistics.assigned_drone == _drone
    )
    {
        _source.logistics.assigned_drone = noone;
        _source.logistics.collection_reserved = false;
    }


    return true;
}