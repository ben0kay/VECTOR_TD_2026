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
			
			// ========================================================================
			// LEVEL CONTENT
			// ========================================================================
			//
			// The test world currently allows the complete global database.
			// Set allow_all to false when making proper campaign levels.

			content:
			{
			    allow_all: true,

			    enemies:
			    [
			        "enemy_weak",
			        "enemy_hunter",
			        "enemy_phaser",
			        "enemy_shooter_single",
			        "enemy_shooter_triple",
			        "enemy_kamikaze",
			        "enemy_splitter",
			        "enemy_splitter_child",
			        "enemy_flyer"
			    ],

			    buildings:
			    [
			        "wall_basic",
			        "tower_basic",
			        "tower_anti_air",
			        "tower_minigun",
			        "tower_cannon",
			        "tower_laser",
			        "tower_sniper"
			    ],

			    resources:
			    [
			        "resource_credits",
			        "resource_carbon",
			        "resource_silicon",
			        "resource_copper"
			    ],

			    deposits:
			    [
			        // FUTURE:
			        // Separate deposit definitions can be restricted here.
			    ]
			},
			
			starting_resources:
			[
			    {
			        resource_key: "resource_credits",
			        amount: 2500
			    },

			    {
			        resource_key: "resource_carbon",
			        amount: 0
			    },

			    {
			        resource_key: "resource_silicon",
			        amount: 0
			    },

			    {
			        resource_key: "resource_copper",
			        amount: 0
			    }
			],

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
                    vein_start_chance: 0.035,
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
                            minimum_distance_cells: 10,
                            maximum_distance_cells: 30,
                            vein_size_min: 5,
                            vein_size_max: 8
                        }
                    ]
                }
            },


            // ================================================================
            // ENEMY PRESSURE
            // ================================================================

            pressure:
            {
                enabled: true,

                // Short for testing. Real worlds may use 60–120 seconds.
                grace_seconds: 20,

                // Prevents one queued attack from creating every enemy at once.
                maximum_spawns_per_step: 4,
				maximum_alive_enemies: 300,
				maximum_queued_enemies: 600,
				
				// ========================================================================
				// TIMED ENEMY MODIFIERS
				// ========================================================================

				modifiers:
				{
				    enabled: true,

				    definitions:
				    [
				        {
				            modifier: EnemyModifier.SHIELDED,

				            // Testing values. Proper levels can unlock this much later.
				            unlock_seconds: 120,

				            chance_start: 0.05,
				            chance_maximum: 0.35,

				            // Time taken to grow from starting to maximum chance.
				            scaling_seconds: 600
				        }
				    ]
				},


                baseline:
                {
                    enabled: true,

                    interval_start_seconds: 4,
                    interval_end_seconds: 1.5,
                    scaling_seconds: 600,

                    pool:
                    [
                        {
                            enemy_key: "enemy_weak",
                            weight: 100,
                            unlock_seconds: 0
                        },

                        {
                            enemy_key: "enemy_hunter",
                            weight: 30,
                            unlock_seconds: 90
                        },

                        {
                            enemy_key: "enemy_shooter_single",
                            weight: 20,
                            unlock_seconds: 180
                        },

                        {
                            enemy_key: "enemy_phaser",
                            weight: 12,
                            unlock_seconds: 240
                        }
                    ]
                },


                clusters:
                {
                    enabled: true,

                    interval_min_seconds: 30,
                    interval_max_seconds: 50,

                    scaling_start_seconds: 180,
                    scaling_seconds: 600,
                    count_multiplier_maximum: 2.5,

                    zone_width_minimum: 0.08,
                    zone_width_maximum: 0.22,

                    patterns:
                    [
                        {
                            key: "weak_cluster",
                            name: "Weak Cluster",

                            weight: 100,
                            unlock_seconds: 0,

                            enemies:
                            [
                                {
                                    enemy_key: "enemy_weak",
                                    weight: 100
                                }
                            ],

                            count_min: 6,
                            count_max: 10,

                            stagger_min_seconds: 0.12,
                            stagger_max_seconds: 0.35
                        },

                        {
                            key: "mixed_cluster",
                            name: "Mixed Cluster",

                            weight: 60,
                            unlock_seconds: 120,

                            enemies:
                            [
                                {
                                    enemy_key: "enemy_weak",
                                    weight: 65
                                },

                                {
                                    enemy_key: "enemy_hunter",
                                    weight: 25
                                },

                                {
                                    enemy_key: "enemy_shooter_single",
                                    weight: 10
                                }
                            ],

                            count_min: 8,
                            count_max: 14,

                            stagger_min_seconds: 0.1,
                            stagger_max_seconds: 0.28
                        },

                        {
                            key: "kamikaze_cluster",
                            name: "Kamikaze Cluster",

                            weight: 20,
                            unlock_seconds: 240,

                            enemies:
                            [
                                {
                                    enemy_key: "enemy_kamikaze",
                                    weight: 100
                                }
                            ],

                            count_min: 3,
                            count_max: 6,

                            stagger_min_seconds: 0.25,
                            stagger_max_seconds: 0.55
                        }
                    ]
                },


                waves:
{
    enabled: true,
    warning_seconds: 8,

    interval_min_seconds: 90,
    interval_max_seconds: 120,

    // Run every wave sequentially once. Afterward, repeat only from
    // ADVANCED ASSAULT onward for the test world's endless pressure.

    cycle: true,
    cycle_start_index: 2,

    definitions:
    [
        {
            key: "weak_swarm",
            name: "WEAK SWARM",

            groups:
            [
                {
                    enemy_key: "enemy_weak",
                    count: 24,
                    modifiers: [],

                    delay_seconds: 0,
                    stagger_min_seconds: 0.08,
                    stagger_max_seconds: 0.16,

                    side: SpawnSide.INHERIT
                }
            ]
        },

        {
            key: "mixed_assault",
            name: "MIXED ASSAULT",

            groups:
            [
                {
                    enemy_key: "enemy_weak",
                    count: 24,
                    modifiers: [],

                    delay_seconds: 0,
                    stagger_min_seconds: 0.07,
                    stagger_max_seconds: 0.14,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_hunter",
                    count: 10,
                    modifiers: [],

                    delay_seconds: 3,
                    stagger_min_seconds: 0.12,
                    stagger_max_seconds: 0.22,

                    side: SpawnSide.INHERIT
                }
            ]
        },

        {
            key: "advanced_assault",
            name: "ADVANCED ASSAULT",

            groups:
            [
                {
                    enemy_key: "enemy_hunter",
                    count: 16,
                    modifiers: [],

                    delay_seconds: 0,
                    stagger_min_seconds: 0.1,
                    stagger_max_seconds: 0.18,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_shooter_single",
                    count: 10,
                    modifiers: [],

                    delay_seconds: 4,
                    stagger_min_seconds: 0.15,
                    stagger_max_seconds: 0.25,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_kamikaze",
                    count: 6,
                    modifiers: [],

                    delay_seconds: 8,
                    stagger_min_seconds: 0.2,
                    stagger_max_seconds: 0.35,

                    side: SpawnSide.RANDOM
                }
            ]
        },

        {
            key: "air_assault",
            name: "AIR ASSAULT",

            groups:
            [
                {
                    enemy_key: "enemy_weak",
                    count: 20,
                    modifiers: [],

                    delay_seconds: 0,
                    stagger_min_seconds: 0.08,
                    stagger_max_seconds: 0.15,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_flyer",
                    count: 16,
                    modifiers: [],

                    delay_seconds: 5,
                    stagger_min_seconds: 0.12,
                    stagger_max_seconds: 0.24,

                    side: SpawnSide.RANDOM
                }
            ]
        },

        {
            key: "shield_assault",
            name: "SHIELD ASSAULT",

            groups:
            [
                {
                    enemy_key: "enemy_weak",
                    count: 24,

                    modifiers:
                    [
                        EnemyModifier.SHIELDED
                    ],

                    delay_seconds: 0,
                    stagger_min_seconds: 0.08,
                    stagger_max_seconds: 0.16,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_hunter",
                    count: 14,

                    modifiers:
                    [
                        EnemyModifier.SHIELDED
                    ],

                    delay_seconds: 5,
                    stagger_min_seconds: 0.12,
                    stagger_max_seconds: 0.22,

                    side: SpawnSide.INHERIT
                }
            ]
        },

        {
            key: "combined_assault",
            name: "COMBINED ASSAULT",

            groups:
            [
                {
                    enemy_key: "enemy_weak",
                    count: 30,
                    modifiers: [],

                    delay_seconds: 0,
                    stagger_min_seconds: 0.06,
                    stagger_max_seconds: 0.12,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_shooter_triple",
                    count: 10,
                    modifiers: [],

                    delay_seconds: 4,
                    stagger_min_seconds: 0.15,
                    stagger_max_seconds: 0.25,

                    side: SpawnSide.INHERIT
                },

                {
                    enemy_key: "enemy_flyer",
                    count: 16,
                    modifiers: [],

                    delay_seconds: 7,
                    stagger_min_seconds: 0.1,
                    stagger_max_seconds: 0.2,

                    side: SpawnSide.RANDOM
                },

                {
                    enemy_key: "enemy_splitter",
                    count: 8,

                    modifiers:
                    [
                        EnemyModifier.SHIELDED
                    ],

                    delay_seconds: 12,
                    stagger_min_seconds: 0.25,
                    stagger_max_seconds: 0.4,

                    side: SpawnSide.RANDOM
                }
            ]
        }
    ]
}


                milestones:
                [
                    {
                        key: "first_blood",
                        name: "FIRST BLOOD RESPONSE",

                        trigger_kills: 25,

                        enemies:
                        [
                            {
                                enemy_key: "enemy_weak",
                                weight: 70
                            },

                            {
                                enemy_key: "enemy_hunter",
                                weight: 30
                            }
                        ],

                        count_min: 18,
                        count_max: 24,

                        stagger_min_seconds: 0.08,
                        stagger_max_seconds: 0.18
                    },

                    {
                        key: "century_harvest",
                        name: "THE CENTURY HARVEST",

                        trigger_kills: 100,

                        enemies:
                        [
                            {
                                enemy_key: "enemy_weak",
                                weight: 45
                            },

                            {
                                enemy_key: "enemy_hunter",
                                weight: 20
                            },

                            {
                                enemy_key: "enemy_shooter_triple",
                                weight: 15
                            },

                            {
                                enemy_key: "enemy_kamikaze",
                                weight: 10
                            },

                            {
                                enemy_key: "enemy_splitter",
                                weight: 10
                            }
                        ],

                        count_min: 40,
                        count_max: 55,

                        stagger_min_seconds: 0.05,
                        stagger_max_seconds: 0.14
                    }
                ]
            }


            // FUTURE:
            // starting resources
            // environmental modifiers
            // fog settings
            // victory conditions
            // spawn-zone exclusions
            // boss encounters
        }
    };


    show_debug_message(
        "VECTOR TD 2026 - WORLD DATA INITIALIZED"
    );

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

