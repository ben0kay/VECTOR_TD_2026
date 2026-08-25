/// @description Data-driven refinery production and cargo delivery.

function scr_refinery_initialize(_refinery)
{
    if (!instance_exists(_refinery)) return false;
    var _data = _refinery.building_data;
    if (!variable_struct_exists(_data, "refinery") || !is_struct(_data.refinery)) return false;

    _refinery.production = {
        state: ProductionState.IDLE,
        resume_state: ProductionState.IDLE,
        selected_recipe_key: "",
        queued_recipe_key: "",
        auto_mode: true,
        progress: 0,
        duration: 0,
        inputs: [],
        output: { resource_key: "", current: 0, capacity: 0, assigned_drone: noone },
        status_text: "SELECT RECIPE"
    };

    return true;
}

function scr_refinery_recipe_select(_refinery, _recipe_key)
{
    if (!instance_exists(_refinery)) return false;
    var _recipe = scr_recipe_data_get(_recipe_key);
    if (!scr_recipe_data_valid(_recipe)) return false;

    var _allowed = _refinery.building_data.refinery.recipes;
    var _recipe_allowed = false;

    for (var i = 0; i < array_length(_allowed); ++i)
    {
        if (_allowed[i] == _recipe_key)
        {
            _recipe_allowed = true;
            break;
        }
    }

    if (!_recipe_allowed) return false;

    if (_refinery.production.state == ProductionState.REQUESTING_INPUT
        || _refinery.production.state == ProductionState.PROCESSING
        || _refinery.production.state == ProductionState.AWAITING_INPUT)
    {
        _refinery.production.queued_recipe_key = _recipe_key;
        _refinery.production.status_text = "RECIPE QUEUED";
        return true;
    }

    _refinery.production.selected_recipe_key = _recipe_key;
    _refinery.production.queued_recipe_key = "";
    _refinery.production.state = ProductionState.IDLE;
    _refinery.production.status_text = "READY";
    return scr_refinery_batch_prepare(_refinery);
}

function scr_refinery_batch_prepare(_refinery)
{
    var _production = _refinery.production;
    var _recipe = scr_recipe_data_get(_production.selected_recipe_key);
    if (!scr_recipe_data_valid(_recipe)) return false;

    var _output_definition = _recipe.outputs[0];
    var _buffer_batches = max(1, _refinery.building_data.refinery.output_buffer_batches);

    if (_production.output.resource_key != _output_definition.resource_key)
    {
        if (_production.output.current > 0) return false;
        _production.output.resource_key = _output_definition.resource_key;
        _production.output.capacity = _output_definition.amount * _buffer_batches;
    }

    if (_production.output.current + _output_definition.amount > _production.output.capacity)
    {
        _production.state = ProductionState.BLOCKED_OUTPUT;
        _production.status_text = "OUTPUT BUFFER FULL";
        return false;
    }

    _production.inputs = [];
    for (var i = 0; i < array_length(_recipe.inputs); ++i)
    {
        var _input = _recipe.inputs[i];
        array_push(_production.inputs, {
            resource_key: _input.resource_key,
            required: _input.amount,
            delivered: 0,
            assigned_drone: noone
        });
    }

    _production.progress = 0;
    _production.duration = _recipe.production.time_seconds;
    _production.state = ProductionState.REQUESTING_INPUT;
    _production.status_text = "REQUESTING MATERIALS";
    return true;
}

function scr_refinery_inputs_ready(_refinery)
{
    var _inputs = _refinery.production.inputs;
    if (array_length(_inputs) <= 0) return false;

    for (var i = 0; i < array_length(_inputs); ++i)
    {
        if (_inputs[i].delivered < _inputs[i].required) return false;
    }
    return true;
}

/// @description Receives production input through the shared production system.

function scr_refinery_input_receive(
    _building,
    _resource_key,
    _amount
)
{
    return scr_production_input_receive(
        _building,
        _resource_key,
        _amount
    );
}

