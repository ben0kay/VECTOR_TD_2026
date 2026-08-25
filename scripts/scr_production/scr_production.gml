/// @description Shared recipe-driven production for refineries and fabricators.


/// @description Returns the production configuration for one building.

function scr_production_definition_get(_building)
{
    if (!instance_exists(_building))
        return undefined;

    var _data = _building.building_data;

    if (variable_struct_exists(_data, "refinery"))
        return _data.refinery;

    if (variable_struct_exists(_data, "fabricator"))
        return _data.fabricator;

    return undefined;
}


/// @description Initializes one generic production building.

function scr_production_initialize(_building)
{
    if (!instance_exists(_building))
        return false;

    var _definition =
        scr_production_definition_get(
            _building
        );

    if (!is_struct(_definition))
        return false;


    var _auto_starting = false;
    var _process_text = "PROCESSING";

    if (variable_struct_exists(_definition, "auto_mode_starting"))
        _auto_starting = _definition.auto_mode_starting;

    if (variable_struct_exists(_definition, "process_text"))
        _process_text = _definition.process_text;


    _building.production =
    {
        state: ProductionState.IDLE,
        resume_state: ProductionState.IDLE,

        selected_recipe_key: "",
        queued_recipe_key: "",

        queued_batches: 0,
        maximum_queued_batches: 99,

        auto_mode: _auto_starting,

        progress: 0,
        duration: 0,

        inputs: [],

        output:
        {
            resource_key: "",
            current: 0,
            capacity: 0,
            assigned_drone: noone
        },

        process_text: _process_text,
        status_text: "SELECT RECIPE"
    };


    return true;
}


/// @description Returns whether a recipe is allowed by one production building.

function scr_production_recipe_allowed(
    _building,
    _recipe_key
)
{
    if (!instance_exists(_building))
        return false;

    var _definition =
        scr_production_definition_get(
            _building
        );

    if (!is_struct(_definition))
        return false;


    for (var i = 0; i < array_length(_definition.recipes); ++i)
    {
        if (_definition.recipes[i] == _recipe_key)
            return true;
    }


    return false;
}


/// @description Selects a recipe without automatically beginning a batch.

function scr_production_recipe_select(
    _building,
    _recipe_key
)
{
    if (!instance_exists(_building))
        return false;

    var _recipe =
        scr_recipe_data_get(
            _recipe_key
        );

    if (!scr_recipe_data_valid(_recipe))
        return false;

    if (!scr_production_recipe_allowed(_building, _recipe_key))
        return false;


    var _production = _building.production;


    if (
        _production.state == ProductionState.PROCESSING
        || _production.state == ProductionState.REQUESTING_INPUT
        || _production.state == ProductionState.AWAITING_INPUT
    )
    {
        _production.queued_recipe_key = _recipe_key;
        _production.status_text = "RECIPE CHANGE QUEUED";

        return true;
    }


    _production.selected_recipe_key = _recipe_key;
    _production.queued_recipe_key = "";
    _production.status_text = "READY";


    return true;
}


/// @description Adds manual batches to a production building's queue.

function scr_production_batch_queue_add(
    _building,
    _amount
)
{
    if (!instance_exists(_building))
        return false;

    if (_building.production.selected_recipe_key == "")
        return false;


    _building.production.queued_batches =
        clamp(
            _building.production.queued_batches
            + max(0, floor(_amount)),

            0,
            _building.production.maximum_queued_batches
        );


    if (_building.production.state == ProductionState.IDLE)
        _building.production.status_text = "BATCH QUEUED";


    return true;
}


/// @description Prepares the next queued or automatic production batch.

function scr_production_batch_prepare(_building)
{
    if (!instance_exists(_building))
        return false;


    var _production = _building.production;

    var _recipe =
        scr_recipe_data_get(
            _production.selected_recipe_key
        );

    if (!scr_recipe_data_valid(_recipe))
        return false;


    var _definition =
        scr_production_definition_get(
            _building
        );

    var _output_definition = _recipe.outputs[0];

    var _buffer_batches =
        max(
            1,
            _definition.output_buffer_batches
        );


    if (
        _production.output.resource_key
        != _output_definition.resource_key
    )
    {
        if (_production.output.current > 0)
        {
            _production.state = ProductionState.BLOCKED_OUTPUT;
            _production.status_text = "CLEAR PREVIOUS OUTPUT";

            return false;
        }


        _production.output.resource_key =
            _output_definition.resource_key;

        _production.output.capacity =
            _output_definition.amount
            * _buffer_batches;
    }


    if (
        _production.output.current
        + _output_definition.amount
        > _production.output.capacity
    )
    {
        _production.state = ProductionState.BLOCKED_OUTPUT;
        _production.status_text = "OUTPUT BUFFER FULL";

        return false;
    }


    _production.inputs = [];


    for (var i = 0; i < array_length(_recipe.inputs); ++i)
    {
        var _input = _recipe.inputs[i];

        array_push(
            _production.inputs,
            {
                resource_key: _input.resource_key,
                required: _input.amount,
                delivered: 0,
                assigned_drone: noone
            }
        );
    }


    if (_production.queued_batches > 0)
        _production.queued_batches--;


    _production.progress = 0;
    _production.duration = _recipe.production.time_seconds;

    _production.state = ProductionState.REQUESTING_INPUT;
    _production.status_text = "REQUESTING MATERIALS";


    return true;
}


