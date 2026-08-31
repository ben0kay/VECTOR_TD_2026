/// @description Data-driven building definitions and lookup.

/// @description Registers every non-tower building definition.

function scr_building_data_initialize()
{
    global.vtd.data.buildings =
    {
        // ====================================================================
        // WALL
        // ====================================================================

        wall_basic:
        {
            identity:
            {
                key: "wall_basic",
                name: "Basic Wall",
                type: BuildingType.WALL,

                description_short:
                    "Cheap barrier for controlling enemy movement.",

                description_long:
                    "A simple defensive wall used to protect important infrastructure and redirect ground enemies. Enemies may breach it when no open route remains."
            },

            visual:
            {
                color: c_fuchsia
            },

            footprint:
            {
                width_cells: 1,
                height_cells: 1
            },

            vitals:
            {
                hp_maximum: 200
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 10
                    }
                ]
            }
        },


        // ====================================================================
        // MINERS
        // ====================================================================

        miner_carbon:
        {
            identity:
            {
                key: "miner_carbon",
                name: "Carbon Miner",
                type: BuildingType.MINER,

                description_short:
                    "Extracts carbon from a matching deposit.",

                description_long:
                    "A resource extractor placed directly over a carbon deposit. Extracted material is held in its local hopper until a cargo drone transports it to compatible storage."
            },

            visual:
            {
                color: make_color_rgb(90, 210, 120)
            },

            footprint:
            {
                width_cells: 1,
                height_cells: 1
            },

            vitals:
            {
                hp_maximum: 180
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 100
                    }
                ]
            },

            miner:
            {
                resource_key: "resource_carbon",
                extraction_rate_per_second: 5,
                hopper_capacity: 100
            }
        },


        miner_silicon:
        {
            identity:
            {
                key: "miner_silicon",
                name: "Silicon Miner",
                type: BuildingType.MINER,

                description_short:
                    "Extracts silicon from a matching deposit.",

                description_long:
                    "A resource extractor placed directly over a silicon deposit. Extracted material is held in its local hopper until a cargo drone transports it to compatible storage."
            },

            visual:
            {
                color: make_color_rgb(80, 190, 255)
            },

            footprint:
            {
                width_cells: 1,
                height_cells: 1
            },

            vitals:
            {
                hp_maximum: 180
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 125
                    }
                ]
            },

            miner:
            {
                resource_key: "resource_silicon",
                extraction_rate_per_second: 4,
                hopper_capacity: 100
            }
        },


        miner_copper:
        {
            identity:
            {
                key: "miner_copper",
                name: "Copper Miner",
                type: BuildingType.MINER,

                description_short:
                    "Extracts copper from a matching deposit.",

                description_long:
                    "A resource extractor placed directly over a copper deposit. Extracted material is held in its local hopper until a cargo drone transports it to compatible storage."
            },

            visual:
            {
                color: make_color_rgb(230, 125, 65)
            },

            footprint:
            {
                width_cells: 1,
                height_cells: 1
            },

            vitals:
            {
                hp_maximum: 180
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 150
                    }
                ]
            },

            miner:
            {
                resource_key: "resource_copper",
                extraction_rate_per_second: 4.5,
                hopper_capacity: 100
            }
        },


        // ====================================================================
        // STORAGE
        // ====================================================================

        storage_carbon:
        {
            identity:
            {
                key: "storage_carbon",
                name: "Carbon Storage",
                type: BuildingType.STORAGE,

                description_short:
                    "Stores delivered carbon.",

                description_long:
                    "A dedicated carbon storage facility. Cargo drones deliver extracted carbon here before it becomes available to the level economy."
            },

            visual:
            {
                color: make_color_rgb(90, 210, 120)
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 350
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 75
                    }
                ]
            },

            storage:
            {
                compartments:
                [
                    { resource_key: "resource_carbon", capacity: 1000 },
                    { resource_key: "resource_refined_carbon", capacity: 100 }
                ]
            }
        },


        storage_silicon:
        {
            identity:
            {
                key: "storage_silicon",
                name: "Silicon Storage",
                type: BuildingType.STORAGE,

                description_short:
                    "Stores delivered silicon.",

                description_long:
                    "A dedicated silicon storage facility. Cargo drones deliver extracted silicon here before it becomes available to the level economy."
            },

            visual:
            {
                color: make_color_rgb(80, 190, 255)
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 350
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 90
                    }
                ]
            },

            storage:
            {
                compartments:
                [
                    { resource_key: "resource_silicon", capacity: 750 },
                    { resource_key: "resource_refined_silicon", capacity: 75 }
                ]
            }
        },


        storage_copper:
        {
            identity:
            {
                key: "storage_copper",
                name: "Copper Storage",
                type: BuildingType.STORAGE,

                description_short:
                    "Stores delivered copper.",

                description_long:
                    "A dedicated copper storage facility. Cargo drones deliver extracted copper here before it becomes available to the level economy."
            },

            visual:
            {
                color: make_color_rgb(230, 125, 65)
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 350
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost:
                [
                    {
                        resource_key: "resource_credits",
                        amount: 100
                    }
                ]
            },

            storage:
            {
                compartments:
                [
                    { resource_key: "resource_copper", capacity: 750 },
                    { resource_key: "resource_refined_copper", capacity: 75 }
                ]
            }
        },


        // ====================================================================
        // REFINERY
        // ====================================================================

        refinery_basic:
        {
            identity:
            {
                key: "refinery_basic",
                name: "Material Refinery",
                type: BuildingType.REFINERY,
                description_short: "Processes raw materials into refined resources.",
                description_long: "A flexible industrial processor. Select a recipe and cargo drones will collect raw inputs, deliver them here, and transport completed refined material back to compatible storage."
            },

            visual: { color: make_color_rgb(45, 145, 165) },
            footprint: { width_cells: 3, height_cells: 3 },
            vitals: { hp_maximum: 500 },
            construction: { time_seconds: 8 },
            economy:
            {
                cost: [{ resource_key: "resource_credits", amount: 500 }]
            },
            build_limit: { type: BuildLimitType.ECONOMY, amount: 2 },

            refinery:
            {
                recipes: ["refined_carbon", "refined_silicon", "refined_copper"],
                output_buffer_batches: 5,
                drone_speed: 8
            },

            energy:
            {
                role: EnergyRole.CONSUMER,
                priority: EnergyPriority.NORMAL,
                connection_range: 320,
                generation_per_second: 0,
                input_rate: 10,
                idle_demand: 1,
                activity_cost: 5,
                buffer: { capacity: 30, starting_ratio: 0 }
            }
        }
    };
	
	
	if (!scr_building_data_energy_generator())
    return false;

	if (!scr_building_data_energy_node())
	    return false;

	if (!scr_building_data_energy_battery())
	    return false;

	if (!scr_building_data_foundations_initialize())
    return false;
	
	if (!scr_building_data_utility_initialize())
    return false;

	if (!scr_building_data_fabricator())
    return false;
	
	if (!scr_building_data_ammunition_storage())
    return false;

    // FUTURE NON-TOWER BUILDINGS:
    // refinery
    // research centre
    // power generator
    // power node
    // battery
    // repair facility
    // drone hub


    show_debug_message(
        "VECTOR TD 2026 - BUILDING DATA INITIALIZED"
    );

    return true;
}