function scr_refinery_input_requests_update(_refinery)
{
    var _inputs = _refinery.production.inputs;
    var _waiting = false;

    for (var i = 0; i < array_length(_inputs); ++i)
    {
        var _input = _inputs[i];
        if (_input.delivered >= _input.required) continue;

        if (instance_exists(_input.assigned_drone)) { _waiting = true; continue; }
        _input.assigned_drone = noone;

        var _needed = _input.required - _input.delivered;
        var _storage = scr_storage_nearest_source_get(_refinery.x, _refinery.y, _input.resource_key, _needed);
        if (!instance_exists(_storage)) continue;

        var _reserved = scr_storage_outgoing_reservation_create(_storage, _input.resource_key, _needed);
        if (_reserved <= 0) continue;

        var _drone = instance_create_layer(_storage.x, _storage.y, "Instances", o_cargo_drone, {
            cargo_job: CargoDroneJob.REFINERY_INPUT,
            source_storage: _storage,
            target_refinery: _refinery,
            cargo_resource_key: _input.resource_key,
            cargo_amount: _reserved
        });

        if (!instance_exists(_drone))
            scr_storage_outgoing_reservation_release(_storage, _input.resource_key, _reserved);
        else
        {
            _input.assigned_drone = _drone;
            _waiting = true;
        }
    }

    if (scr_refinery_inputs_ready(_refinery))
    {
        _refinery.production.state = ProductionState.PROCESSING;
        _refinery.production.status_text = "REFINING";
    }
    else
    {
        _refinery.production.state = ProductionState.AWAITING_INPUT;
        _refinery.production.status_text = _waiting ? "DELIVERY IN TRANSIT" : "INSUFFICIENT INPUT";
    }
    return true;
}

function scr_refinery_output_drone_request(_refinery)
{
    var _output = _refinery.production.output;
    if (_output.current <= 0 || instance_exists(_output.assigned_drone)) return false;

    var _storage = scr_storage_nearest_get(_refinery.x, _refinery.y, _output.resource_key);
    if (!instance_exists(_storage)) return false;

    var _amount = min(_output.current, scr_storage_available_space(_storage, _output.resource_key));
    var _reserved = scr_storage_reservation_create(_storage, _output.resource_key, _amount);
    if (_reserved <= 0) return false;

    _output.current -= _reserved;

    var _drone = instance_create_layer(_refinery.x, _refinery.y, "Instances", o_cargo_drone, {
        cargo_job: CargoDroneJob.REFINERY_OUTPUT,
        source_refinery: _refinery,
        target_storage: _storage,
        cargo_resource_key: _output.resource_key,
        cargo_amount: _reserved,
        cargo_reserved_amount: _reserved
    });

    if (!instance_exists(_drone))
    {
        _output.current += _reserved;
        scr_storage_reservation_release(_storage, _output.resource_key, _reserved);
        return false;
    }

    _output.assigned_drone = _drone;
    return true;
}

function scr_refinery_batch_complete(_refinery)
{
    var _production = _refinery.production;
    var _recipe = scr_recipe_data_get(_production.selected_recipe_key);
    var _output = _recipe.outputs[0];

    _production.output.current += _output.amount;
    _production.progress = _production.duration;
    _production.inputs = [];
    _production.state = ProductionState.OUTPUT_READY;
    _production.status_text = "OUTPUT READY";

    var _output_data = scr_resource_data_get(_output.resource_key);
    var _output_name = scr_resource_data_valid(_output_data)
        ? _output_data.identity.name
        : _output.resource_key;

    scr_hud_notification_push(
        "refinery_" + string(real(_refinery.id)),
        "REFINING COMPLETE",
        string(_output.amount) + " " + string_upper(_output_name),
        scr_resource_data_valid(_output_data) ? _output_data.visual.color : c_aqua,
        2.5
    );

    if (_production.queued_recipe_key != "")
    {
        _production.selected_recipe_key = _production.queued_recipe_key;
        _production.queued_recipe_key = "";
    }

    scr_refinery_output_drone_request(_refinery);
    return true;
}

