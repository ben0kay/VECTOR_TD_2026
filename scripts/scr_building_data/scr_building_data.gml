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
                resource_key: "resource_carbon",
                capacity: 1000
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
                resource_key: "resource_silicon",
                capacity: 750
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
                resource_key: "resource_copper",
                capacity: 750
            }
        }
    };
	
	
	if (!scr_building_data_energy_generator())
    return false;

	if (!scr_building_data_energy_node())
	    return false;

	if (!scr_building_data_energy_battery())
	    return false;

	if (!scr_building_data_foundation_basic())
	    return false;
	
	if (!scr_building_data_utility_initialize())
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

/// @description Registers the basic structural foundation.

function scr_building_data_foundation_basic()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "foundation_basic",
        {
            identity:
            {
                key: "foundation_basic",
                name: "Basic Foundation",
                type: BuildingType.FOUNDATION,

                description_short:
                    "Structural flooring for buildings and player movement.",

                description_long:
                    "A flat construction platform placed before ordinary buildings. Fully supported buildings gain 5% maximum integrity, while the player moves 15% faster across completed foundation tiles."
            },

            visual:
            {
                color: make_color_rgb(30, 150, 170)
            },

            footprint:
            {
                width_cells: 1,
                height_cells: 1
            },

            vitals:
            {
                hp_maximum: 75
            },

            construction:
            {
                time_seconds: 1.5
            },

            economy:
            {
                cost:
                [{
                    resource_key: "resource_credits",
                    amount: 5
                }]
            },

            foundation:
            {
                building_hp_multiplier: 1.05,
                player_speed_multiplier: 1.15
            }
        }
    );

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

        visual:
        {
            color: make_color_rgb(60, 170, 220)
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


    show_debug_message(
        "VECTOR TD 2026 - CAPACITY HUB DATA INITIALIZED"
    );


    return true;
}