/// @description Creates one specialized capacity-hub definition.

function scr_building_hub_definition_create(
    _key,
    _name,
    _description_short,
    _color,
    _limit_type,
    _limit_amount
)
{
    return
    {
        identity:
        {
            key:
                _key,

            name:
                _name,

            type:
                BuildingType.SUPPORT,

            description_short:
                _description_short,

            description_long:
                "A specialized command facility that expands the number of structures your fortress can coordinate. Its bonus becomes available when construction finishes and is lost if the hub is destroyed. Existing structures remain operational if the base becomes over capacity."
        },

        visual:
        {
            color:
                _color
        },

        footprint:
        {
            width_cells: 2,
            height_cells: 2
        },

        vitals:
        {
            hp_maximum: 400
        },

        construction:
        {
            time_seconds: 6
        },

        economy:
        {
            cost:
            [
                {
                    resource_key:
                        "resource_credits",

                    amount:
                        500
                },

                {
                    resource_key:
                        "resource_carbon",

                    amount:
                        100
                }
            ]
        },

        // Every hub consumes one infrastructure slot.

        build_limit:
        {
            type:
                BuildLimitType.INFRASTRUCTURE,

            amount:
                1
        },

        // This is the capacity supplied when construction completes.

        hub:
        {
            limit_type:
                _limit_type,

            amount:
                _limit_amount
        },

        energy:
        {
            role:
                EnergyRole.CONSUMER,

            priority:
                EnergyPriority.HIGH,

            connection_range:
                320,

            generation_per_second:
                0,

            input_rate:
                8,

            idle_demand:
                0.5,

            activity_cost:
                0,

            buffer:
            {
                capacity:
                    25,

                starting_ratio:
                    0.5
            }
        }
    };
}