function scr_refinery_update(_refinery)
{
    if (!instance_exists(_refinery)) return false;
    var _production = _refinery.production;

    if (_production.output.current > 0 && !instance_exists(_production.output.assigned_drone) && IFRAMES_30)
        scr_refinery_output_drone_request(_refinery);

    if (_refinery.BuildingState != BuildingState.ACTIVE)
    {
        if (_production.state != ProductionState.PAUSED)
            _production.resume_state = _production.state;

        _production.state = ProductionState.PAUSED;
        _production.status_text = "DISABLED";
        return true;
    }

    if (_production.state == ProductionState.PAUSED)
    {
        _production.state = _production.resume_state;
        _production.status_text = "RESUMING";
    }

    if (_production.selected_recipe_key == "")
    {
        _production.state = ProductionState.IDLE;
        _production.status_text = "SELECT RECIPE";
        return true;
    }

    switch (_production.state)
    {
        case ProductionState.IDLE:
        case ProductionState.OUTPUT_READY:
        case ProductionState.BLOCKED_OUTPUT:
        {
            if (_production.auto_mode)
                scr_refinery_batch_prepare(_refinery);
        }
        break;

        case ProductionState.REQUESTING_INPUT:
        case ProductionState.AWAITING_INPUT:
        {
            if (IFRAMES_30 || _production.state == ProductionState.REQUESTING_INPUT)
                scr_refinery_input_requests_update(_refinery);
        }
        break;

        case ProductionState.PROCESSING:
        {
            var _fps = max(1, game_get_speed(gamespeed_fps));
            var _recipe = scr_recipe_data_get(_production.selected_recipe_key);
            var _energy_cost = _recipe.production.energy_per_second / _fps;

            if (!scr_energy_activity_consume(_refinery, _energy_cost))
            {
                _production.status_text = "INSUFFICIENT ENERGY";
                break;
            }

            _production.status_text = "REFINING";
            _production.progress += 1 / _fps;
            if (_production.progress >= _production.duration) scr_refinery_batch_complete(_refinery);
        }
        break;
    }

    return true;
}