/// @description Returns the active generated world's definition.

function scr_world_data_current_get()
{
    if (!variable_global_exists("vtd_level"))
        return undefined;

    if (!is_struct(global.vtd_level))
        return undefined;

    if (!variable_struct_exists(global.vtd_level, "world"))
        return undefined;

    if (!is_struct(global.vtd_level.world.generation))
        return undefined;

    return scr_world_data_get(
        global.vtd_level.world.generation.key
    );
}


/// @description Returns one content array from a world definition.

function scr_world_content_array_get(_world_data, _content_type)
{
    if (!is_struct(_world_data))
        return [];

    if (!variable_struct_exists(_world_data, "content"))
        return [];

    var _content = _world_data.content;

    switch (_content_type)
    {
        case WorldContentType.ENEMY:
            return _content.enemies;

        case WorldContentType.BUILDING:
            return _content.buildings;

        case WorldContentType.RESOURCE:
            return _content.resources;

        case WorldContentType.DEPOSIT:
            return _content.deposits;
    }

    return [];
}


/// @description Returns whether a world permits one content key.

function scr_world_content_allowed(
    _world_data,
    _content_type,
    _content_key
)
{
    if (!is_struct(_world_data))
        return false;

    if (!variable_struct_exists(_world_data, "content"))
        return true;

    var _content = _world_data.content;

    if (
        variable_struct_exists(_content, "allow_all")
        && _content.allow_all
    )
    {
        return true;
    }

    var _allowed =
        scr_world_content_array_get(
            _world_data,
            _content_type
        );

    for (var i = 0; i < array_length(_allowed); ++i)
    {
        if (_allowed[i] == _content_key)
            return true;
    }

    return false;
}


/// @description Returns whether the current world permits one content key.

function scr_world_current_content_allowed(
    _content_type,
    _content_key
)
{
    var _world_data =
        scr_world_data_current_get();

    if (!is_struct(_world_data))
        return true;

    return scr_world_content_allowed(
        _world_data,
        _content_type,
        _content_key
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