/// @description Registers every active utility building.

function scr_building_data_utility_initialize()
{
    if (!scr_building_data_utility_credit_magnet())
        return false;

    if (!scr_building_data_utility_repairer())
        return false;

    if (!scr_building_data_utility_credit_uplink())
        return false;
	
	if (!scr_building_data_utility_radar())
    return false;
	
	if (!scr_building_data_utility_shield_generator())
    return false;

    return true;
}

/// @description Registers all specialized capacity hubs.

function scr_building_hub_data_initialize()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "hub_tower",

        scr_building_hub_definition_create(
            "hub_tower",
            "Tower Operations Hub",
            "Adds 10 tower capacity.",
            c_yellow,
            BuildLimitType.TOWER,
            10
        )
    );


    variable_struct_set(
        global.vtd.data.buildings,
        "hub_defense",

        scr_building_hub_definition_create(
            "hub_defense",
            "Defense Coordination Hub",
            "Adds 50 defense capacity.",
            c_fuchsia,
            BuildLimitType.DEFENSE,
            50
        )
    );


    variable_struct_set(
        global.vtd.data.buildings,
        "hub_economy",

        scr_building_hub_definition_create(
            "hub_economy",
            "Economy Administration Hub",
            "Adds 10 economy capacity.",
            make_color_rgb(90, 210, 120),
            BuildLimitType.ECONOMY,
            10
        )
    );


    variable_struct_set(
        global.vtd.data.buildings,
        "hub_infrastructure",

        scr_building_hub_definition_create(
            "hub_infrastructure",
            "Infrastructure Control Hub",
            "Adds 15 infrastructure capacity.",
            c_aqua,
            BuildLimitType.INFRASTRUCTURE,
            15
        )
    );


    variable_struct_set(
        global.vtd.data.buildings,
        "hub_foundation",

        scr_building_hub_definition_create(
            "hub_foundation",
            "Foundation Control Hub",
            "Adds 100 foundation capacity.",
            make_color_rgb(100, 150, 190),
            BuildLimitType.FOUNDATION,
            100
        )
    );


    show_debug_message(
        "VECTOR TD 2026 - CAPACITY HUB DATA INITIALIZED"
    );


    return true;
}


/// @description Returns one building definition.

function scr_building_data_get(_building_key)
{
    if (!is_string(_building_key))
        return undefined;

    if (_building_key == "")
        return undefined;


    if (
        !variable_struct_exists(
            global.vtd.data.buildings,
            _building_key
        )
    )
    {
        show_debug_message(
            "BUILDING DATA ERROR - unknown key: "
            + _building_key
        );

        return undefined;
    }


    return variable_struct_get(
        global.vtd.data.buildings,
        _building_key
    );
}


/// @description Returns whether a building definition contains required data.