function scr_refinery_draw(_refinery)
{
    if (!instance_exists(_refinery)) return false;
    var _pulse = 0.65 + (sin((global.vtd.tick * 5) + real(_refinery.id)) * 0.2);
    draw_set_color(_refinery.visual.color);
    draw_circle(_refinery.x, _refinery.y, 30, true);
    draw_circle(_refinery.x, _refinery.y, 20, true);
    draw_set_alpha(_pulse);
    draw_circle(_refinery.x, _refinery.y, 10, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    return true;
}

function scr_refinery_cleanup(_refinery)
{
    if (!instance_exists(_refinery)) return false;
    if (!variable_instance_exists(_refinery, "production")) return true;

    var _inputs = _refinery.production.inputs;
    for (var i = 0; i < array_length(_inputs); ++i)
    {
        if (instance_exists(_inputs[i].assigned_drone)) instance_destroy(_inputs[i].assigned_drone);
    }

    if (instance_exists(_refinery.production.output.assigned_drone))
        _refinery.production.output.assigned_drone = noone;

    return true;
}


/// @description Initializes a refinery-specific job on the shared cargo drone.

function scr_refinery_drone_initialize(_drone)
{
    if (!instance_exists(_drone)) return false;

    _drone.movement = { speed: 8, arrival_distance: 12 };
    _drone.visual = { draw_angle: 0, radius: 8, color: c_white };
    _drone.assignment = { source: noone, destination: noone, reserved_amount: 0 };
    _drone.cargo = { resource_key: _drone.cargo_resource_key, current: 0, capacity: max(1, _drone.cargo_amount) };

    var _resource_data = scr_resource_data_get(_drone.cargo.resource_key);
    if (scr_resource_data_valid(_resource_data)) _drone.visual.color = _resource_data.visual.color;

    switch (_drone.cargo_job)
    {
        case CargoDroneJob.REFINERY_INPUT:
        {
            if (!instance_exists(_drone.source_storage) || !instance_exists(_drone.target_refinery)) return false;

            _drone.assignment.source = _drone.source_storage;
            _drone.assignment.destination = _drone.target_refinery;
            _drone.cargo.current = scr_storage_reserved_withdraw(
                _drone.source_storage,
                _drone.cargo.resource_key,
                _drone.cargo_amount
            );

            if (_drone.cargo.current <= 0) return false;
            _drone.CargoDroneState = CargoDroneState.TO_REFINERY;
        }
        break;

        case CargoDroneJob.REFINERY_OUTPUT:
        {
            if (!instance_exists(_drone.source_refinery) || !instance_exists(_drone.target_storage)) return false;
            _drone.assignment.source = _drone.source_refinery;
            _drone.assignment.destination = _drone.target_storage;
            _drone.assignment.reserved_amount = _drone.cargo_reserved_amount;
            _drone.cargo.current = _drone.cargo_amount;
            _drone.CargoDroneState = CargoDroneState.TO_STORAGE;
        }
        break;
    }

    return true;
}


function scr_refinery_drone_update(_drone)
{
    if (!instance_exists(_drone)) return false;

    switch (_drone.cargo_job)
    {
        case CargoDroneJob.REFINERY_INPUT:
        {
            var _refinery = _drone.assignment.destination;
            if (!instance_exists(_refinery)) { instance_destroy(_drone); return false; }

            if (scr_logistics_drone_move_to(_drone, _refinery.x, _refinery.y))
            {
                _drone.cargo.current = scr_refinery_input_receive(
                    _refinery,
                    _drone.cargo.resource_key,
                    _drone.cargo.current
                );
                instance_destroy(_drone);
                return true;
            }
        }
        break;

        case CargoDroneJob.REFINERY_OUTPUT:
        {
            var _storage = _drone.assignment.destination;

            if (!scr_storage_destination_valid(_storage, _drone.cargo.resource_key))
            {
                if (instance_exists(_storage))
                    scr_storage_reservation_release(_storage, _drone.cargo.resource_key, _drone.assignment.reserved_amount);

                _storage = scr_storage_nearest_get(_drone.x, _drone.y, _drone.cargo.resource_key);
                if (!instance_exists(_storage)) return true;

                var _reserved = scr_storage_reservation_create(_storage, _drone.cargo.resource_key, _drone.cargo.current);
                if (_reserved <= 0) return true;

                _drone.assignment.destination = _storage;
                _drone.assignment.reserved_amount = _reserved;
            }

            if (scr_logistics_drone_move_to(_drone, _storage.x, _storage.y))
            {
                _drone.cargo.current = scr_storage_receive(
                    _storage,
                    _drone.cargo.resource_key,
                    _drone.cargo.current,
                    _drone.assignment.reserved_amount
                );

                if (_drone.cargo.current <= 0)
                {
                    var _source = _drone.assignment.source;
                    if (instance_exists(_source)) _source.production.output.assigned_drone = noone;
                    _drone.assignment.destination = noone;
                    _drone.assignment.reserved_amount = 0;
                    instance_destroy(_drone);
                    return true;
                }
            }
        }
        break;
    }

    return true;
}


function scr_refinery_drone_cleanup(_drone)
{
    if (!instance_exists(_drone)) return false;

    if (_drone.cargo_job == CargoDroneJob.REFINERY_OUTPUT)
    {
        var _storage = _drone.assignment.destination;
        if (instance_exists(_storage))
            scr_storage_reservation_release(_storage, _drone.cargo.resource_key, _drone.assignment.reserved_amount);

        var _source = _drone.assignment.source;
        if (instance_exists(_source)) _source.production.output.assigned_drone = noone;
    }
    else if (_drone.cargo_job == CargoDroneJob.REFINERY_INPUT)
    {
        var _refinery = _drone.assignment.destination;
        if (instance_exists(_refinery))
        {
            var _inputs = _refinery.production.inputs;
            for (var i = 0; i < array_length(_inputs); ++i)
            {
                if (_inputs[i].assigned_drone == _drone) _inputs[i].assigned_drone = noone;
            }
        }
    }

    return true;
}
