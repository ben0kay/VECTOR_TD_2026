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


    // Towers register into this same building database.

    scr_tower_data_initialize();


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