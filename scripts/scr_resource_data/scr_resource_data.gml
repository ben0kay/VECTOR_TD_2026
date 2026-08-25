/// @description Data-driven raw resource definitions.


/// @description Registers every currency and physical resource definition.

function scr_resource_data_initialize()
{
    global.vtd.data.resources =
    {
        // ====================================================================
        // CURRENCY
        // ====================================================================

        resource_credits:
        {
            identity:
            {
                key: "resource_credits",
                name: "Credits",
                type: ResourceType.CURRENCY
            },

            visual:
            {
                sprite: -1,
                draw_function: undefined,
                color: c_aqua
            }
        },


        // ====================================================================
        // RAW MATERIALS
        // ====================================================================

        resource_carbon:
        {
            identity:
            {
                key: "resource_carbon",
                name: "Carbon",
                type: ResourceType.RAW_MATERIAL,
                refined_key: "resource_refined_carbon"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_resource_node_visual_crystal,
                color: make_color_rgb(90, 210, 120)
            },

            node:
            {
                amount_min: 700,
                amount_max: 1200
            },

            generation:
            {
                vein_size_min: 4,
                vein_size_max: 9
            }
        },


        resource_silicon:
        {
            identity:
            {
                key: "resource_silicon",
                name: "Silicon",
                type: ResourceType.RAW_MATERIAL,
                refined_key: "resource_refined_silicon"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_resource_node_visual_crystal,
                color: make_color_rgb(80, 190, 255)
            },

            node:
            {
                amount_min: 450,
                amount_max: 850
            },

            generation:
            {
                vein_size_min: 3,
                vein_size_max: 7
            }
        },


        resource_copper:
        {
            identity:
            {
                key: "resource_copper",
                name: "Copper",
                type: ResourceType.RAW_MATERIAL,
                refined_key: "resource_refined_copper"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_resource_node_visual_crystal,
                color: make_color_rgb(230, 125, 65)
            },

            node:
            {
                amount_min: 550,
                amount_max: 950
            },

            generation:
            {
                vein_size_min: 3,
                vein_size_max: 8
            }
        },


        // ====================================================================
        // REFINED MATERIALS
        // ====================================================================

        resource_refined_carbon:
        {
            identity:
            {
                key: "resource_refined_carbon",
                name: "Refined Carbon",
                type: ResourceType.REFINED_MATERIAL
            },

            visual:
            {
                sprite: -1,
                draw_function: undefined,
                color: make_color_rgb(145, 255, 170)
            }
        },


        resource_refined_silicon:
        {
            identity:
            {
                key: "resource_refined_silicon",
                name: "Refined Silicon",
                type: ResourceType.REFINED_MATERIAL
            },

            visual:
            {
                sprite: -1,
                draw_function: undefined,
                color: make_color_rgb(145, 225, 255)
            }
        },


        resource_refined_copper:
        {
            identity:
            {
                key: "resource_refined_copper",
                name: "Refined Copper",
                type: ResourceType.REFINED_MATERIAL
            },

            visual:
            {
                sprite: -1,
                draw_function: undefined,
                color: make_color_rgb(255, 175, 105)
            }
        },
		
		bullets:
		{
		    identity:
		    {
		        key: "bullets",
		        name: "Bullets"
		    },

		    inputs:
		    [{
		        resource_key: "resource_refined_copper",
		        amount: 1
		    }],

		    outputs:
		    [{
		        resource_key: "resource_bullets",
		        amount: 100
		    }],

		    production:
		    {
		        time_seconds: 10,
		        energy_per_second: 5
		    }
		},


		explosives:
		{
		    identity:
		    {
		        key: "explosives",
		        name: "Explosives"
		    },

		    inputs:
		    [{
		        resource_key: "resource_refined_carbon",
		        amount: 1
		    }],

		    outputs:
		    [{
		        resource_key: "resource_explosives",
		        amount: 20
		    }],

		    production:
		    {
		        time_seconds: 15,
		        energy_per_second: 8
		    }
		},
		
		
		// ====================================================================
		// AMMUNITION
		// ====================================================================

		resource_bullets:
		{
		    identity:
		    {
		        key: "resource_bullets",
		        name: "Bullets",
		        type: ResourceType.AMMUNITION
		    },

		    visual:
		    {
		        sprite: -1,
		        draw_function: undefined,
		        color: c_yellow
		    }
		},


		resource_explosives:
		{
		    identity:
		    {
		        key: "resource_explosives",
		        name: "Explosives",
		        type: ResourceType.AMMUNITION
		    },

		    visual:
		    {
		        sprite: -1,
		        draw_function: undefined,
		        color: c_orange
		    }
		}
    };
	
	


    show_debug_message(
        "VECTOR TD 2026 - RESOURCE DATA INITIALIZED"
    );

    return true;
}