function scr_building_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!variable_struct_exists(
        _data,
        "identity"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "visual"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "footprint"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "vitals"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "construction"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "economy"
    ))
    {
        return false;
    }


    if (!is_struct(_data.identity))
        return false;

    if (!is_struct(_data.visual))
        return false;

    if (!is_struct(_data.footprint))
        return false;

    if (!is_struct(_data.vitals))
        return false;

    if (!is_struct(_data.construction))
        return false;

    if (!is_struct(_data.economy))
        return false;


    if (!is_string(_data.identity.key))
        return false;

    if (!is_string(_data.identity.name))
        return false;

    if (_data.identity.key == "")
        return false;

    if (_data.identity.name == "")
        return false;


    if (
        _data.footprint.width_cells
        <= 0
    )
    {
        return false;
    }

    if (
        _data.footprint.height_cells
        <= 0
    )
    {
        return false;
    }

    if (_data.vitals.hp_maximum <= 0)
        return false;


    return true;
}


/// @description Registers the basic solar energy generator.

function scr_building_data_energy_generator()
{
variable_struct_set(global.vtd.data.buildings, "energy_generator_solar",
{
identity:
{
key: "energy_generator_solar",
name: "Solar Generator",
type: BuildingType.POWER_GENERATOR,
description_short: "Produces energy for one local network.",
description_long: "A basic renewable generator. Connect it to an energy node to supply nearby buildings and charge network batteries."
},

build_menu:
{
    order: 10
},

visual:
{
    color: make_color_rgb(60, 170, 220),
	baked:
	{
	    body: scr_energy_generator_baked_body,
	    effects: scr_energy_generator_baked_effects
	}
},

footprint: { width_cells: 2, height_cells: 2 },
vitals: { hp_maximum: 250 },
construction: { time_seconds: 3 },

economy:
{
    cost:
    [{
        resource_key: "resource_credits",
        amount: 120
    }]
},

energy:
{
    role: EnergyRole.GENERATOR,
    priority: EnergyPriority.CRITICAL,

    connection_range: 320,
    generation_per_second: 25,

    input_rate: 0,
    idle_demand: 0,
    activity_cost: 0,

    buffer:
    {
        capacity: 0,
        starting_ratio: 0
    }
}
});

return true;
}

/// @description Registers the basic local energy node.

function scr_building_data_energy_node()
{
variable_struct_set(global.vtd.data.buildings, "energy_node_basic",
{
identity:
{
key: "energy_node_basic",
name: "Energy Node",
type: BuildingType.POWER_NODE,
description_short: "Connects nearby buildings into a local network.",
description_long: "A local distribution node. Nearby generators, consumers and batteries attach to it, while multiple nodes connect into a larger independent network."
},

build_menu:
{
    order: 20
},

visual:
{
    color: c_aqua
},

footprint: { width_cells: 1, height_cells: 1 },
vitals: { hp_maximum: 180 },
construction: { time_seconds: 2 },

economy:
{
    cost:
    [{
        resource_key: "resource_credits",
        amount: 40
    }]
},

energy:
{
    role: EnergyRole.NODE,
    priority: EnergyPriority.CRITICAL,

    connection_range: 384,
    generation_per_second: 0,

    input_rate: 0,
    idle_demand: 0,
    activity_cost: 0,

    buffer:
    {
        capacity: 0,
        starting_ratio: 0
    }
}
});

return true;
}

/// @description Registers the basic local-network energy battery.

