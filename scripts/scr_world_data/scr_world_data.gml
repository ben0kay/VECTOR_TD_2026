/// @description Data-driven world and generation definitions.


/// @description Registers every world definition.

function scr_world_data_initialize()
{
    global.vtd.data.worlds =
    {
        world_test:
        {
            identity:
            {
                key: "world_test",
                name: "Test Cluster World"
            },

            generation:
            {
                style: WorldGenerationStyle.CLUSTERS,
                seed: -1,

                safe_radius_cells: 9,
                border_clearance_cells: 3,

                clusters:
                {
                    count_min: 20,
                    count_max: 32,

                    size_min: 32,
                    size_max: 64,

                    minimum_distance_cells: 8,
                    growth_chance: 0.82,
                    maximum_seed_attempts: 1000
                },

                resources:
                {
                    enabled: true,

                    // Chance for one exposed dead cell to begin a vein.
                    vein_start_chance: 0.035,

                    // Prevents extremely ore-heavy maps.
                    maximum_random_veins: 18,

                    pool:
                    [
                        {
                            resource_key: "resource_carbon",
                            weight: 50
                        },

                        {
                            resource_key: "resource_silicon",
                            weight: 30
                        },

                        {
                            resource_key: "resource_copper",
                            weight: 20
                        }
                    ],

                    guaranteed:
                    [
                        {
                            resource_key: "resource_carbon",

                            // Distance is measured from the map centre in cells.
                            minimum_distance_cells: 10,
                            maximum_distance_cells: 30,

                            vein_size_min: 5,
                            vein_size_max: 8
                        }
                    ]
                }
            }

            // FUTURE:
            // cavern settings
            // enemy spawning
            // waves and milestones
            // environmental modifiers
        }
    };


    show_debug_message("VECTOR TD 2026 - WORLD DATA INITIALIZED");

    return true;
}


/// @description Returns one world definition.

function scr_world_data_get(_world_key)
{
    if (!is_string(_world_key))
        return undefined;

    if (_world_key == "")
        return undefined;

    if (!variable_struct_exists(global.vtd.data.worlds, _world_key))
    {
        show_debug_message(
            "WORLD DATA ERROR - unknown key: " + _world_key
        );

        return undefined;
    }


    return variable_struct_get(
        global.vtd.data.worlds,
        _world_key
    );
}


/// @description Returns whether a world definition contains valid core data.

function scr_world_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!variable_struct_exists(_data, "identity"))
        return false;

    if (!variable_struct_exists(_data, "generation"))
        return false;

    if (!is_struct(_data.identity))
        return false;

    if (!is_struct(_data.generation))
        return false;

    if (!is_string(_data.identity.key))
        return false;

    if (_data.identity.key == "")
        return false;


    switch (_data.generation.style)
    {
        case WorldGenerationStyle.CLUSTERS:
        {
            if (!variable_struct_exists(_data.generation, "clusters"))
                return false;

            if (!is_struct(_data.generation.clusters))
                return false;

            var _clusters = _data.generation.clusters;

            if (_clusters.count_min < 0)
                return false;

            if (_clusters.count_max < _clusters.count_min)
                return false;

            if (_clusters.size_min <= 0)
                return false;

            if (_clusters.size_max < _clusters.size_min)
                return false;

            if (_clusters.minimum_distance_cells < 0)
                return false;

            if (_clusters.growth_chance < 0)
                return false;

            if (_clusters.growth_chance > 1)
                return false;

            if (_clusters.maximum_seed_attempts <= 0)
                return false;
        }
        break;


        case WorldGenerationStyle.CAVERNS:
        {
            // FUTURE:
            // Validate cavern and tunnel settings.
        }
        break;


        case WorldGenerationStyle.NONE:
        {
            // An intentionally empty world is valid.
        }
        break;
    }


    return true;
}