/// @description Returns one raw resource definition.

function scr_resource_data_get(_resource_key)
{
    if (!is_string(_resource_key))
        return undefined;

    if (_resource_key == "")
        return undefined;

    if (!variable_struct_exists(global.vtd.data.resources, _resource_key))
    {
        show_debug_message(
            "RESOURCE DATA ERROR - unknown key: " + _resource_key
        );

        return undefined;
    }


    return variable_struct_get(
        global.vtd.data.resources,
        _resource_key
    );
}


/// @description Returns whether a resource definition contains valid data.

function scr_resource_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!variable_struct_exists(_data, "identity"))
        return false;

    if (!variable_struct_exists(_data, "visual"))
        return false;

    if (!is_struct(_data.identity))
        return false;

    if (!is_struct(_data.visual))
        return false;

    if (!variable_struct_exists(_data.identity, "key"))
        return false;

    if (!variable_struct_exists(_data.identity, "name"))
        return false;

    if (!variable_struct_exists(_data.identity, "type"))
        return false;

    if (!is_string(_data.identity.key))
        return false;

    if (_data.identity.key == "")
        return false;


    switch (_data.identity.type)
    {
        case ResourceType.CURRENCY:
        {
            // Currency exists only in the level economy.
            // It does not spawn as a physical world deposit.

            return true;
        }


        case ResourceType.RAW_MATERIAL:
        {
            if (!variable_struct_exists(_data, "node"))
                return false;

            if (!variable_struct_exists(_data, "generation"))
                return false;

            if (!is_struct(_data.node))
                return false;

            if (!is_struct(_data.generation))
                return false;

            if (_data.node.amount_min <= 0)
                return false;

            if (_data.node.amount_max < _data.node.amount_min)
                return false;

            if (_data.generation.vein_size_min <= 0)
                return false;

            if (
                _data.generation.vein_size_max
                < _data.generation.vein_size_min
            )
            {
                return false;
            }

            return true;
        }


        case ResourceType.REFINED_MATERIAL:
            return true;
    }


    return false;
}

/// @description Returns or creates one level resource entry.

function scr_resource_level_entry_get(_resource_key)
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
        var _data = scr_resource_data_get(_resource_key);

        if (!scr_resource_data_valid(_data))
            return undefined;

        variable_struct_set(
            _entries,
            _resource_key,
            {
                key: _resource_key,
                type: _data.identity.type,

                current: 0,
                capacity: 0,

                unlimited_capacity:
                    _data.identity.type
                    == ResourceType.CURRENCY
            }
        );
    }


    return variable_struct_get(_entries, _resource_key);
}

/// @description Initializes the level economy from one world definition.

function scr_resource_level_initialize(_world_data)
{
    if (!is_struct(_world_data))
        return false;


    global.vtd_level.resources =
    {
        entries: {}
    };


    // Register every known resource so the HUD has stable ordering.

    var _resource_keys =
        variable_struct_get_names(
            global.vtd.data.resources
        );


    for (var i = 0; i < array_length(_resource_keys); ++i)
    {
        scr_resource_level_entry_get(
            _resource_keys[i]
        );
    }


    if (!variable_struct_exists(_world_data, "starting_resources"))
        return true;

    if (!is_array(_world_data.starting_resources))
        return false;


    for (
        var i = 0;
        i < array_length(_world_data.starting_resources);
        ++i
    )
    {
        var _starting =
            _world_data.starting_resources[i];

        if (!is_struct(_starting))
            continue;

        if (!variable_struct_exists(_starting, "resource_key"))
            continue;

        if (!variable_struct_exists(_starting, "amount"))
            continue;


        var _entry =
            scr_resource_level_entry_get(
                _starting.resource_key
            );

        if (!is_struct(_entry))
            continue;


        _entry.current =
            max(0, _starting.amount);


        // Physical resources normally gain capacity from storage buildings.
        // Starting physical materials receive enough temporary capacity to exist.

        if (!_entry.unlimited_capacity)
        {
            _entry.capacity =
                max(
                    _entry.capacity,
                    _entry.current
                );
        }
    }


    return true;
}