function scr_building_data_energy_battery()
{
variable_struct_set(global.vtd.data.buildings, "energy_battery_basic",
{
identity:
{
key: "energy_battery_basic",
name: "Energy Battery",
type: BuildingType.POWER_BATTERY,
description_short: "Stores surplus energy for one local network.",
description_long: "A network battery that charges from surplus generation and discharges when local demand exceeds supply. Stored energy remains inside this battery if its network is divided."
},

build_menu:
{
    order: 30
},

visual:
{
    color: make_color_rgb(120, 220, 80)
},

footprint: { width_cells: 2, height_cells: 2 },
vitals: { hp_maximum: 300 },
construction: { time_seconds: 4 },

economy:
{
    cost:
    [{
        resource_key: "resource_credits",
        amount: 160
    }]
},

energy:
{
    role: EnergyRole.BATTERY,
    priority: EnergyPriority.HIGH,

    connection_range: 320,
    generation_per_second: 0,

    input_rate: 0,
    idle_demand: 0,
    activity_cost: 0,

    buffer:
    {
        capacity: 0,
        starting_ratio: 0
    },

    battery:
    {
        capacity: 500,
        starting_ratio: 0.25,
        charge_rate: 20,
        discharge_rate: 30
    }
}
});

return true;
}


/// @description Registers the Credit Magnet.

function scr_building_data_utility_credit_magnet()
{
variable_struct_set(
global.vtd.data.buildings,
"utility_credit_magnet",
{
identity:
{
key: "utility_credit_magnet",
name: "Credit Magnet",
type: BuildingType.UTILITY,

            description_short:
                "Attracts nearby physical credit pickups.",

            description_long:
                "Periodically emits an energized collection pulse that claims nearby credit pickups and draws them safely into the structure."
        },

        build_menu:
        {
            order: 10
        },

        visual:
        {
            color:
                make_color_rgb(
                    95,
                    35,
                    125
                )
        },

        footprint:
        {
            width_cells: 1,
            height_cells: 1
        },

        vitals:
        {
            hp_maximum: 180
        },

        construction:
        {
            time_seconds: 3
        },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 200
            }]
        },

        build_limit:
        {
            type: BuildLimitType.ECONOMY,
            amount: 1
        },

        utility:
        {
            type: UtilityType.CREDIT_MAGNET,

            range: 768,
            interval_seconds: 2,
            amount: 0,

            resource_key:
                "resource_credits"
        },

        energy:
        {
            role: EnergyRole.CONSUMER,
            priority: EnergyPriority.LOW,

            connection_range: 320,
            generation_per_second: 0,

            input_rate: 5,
            idle_demand: 0.5,
            activity_cost: 5,

            buffer:
            {
                capacity: 15,
                starting_ratio: 0
            }
        }
    }
);

return true;
}

/// @description Registers the Restoration Array.

function scr_building_data_utility_repairer()
{
variable_struct_set(
global.vtd.data.buildings,
"utility_repairer",
{
identity:
{
key: "utility_repairer",
name: "Restoration Array",
type: BuildingType.UTILITY,

            description_short:
                "Repairs the most damaged nearby structure.",

            description_long:
                "A defensive maintenance system that periodically identifies the nearby structure with the lowest integrity and restores part of its health."
        },

        build_menu:
        {
            order: 20
        },

        visual:
        {
            color:
                make_color_rgb(
                    35,
                    125,
                    85
                )
        },

        footprint:
        {
            width_cells: 2,
            height_cells: 2
        },

        vitals:
        {
            hp_maximum: 350
        },

        construction:
        {
            time_seconds: 5
        },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 350
            }]
        },

        build_limit:
        {
            type: BuildLimitType.ECONOMY,
            amount: 1
        },

        utility:
        {
            type: UtilityType.REPAIRER,

            range: 448,
            interval_seconds: 0.5,
            amount: 8
        },

        energy:
        {
            role: EnergyRole.CONSUMER,
            priority: EnergyPriority.NORMAL,

            connection_range: 320,
            generation_per_second: 0,

            input_rate: 8,
            idle_demand: 1,
            activity_cost: 2,

            buffer:
            {
                capacity: 20,
                starting_ratio: 0
            }
        }
    }
);

return true;
}

/// @description Registers the passive Credit Uplink.