/// @description Returns whether every production input has arrived.

function scr_production_inputs_ready(_building)
{
    if (!instance_exists(_building))
        return false;


    var _inputs = _building.production.inputs;

    if (array_length(_inputs) <= 0)
        return false;


    for (var i = 0; i < array_length(_inputs); ++i)
    {
        if (_inputs[i].delivered < _inputs[i].required)
            return false;
    }


    return true;
}


/// @description Receives one cargo-drone production input.

function scr_production_input_receive(
    _building,
    _resource_key,
    _amount
)
{
    if (!instance_exists(_building))
        return _amount;


    var _inputs = _building.production.inputs;


    for (var i = 0; i < array_length(_inputs); ++i)
    {
        var _input = _inputs[i];

        if (_input.resource_key != _resource_key)
            continue;


        var _accepted =
            min(
                max(0, _amount),
                _input.required - _input.delivered
            );


        _input.delivered += _accepted;
        _input.assigned_drone = noone;


        return _amount - _accepted;
    }


    return _amount;
}


/// @description Requests missing production inputs from storage.

function scr_production_input_requests_update(_building)
{
    if (!instance_exists(_building))
        return false;


    var _inputs = _building.production.inputs;
    var _waiting = false;


    for (var i = 0; i < array_length(_inputs); ++i)
    {
        var _input = _inputs[i];

        if (_input.delivered >= _input.required)
            continue;


        if (instance_exists(_input.assigned_drone))
        {
            _waiting = true;
            continue;
        }


        _input.assigned_drone = noone;


        var _needed =
            _input.required
            - _input.delivered;


        var _storage =
            scr_storage_nearest_source_get(
                _building.x,
                _building.y,
                _input.resource_key,
                _needed
            );


        if (!instance_exists(_storage))
            continue;


        var _reserved =
            scr_storage_outgoing_reservation_create(
                _storage,
                _input.resource_key,
                _needed
            );


        if (_reserved <= 0)
            continue;


        // The existing refinery cargo job already moves arbitrary
        // resources between storage and a production instance.

        var _drone =
            instance_create_layer(
                _storage.x,
                _storage.y,
                "Instances",
                o_cargo_drone,
                {
                    cargo_job:
                        CargoDroneJob.REFINERY_INPUT,

                    source_storage:
                        _storage,

                    target_refinery:
                        _building,

                    cargo_resource_key:
                        _input.resource_key,

                    cargo_amount:
                        _reserved
                }
            );


        if (!instance_exists(_drone))
        {
            scr_storage_outgoing_reservation_release(
                _storage,
                _input.resource_key,
                _reserved
            );
        }
        else
        {
            _input.assigned_drone = _drone;
            _waiting = true;
        }
    }


    if (scr_production_inputs_ready(_building))
    {
        _building.production.state =
            ProductionState.PROCESSING;

        _building.production.status_text =
            _building.production.process_text;
    }
    else
    {
        _building.production.state =
            ProductionState.AWAITING_INPUT;

        _building.production.status_text =
            _waiting
            ? "DELIVERY IN TRANSIT"
            : "INSUFFICIENT INPUT";
    }


    return true;
}


/// @description Requests delivery of completed production output to storage.

