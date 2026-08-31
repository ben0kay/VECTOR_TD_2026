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
			// LEVEL COMPLETION
			// ========================================================================

			victory:
			{
			    // Set to NONE when testing endless pressure.
			    type: LevelVictoryType.COMPLETE_WAVES,

			    required_waves: 6,
			    survival_seconds: 0
			},

			progression:
			{
			    // Prepared for the future campaign/level loader.
			    next_world_key: "",
			    menu_room: noone
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
			        amount: 25000
			    },

			    {
			        resource_key: "resource_carbon",
			        amount: 1000
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
			
			build_limits:
			{
			    tower: 10,
			    defense: 50,
			    economy: 10,
			    infrastructure: 20
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

			navigation:
			{
			    flanking:
			    {
			        enabled: true,
			        chance: 0.20,
			        distance_ratio: 0.22,
			        candidates_per_corner: 6,
			        search_radius_cells: 8
			    }
			},
            // ================================================================
            // ENEMY PRESSURE
            // ================================================================

            pressure:
            {
                enabled: true,

                // Short for testing. Real worlds may use 60–120 seconds.
                grace_seconds: 30,

                // Prevents one queued attack from creating every enemy at once.
                maximum_spawns_per_step: 4,
				maximum_alive_enemies: 300,
				maximum_queued_enemies: 600,
				
				
				// ========================================================================
				// ENEMY ORDERS
				// ========================================================================

				orders:
				{
				    enabled: true,

				    // Each ordinary baseline enemy rolls independently.
				    baseline_chance: 0.001,

				    // One roll per cluster. A successful roll applies to its entire group.
				    cluster_chance: 0.05,

				    available:
				    [
				        EnemyOrder.TARGET_PLAYER,
				        EnemyOrder.TARGET_MINER,
				        EnemyOrder.TARGET_TOWER
				    ]
				},
				
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
				            unlock_seconds: 300,

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

				    interval_start_seconds: 2.25,
				    interval_end_seconds: 0.5,
				    scaling_seconds: 600,
					weight_shift_seconds: 300,
					weight_shift_strength: 2,

				    pool:
				    [
			    { enemy_key: "enemy_weak",             weight: 70, unlock_seconds: 0   },
			    { enemy_key: "enemy_hunter",           weight: 45, unlock_seconds: 24  },
			    { enemy_key: "enemy_shooter_single",   weight: 30, unlock_seconds: 48  },
			    { enemy_key: "enemy_kamikaze",         weight: 16, unlock_seconds: 72  },
			    { enemy_key: "enemy_phaser",           weight: 12, unlock_seconds: 96  },
			    { enemy_key: "enemy_shooter_triple",   weight: 18, unlock_seconds: 120 },
			    { enemy_key: "enemy_flyer",            weight: 18, unlock_seconds: 144 },
			    { enemy_key: "enemy_centipede_head",   weight: 5,  unlock_seconds: 152 },
			    { enemy_key: "enemy_splitter",         weight: 10, unlock_seconds: 168 },
			    { enemy_key: "enemy_sniper",           weight: 5,  unlock_seconds: 180 },
			    { enemy_key: "enemy_brute",            weight: 12, unlock_seconds: 192 },
			    { enemy_key: "enemy_weak_mk2",         weight: 10, unlock_seconds: 200 },
			    { enemy_key: "enemy_hunter_mk2",       weight: 10, unlock_seconds: 204 },
			    { enemy_key: "enemy_transporter",      weight: 7,  unlock_seconds: 216 },
			    { enemy_key: "enemy_gunship",          weight: 8,  unlock_seconds: 240 },
			    { enemy_key: "enemy_shield_generator", weight: 5,  unlock_seconds: 264 },
			    { enemy_key: "enemy_siege_beam",       weight: 4,  unlock_seconds: 288 },
			    { enemy_key: "enemy_siege_rocket",     weight: 4,  unlock_seconds: 312 },
			    { enemy_key: "enemy_heavy_flyer",      weight: 3,  unlock_seconds: 340 },
				{ enemy_key: "enemy_transporter_flying",      weight: 2,  unlock_seconds: 360 }
			]
				},


                clusters:
                {
                    enabled: true,

                    interval_min_seconds: 12,
					interval_max_seconds: 20,

					scaling_start_seconds: 120,
					scaling_seconds: 600,
					count_multiplier_maximum: 3.0,

                    zone_width_minimum: 0.1,
                    zone_width_maximum: 0.22,

                    patterns:
							[
						{
						    key: "dynamic_cluster",
						    name: "Adaptive Cluster",

						    dynamic: true,

						    weight: 200,
						    unlock_seconds: 0,

						    count_min: 10,
						    count_max: 15,

						    stagger_min_seconds: 0.10,
						    stagger_max_seconds: 0.30,

						    later_enemy_bias_strength: 1.5
						},
						{
							key: "weak_cluster", name: "Weak Cluster", weight: 100, unlock_seconds: 0,
							enemies: [
							{ enemy_key: "enemy_weak", weight: 100 }
							],
							count_min: 6, count_max: 10, stagger_min_seconds: 0.12, stagger_max_seconds: 0.35
						},

					    {
					        key: "mixed_cluster", name: "Mixed Cluster", weight: 60, unlock_seconds: 120,
					        enemies: [
					            { enemy_key: "enemy_weak",           weight: 65 },
					            { enemy_key: "enemy_hunter",         weight: 25 },
					            { enemy_key: "enemy_shooter_single", weight: 10 }
					        ],
					        count_min: 8, count_max: 14, stagger_min_seconds: 0.10, stagger_max_seconds: 0.28
					    },

					    {
					        key: "kamikaze_cluster", name: "Kamikaze Cluster", weight: 20, unlock_seconds: 240,
					        enemies: [
					            { enemy_key: "enemy_kamikaze", weight: 100 }
					        ],
					        count_min: 3, count_max: 6, stagger_min_seconds: 0.25, stagger_max_seconds: 0.55
					    },

					    {
					        key: "air_cluster", name: "Air Cluster", weight: 35, unlock_seconds: 300,
					        enemies: [
					            { enemy_key: "enemy_flyer", weight: 100 }
					        ],
					        count_min: 5, count_max: 9, stagger_min_seconds: 0.12, stagger_max_seconds: 0.26
					    },

					    {
					        key: "ranged_cluster", name: "Ranged Cluster", weight: 32, unlock_seconds: 360,
					        enemies: [
					            { enemy_key: "enemy_shooter_single", weight: 65 },
					            { enemy_key: "enemy_shooter_triple", weight: 35 }
					        ],
					        count_min: 5, count_max: 9, stagger_min_seconds: 0.18, stagger_max_seconds: 0.35
					    },

					    {
					        key: "splitter_cluster", name: "Splitter Cluster", weight: 24, unlock_seconds: 420,
					        enemies: [
					            { enemy_key: "enemy_weak",     weight: 55 },
					            { enemy_key: "enemy_splitter", weight: 45 }
					        ],
					        count_min: 5, count_max: 8, stagger_min_seconds: 0.20, stagger_max_seconds: 0.42
					    },

					    {
					        key: "heavy_cluster", name: "Heavy Cluster", weight: 18, unlock_seconds: 480,
					        enemies: [
					            { enemy_key: "enemy_hunter", weight: 55 },
					            { enemy_key: "enemy_brute",  weight: 45 }
					        ],
					        count_min: 4, count_max: 7, stagger_min_seconds: 0.25, stagger_max_seconds: 0.50
					    },

					    {
					        key: "air_support_cluster", name: "Air Support Cluster", weight: 16, unlock_seconds: 540,
					        enemies: [
					            { enemy_key: "enemy_flyer",   weight: 70 },
					            { enemy_key: "enemy_gunship", weight: 30 }
					        ],
					        count_min: 5, count_max: 8, stagger_min_seconds: 0.18, stagger_max_seconds: 0.38
					    },

					    {
					        key: "transport_cluster", name: "Transport Cluster", weight: 12, unlock_seconds: 600,
					        enemies: [
					            { enemy_key: "enemy_hunter",      weight: 55 },
					            { enemy_key: "enemy_transporter", weight: 20 },
					            { enemy_key: "enemy_brute",       weight: 25 }
					        ],
					        count_min: 4, count_max: 7, stagger_min_seconds: 0.28, stagger_max_seconds: 0.55
					    },

					    {
					        key: "advanced_mixed_cluster", name: "Advanced Mixed Cluster", weight: 14, unlock_seconds: 660,
					        enemies: [
					            { enemy_key: "enemy_hunter",         weight: 30 },
					            { enemy_key: "enemy_shooter_triple", weight: 20 },
					            { enemy_key: "enemy_kamikaze",       weight: 15 },
					            { enemy_key: "enemy_splitter",       weight: 15 },
					            { enemy_key: "enemy_flyer",          weight: 20 }
					        ],
					        count_min: 8, count_max: 13, stagger_min_seconds: 0.10, stagger_max_seconds: 0.25
					    }
					]
                },


                waves:
	{
    enabled: true,
    warning_seconds: 8,

    interval_min_seconds: 140,
    interval_max_seconds: 180,

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
		                enemy_key: "enemy_weak", count: 24, modifiers: [],
		                delay_seconds: 0, stagger_min_seconds: 0.1, stagger_max_seconds: 0.18,
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
		                enemy_key: "enemy_weak", count: 22, modifiers: [],
		                delay_seconds: 0, stagger_min_seconds: 0.1, stagger_max_seconds: 0.18,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_hunter", count: 10, modifiers: [],
		                delay_seconds: 3, stagger_min_seconds: 0.12, stagger_max_seconds: 0.22,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_shooter_single", count: 5, modifiers: [],
		                delay_seconds: 6, stagger_min_seconds: 0.18, stagger_max_seconds: 0.30,
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
		                enemy_key: "enemy_hunter", count: 14, modifiers: [],
		                delay_seconds: 0, stagger_min_seconds: 0.10, stagger_max_seconds: 0.18,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_shooter_single", count: 10, modifiers: [],
		                delay_seconds: 3, stagger_min_seconds: 0.15, stagger_max_seconds: 0.25,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_kamikaze", count: 7, modifiers: [],
		                delay_seconds: 6, stagger_min_seconds: 0.20, stagger_max_seconds: 0.35,
		                side: SpawnSide.RANDOM
		            },

		            {
		                enemy_key: "enemy_splitter", count: 4, modifiers: [],
		                delay_seconds: 9, stagger_min_seconds: 0.28, stagger_max_seconds: 0.42,
		                side: SpawnSide.INHERIT
		            }
		        ]
		    },

		    {
		        key: "air_assault",
		        name: "AIR ASSAULT",

		        groups:
		        [
		            {
		                enemy_key: "enemy_hunter", count: 12, modifiers: [],
		                delay_seconds: 0, stagger_min_seconds: 0.10, stagger_max_seconds: 0.18,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_shooter_triple", count: 7, modifiers: [],
		                delay_seconds: 3, stagger_min_seconds: 0.16, stagger_max_seconds: 0.26,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_flyer", count: 16, modifiers: [],
		                delay_seconds: 5, stagger_min_seconds: 0.10, stagger_max_seconds: 0.20,
		                side: SpawnSide.RANDOM
		            },

		            {
		                enemy_key: "enemy_gunship", count: 3, modifiers: [],
		                delay_seconds: 9, stagger_min_seconds: 0.35, stagger_max_seconds: 0.55,
		                side: SpawnSide.RANDOM
		            }
		        ]
		    },

		    {
		        key: "shield_assault",
		        name: "HEAVY ASSAULT",

		        groups:
		        [
		            {
		                enemy_key: "enemy_hunter", count: 14,
		                modifiers: [ EnemyModifier.SHIELDED ],
		                delay_seconds: 0, stagger_min_seconds: 0.10, stagger_max_seconds: 0.20,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_brute", count: 5, modifiers: [],
		                delay_seconds: 4, stagger_min_seconds: 0.35, stagger_max_seconds: 0.55,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_splitter", count: 6,
		                modifiers: [ EnemyModifier.SHIELDED ],
		                delay_seconds: 7, stagger_min_seconds: 0.25, stagger_max_seconds: 0.40,
		                side: SpawnSide.RANDOM
		            },

		            {
		                enemy_key: "enemy_transporter", count: 3, modifiers: [],
		                delay_seconds: 11, stagger_min_seconds: 0.50, stagger_max_seconds: 0.80,
		                side: SpawnSide.RANDOM
		            }
		        ]
		    },

		    {
		        key: "combined_assault",
		        name: "COMBINED ASSAULT",

		        groups:
		        [
		            {
		                enemy_key: "enemy_hunter", count: 18, modifiers: [],
		                delay_seconds: 0, stagger_min_seconds: 0.08, stagger_max_seconds: 0.16,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_shooter_triple", count: 10, modifiers: [],
		                delay_seconds: 3, stagger_min_seconds: 0.14, stagger_max_seconds: 0.24,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_flyer", count: 16, modifiers: [],
		                delay_seconds: 5, stagger_min_seconds: 0.10, stagger_max_seconds: 0.20,
		                side: SpawnSide.RANDOM
		            },

		            {
		                enemy_key: "enemy_gunship", count: 4, modifiers: [],
		                delay_seconds: 8, stagger_min_seconds: 0.30, stagger_max_seconds: 0.50,
		                side: SpawnSide.RANDOM
		            },

		            {
		                enemy_key: "enemy_brute", count: 6,
		                modifiers: [ EnemyModifier.SHIELDED ],
		                delay_seconds: 10, stagger_min_seconds: 0.35, stagger_max_seconds: 0.55,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_transporter", count: 3, modifiers: [],
		                delay_seconds: 13, stagger_min_seconds: 0.50, stagger_max_seconds: 0.80,
		                side: SpawnSide.RANDOM
		            },

		            {
		                enemy_key: "enemy_shield_generator", count: 2, modifiers: [],
		                delay_seconds: 15, stagger_min_seconds: 0.80, stagger_max_seconds: 1.10,
		                side: SpawnSide.INHERIT
		            },

		            {
		                enemy_key: "enemy_siege_beam", count: 1, modifiers: [],
		                delay_seconds: 18, stagger_min_seconds: 0, stagger_max_seconds: 0,
		                side: SpawnSide.INHERIT
		            }
		        ]
		    }
		]
	},


                milestones:
				[
				    {
				        key: "first_blood",
				        name: "FIRST BLOOD RESPONSE",
				        trigger_kills: 50,
				        enemies: [
				            { enemy_key: "enemy_weak",   weight: 70 },
				            { enemy_key: "enemy_hunter", weight: 30 }
				        ],
				        count_min: 36,
				        count_max: 42,
				        stagger_min_seconds: 0.08,
				        stagger_max_seconds: 0.18
				    },

				    {
				        key: "century_harvest",
				        name: "THE 3.CENTURY HARVEST",
				        trigger_kills: 300,
				        enemies: [
				            { enemy_key: "enemy_weak",           weight: 45 },
				            { enemy_key: "enemy_hunter",         weight: 20 },
				            { enemy_key: "enemy_shooter_triple", weight: 15 },
				            { enemy_key: "enemy_kamikaze",       weight: 10 },
							{ enemy_key: "enemy_sniper",         weight: 10 },
				            { enemy_key: "enemy_splitter",       weight: 10 }
				        ],
				        count_min: 100,
				        count_max: 150,
				        stagger_min_seconds: 0.08,
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