function scr_building_data_utility_credit_uplink()
{
variable_struct_set(
global.vtd.data.buildings,
"utility_credit_uplink",
{
identity:
{
key: "utility_credit_uplink",
name: "Credit Uplink",
type: BuildingType.UTILITY,

            description_short:
                "Generates a small recurring credit income.",

            description_long:
                "Maintains an automated off-world trade and communications link. While supplied with energy, it periodically transfers a fixed credit payment into the level economy."
        },

        build_menu:
        {
            order: 30
        },

        visual:
        {
            color:
                make_color_rgb(
                    130,
                    105,
                    25
                )
        },

        footprint:
        {
            width_cells: 2,
            height_cells: 2
        },

        vitals:
        {
            hp_maximum: 250
        },

        construction:
        {
            time_seconds: 4
        },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 250
            }]
        },

        build_limit:
        {
            type: BuildLimitType.ECONOMY,
            amount: 1
        },

        utility:
        {
            type: UtilityType.CREDIT_UPLINK,

            range: 0,
            interval_seconds: 5,
            amount: 2
        },

        energy:
        {
            role: EnergyRole.CONSUMER,
            priority: EnergyPriority.LOW,

            connection_range: 320,
            generation_per_second: 0,

            input_rate: 5,
            idle_demand: 0.25,
            activity_cost: 4,

            buffer:
            {
                capacity: 15,
                starting_ratio: 0
            }
        }
    }
);

return true;
}

/// @description Registers the stealth-detection Radar Array.

function scr_building_data_utility_radar()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "utility_radar",
        {
            identity:
            {
                key: "utility_radar",
                name: "Radar Array",
                type: BuildingType.UTILITY,

                description_short:
                    "Detects cloaked enemies within its scan radius.",

                description_long:
                    "A powered surveillance installation that continuously sweeps the surrounding area. Periodic detection pulses temporarily reveal cloaked enemies, allowing defensive towers to acquire them."
            },

            build_menu:
            {
                order: 40
            },

            visual:
            {
                color:
                    make_color_rgb(
                        80,
                        190,
                        255
                    )
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 300
            },

            construction:
            {
                time_seconds: 6
            },

            economy:
            {
                cost:
                [{
                    resource_key: "resource_credits",
                    amount: 450
                }]
            },

            build_limit:
            {
                type: BuildLimitType.INFRASTRUCTURE,
                amount: 1
            },

            utility:
            {
                type: UtilityType.RADAR,

                range: 512,
                interval_seconds: 3.5,
                amount: 0,

                radar:
                {
                    reveal_seconds: 2.5,

                    sweep_degrees_per_second:
                        100,

                    pulse_duration_seconds:
                        0.65,

                    color:
                        make_color_rgb(
                            80,
                            190,
                            255
                        )
                }
            },

            energy:
            {
                role: EnergyRole.CONSUMER,
                priority: EnergyPriority.NORMAL,

                connection_range: 320,
                generation_per_second: 0,

                // Allows the network to refill the radar's internal buffer.

                input_rate: 12,

                idle_demand: 2,
                activity_cost: 8,

                buffer:
                {
                    capacity: 30,
                    starting_ratio: 0.5
                }
            }
        }
    );


    return true;
}

/// @description Registers the local field Shield Generator.