function scr_production_output_drone_request(_building)
{
    if (!instance_exists(_building))
        return false;


    var _output = _building.production.output;


    if (
        _output.current <= 0
        || instance_exists(_output.assigned_drone)
    )
    {
        return false;
    }


    var _storage =
        scr_storage_nearest_get(
            _building.x,
            _building.y,
            _output.resource_key
        );


    if (!instance_exists(_storage))
        return false;


    var _amount =
        min(
            _output.current,

            scr_storage_available_space(
                _storage,
                _output.resource_key
            )
        );


    var _reserved =
        scr_storage_reservation_create(
            _storage,
            _output.resource_key,
            _amount
        );


    if (_reserved <= 0)
        return false;


    _output.current -= _reserved;


    var _drone =
        instance_create_layer(
            _building.x,
            _building.y,
            "Instances",
            o_cargo_drone,
            {
                cargo_job:
                    CargoDroneJob.REFINERY_OUTPUT,

                source_refinery:
                    _building,

                target_storage:
                    _storage,

                cargo_resource_key:
                    _output.resource_key,

                cargo_amount:
                    _reserved,

                cargo_reserved_amount:
                    _reserved
            }
        );


    if (!instance_exists(_drone))
    {
        _output.current += _reserved;

        scr_storage_reservation_release(
            _storage,
            _output.resource_key,
            _reserved
        );

        return false;
    }


    _output.assigned_drone = _drone;

    return true;
}


/// @description Completes one production batch.

function scr_production_batch_complete(_building)
{
    if (!instance_exists(_building))
        return false;


    var _production = _building.production;

    var _recipe =
        scr_recipe_data_get(
            _production.selected_recipe_key
        );


    if (!scr_recipe_data_valid(_recipe))
        return false;


    var _output = _recipe.outputs[0];


    _production.output.current +=
        _output.amount;

    _production.progress =
        _production.duration;

    _production.inputs = [];

    _production.state =
        ProductionState.OUTPUT_READY;

    _production.status_text =
        "OUTPUT READY";


    var _output_data =
        scr_resource_data_get(
            _output.resource_key
        );

    var _output_name =
        scr_resource_data_valid(_output_data)
        ? _output_data.identity.name
        : _output.resource_key;


    scr_hud_notification_push(
        "production_" + string(real(_building.id)),
        string_upper(_building.identity.name),
        string(_output.amount)
        + " "
        + string_upper(_output_name)
        + " COMPLETE",
        scr_resource_data_valid(_output_data)
        ? _output_data.visual.color
        : c_aqua,
        2.5
    );


    if (_production.queued_recipe_key != "")
    {
        _production.selected_recipe_key =
            _production.queued_recipe_key;

        _production.queued_recipe_key = "";
    }


    scr_production_output_drone_request(
        _building
    );


    return true;
}


/// @description Updates one shared production runtime.

function scr_production_update(_building)
{
    if (!instance_exists(_building))
        return false;


    var _production = _building.production;


    if (
        _production.output.current > 0
        && !instance_exists(_production.output.assigned_drone)
        && IFRAMES_30
    )
    {
        scr_production_output_drone_request(
            _building
        );
    }


    if (_building.BuildingState != BuildingState.ACTIVE)
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
            if (
                _production.queued_batches > 0
                || _production.auto_mode
            )
            {
                scr_production_batch_prepare(
                    _building
                );
            }
            else
            {
                _production.state =
                    ProductionState.IDLE;

                _production.status_text =
                    "READY";
            }
        }
        break;


        case ProductionState.REQUESTING_INPUT:
        case ProductionState.AWAITING_INPUT:
        {
            if (
                IFRAMES_30
                || _production.state
                == ProductionState.REQUESTING_INPUT
            )
            {
                scr_production_input_requests_update(
                    _building
                );
            }
        }
        break;


        case ProductionState.PROCESSING:
        {
            var _fps =
                max(
                    1,
                    game_get_speed(gamespeed_fps)
                );

            var _recipe =
                scr_recipe_data_get(
                    _production.selected_recipe_key
                );

            var _energy_cost =
                _recipe.production.energy_per_second
                / _fps;


            if (
                !scr_energy_activity_consume(
                    _building,
                    _energy_cost
                )
            )
            {
                _production.status_text =
                    "INSUFFICIENT ENERGY";

                break;
            }


            _production.status_text =
                _production.process_text;

            _production.progress +=
                1 / _fps;


            if (
                _production.progress
                >= _production.duration
            )
            {
                scr_production_batch_complete(
                    _building
                );
            }
        }
        break;
    }


    return true;
}


/// @description Cleans production drone assignments.

function scr_production_cleanup(_building)
{
    if (!instance_exists(_building))
        return false;

    if (!variable_instance_exists(_building, "production"))
        return true;


    var _inputs = _building.production.inputs;


    for (var i = 0; i < array_length(_inputs); ++i)
    {
        if (instance_exists(_inputs[i].assigned_drone))
            instance_destroy(_inputs[i].assigned_drone);
    }


    if (
        instance_exists(
            _building.production.output.assigned_drone
        )
    )
    {
        _building.production.output.assigned_drone =
            noone;
    }


    return true;
}