/// @description Returns the available amount of one level resource.

function scr_resource_amount_get(_resource_key)
{
    var _entry =
        scr_resource_level_entry_get(
            _resource_key
        );

    if (!is_struct(_entry))
        return 0;

    return _entry.current;
}


/// @description Returns material not already reserved for logistics.

function scr_resource_available_get(_resource_key)
{
    var _data = scr_resource_data_get(_resource_key);
    if (!scr_resource_data_valid(_data)) return 0;

    if (_data.identity.type == ResourceType.CURRENCY)
        return scr_resource_amount_get(_resource_key);

    var _available = 0;
    var _count = instance_number(o_storage);

    for (var i = 0; i < _count; ++i)
        _available += scr_storage_available_amount(instance_find(o_storage, i), _resource_key);

    return _available;
}

/// @description Adds an amount to one level resource.

function scr_resource_amount_add(_resource_key, _amount)
{
    if (_amount <= 0)
        return 0;


    var _entry =
        scr_resource_level_entry_get(
            _resource_key
        );

    if (!is_struct(_entry))
        return 0;


    var _accepted = _amount;

    if (!_entry.unlimited_capacity)
    {
        _accepted =
            min(
                _amount,
                max(
                    0,
                    _entry.capacity
                    - _entry.current
                )
            );
    }


    _entry.current += _accepted;

    return _accepted;
}

/// @description Returns whether the level can afford a cost array.

function scr_resource_cost_can_afford(_cost)
{
    if (!is_array(_cost))
        return false;


    for (var i = 0; i < array_length(_cost); ++i)
    {
        var _entry = _cost[i];

        if (!is_struct(_entry))
            return false;

        if (!variable_struct_exists(_entry, "resource_key"))
            return false;

        if (!variable_struct_exists(_entry, "amount"))
            return false;

        if (_entry.amount < 0)
            return false;

        if (
            scr_resource_available_get(_entry.resource_key)
            < _entry.amount
        )
        {
            return false;
        }
    }


    return true;
}

/// @description Removes an amount from one level resource.

function scr_resource_amount_remove(_resource_key, _amount)
{
    if (_amount <= 0)
        return true;


    var _entry =
        scr_resource_level_entry_get(
            _resource_key
        );

    if (!is_struct(_entry))
        return false;

    if (_entry.current < _amount)
        return false;


    var _resource_data =
        scr_resource_data_get(_resource_key);

    if (!scr_resource_data_valid(_resource_data))
        return false;


    // Currency has no physical storage instances.

    if (
        _resource_data.identity.type
        == ResourceType.CURRENCY
    )
    {
        _entry.current -= _amount;
        return true;
    }

    if (scr_resource_available_get(_resource_key) < _amount)
        return false;


    // Physical materials are removed from their actual storage buildings.

    var _remaining = _amount;
    var _storage_count = instance_number(o_storage);


    for (var i = 0; i < _storage_count; ++i)
    {
        var _storage = instance_find(o_storage, i);

        if (!instance_exists(_storage))
            continue;

        var _removed = scr_storage_withdraw(
            _storage,
            _resource_key,
            _remaining
        );

        _remaining -= _removed;


        if (_remaining <= 0)
            break;
    }


    if (_remaining > 0)
        return false;


    return true;
}

/// @description Pays a complete building cost after affordability is confirmed.

function scr_resource_cost_pay(_cost)
{
    if (!scr_resource_cost_can_afford(_cost))
        return false;


    for (var i = 0; i < array_length(_cost); ++i)
    {
        var _entry = _cost[i];

        if (
            !scr_resource_amount_remove(
                _entry.resource_key,
                _entry.amount
            )
        )
        {
            show_debug_message(
                "RESOURCE PAYMENT ERROR - deduction failed: "
                + _entry.resource_key
            );

            return false;
        }
    }


    return true;
}

/// @description Refunds a previously paid building cost.

function scr_resource_cost_refund(_cost)
{
    if (!is_array(_cost))
        return false;


    for (var i = 0; i < array_length(_cost); ++i)
    {
        var _entry = _cost[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "resource_key"))
            continue;

        if (!variable_struct_exists(_entry, "amount"))
            continue;

        scr_resource_amount_add(
            _entry.resource_key,
            _entry.amount
        );
    }


    return true;
}