function scr_building_data_utility_shield_generator()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "utility_shield_generator",
        {
            identity:
            {
                key: "utility_shield_generator",
                name: "Shield Generator",
                type: BuildingType.UTILITY,

                description_short:
                    "Projects regenerating shields over nearby buildings.",

                description_long:
                    "A high-demand defensive support installation. It projects individual shields over nearby structures and automatically restores damaged shields after they avoid incoming damage."
            },

            build_menu:
            {
                order: 50
            },

            visual:
            {
                color:
                    make_color_rgb(
                        90,
                        180,
                        255
                    ),
						baked:
	{
	    body: scr_utility_shield_generator_baked_body,
	    effects: scr_utility_shield_generator_baked_effects
	}
            },

            footprint:
            {
                width_cells: 3,
                height_cells: 3
            },

            vitals:
            {
                hp_maximum: 500,
                shield_maximum: 200
            },

            construction:
            {
                time_seconds: 10
            },

            economy:
            {
                cost:
                [{
                    resource_key: "resource_credits",
                    amount: 800
                }]
            },

            build_limit:
            {
                type: BuildLimitType.INFRASTRUCTURE,
                amount: 2
            },

            utility:
            {
                type:
                    UtilityType.SHIELD_GENERATOR,

                range: 448,
                interval_seconds: 0.25,
                amount: 0,

                shield_generator:
                {
                    regeneration_delay_seconds: 3,
                    regeneration_per_second: 20,

                    idle_energy_per_building: 4,
                    regeneration_energy_per_point: 0.08,

                    field_linger_seconds: 0.6,

                    color:
                        make_color_rgb(
                            90,
                            180,
                            255
                        )
                }
            },

            energy:
            {
                role: EnergyRole.CONSUMER,
                priority: EnergyPriority.HIGH,

                connection_range: 320,
                generation_per_second: 0,

                input_rate: 80,

                idle_demand: 4,
                activity_cost: 0,

                buffer:
                {
                    capacity: 100,
                    starting_ratio: 0.5
                }
            }
        }
    );


    return true;
}

/// @description Registers the general-purpose Fabricator.

function scr_building_data_fabricator()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "fabricator_basic",
        {
            identity:
            {
                key: "fabricator_basic",
                name: "Fabricator",
                type: BuildingType.FABRICATOR,

                description_short:
                    "Manufactures ammunition and industrial components.",

                description_long:
                    "A flexible manufacturing facility. Select a recipe and queue production batches. Cargo drones deliver refined inputs and move completed products into compatible storage."
            },

            build_menu:
            {
                order: 20
            },

            visual:
            {
                color:
                    make_color_rgb(
                        80,
                        175,
                        145
                    )
            },

            footprint:
            {
                width_cells: 3,
                height_cells: 3
            },

            vitals:
            {
                hp_maximum: 450
            },

            construction:
            {
                time_seconds: 10
            },

            economy:
            {
                cost:
                [{
                    resource_key: "resource_credits",
                    amount: 650
                }]
            },

            build_limit:
            {
                type: BuildLimitType.ECONOMY,
                amount: 2
            },

            fabricator:
            {
                recipes:
                [
                    "bullets",
                    "explosives"
                ],

                output_buffer_batches: 5,
                drone_speed: 8,

                auto_mode_starting: false,
                process_text: "FABRICATING"
            },

            energy:
            {
                role: EnergyRole.CONSUMER,
                priority: EnergyPriority.NORMAL,

                connection_range: 320,
                generation_per_second: 0,

                input_rate: 20,

                idle_demand: 2,
                activity_cost: 0,

                buffer:
                {
                    capacity: 50,
                    starting_ratio: 0.5
                }
            }
        }
    );


    return true;
}

/// @description Registers storage for manufactured ammunition.

function scr_building_data_ammunition_storage()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "storage_ammunition",
        {
            identity:
            {
                key: "storage_ammunition",
                name: "Ammunition Storage",
                type: BuildingType.STORAGE,

                description_short:
                    "Stores bullets and explosives.",

                description_long:
                    "A protected ammunition depot used by Fabricators and tower-resupply drones. Destroying it also destroys its stored ammunition."
            },

            build_menu:
            {
                order: 40
            },

            visual:
            {
                color:
                    make_color_rgb(
                        160,
                        120,
                        45
                    )
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 350
            },

            construction:
            {
                time_seconds: 6
            },

            economy:
            {
                cost:
                [{
                    resource_key: "resource_credits",
                    amount: 250
                }]
            },

            build_limit:
            {
                type: BuildLimitType.ECONOMY,
                amount: 1
            },

            storage:
            {
                compartments:
                [
                    {
                        resource_key: "resource_bullets",
                        capacity: 2000
                    },

                    {
                        resource_key: "resource_explosives",
                        capacity: 400
                    }
                ]
            }
        }
    );


    return true;
}