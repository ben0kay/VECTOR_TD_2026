/// @description Data-driven baseline, cluster, wave, and milestone spawning.

/// @description Validates one world's enemy-pressure definition.

function scr_enemy_spawner_data_valid(_data)
{
    if (!is_struct(_data))
        return false;


    // ========================================================================
    // ROOT DATA
    // ========================================================================

    if (!variable_struct_exists(_data, "enabled"))
        return false;

    if (!variable_struct_exists(_data, "grace_seconds"))
        return false;

    if (!variable_struct_exists(_data, "maximum_spawns_per_step"))
        return false;

    if (!variable_struct_exists(_data, "maximum_alive_enemies"))
        return false;

    if (!variable_struct_exists(_data, "maximum_queued_enemies"))
        return false;

    if (!variable_struct_exists(_data, "baseline"))
        return false;

    if (!variable_struct_exists(_data, "clusters"))
        return false;

    if (!variable_struct_exists(_data, "waves"))
        return false;

    if (!variable_struct_exists(_data, "milestones"))
        return false;

    if (!variable_struct_exists(_data, "modifiers"))
        return false;


    if (_data.grace_seconds < 0)
        return false;

    if (_data.maximum_spawns_per_step <= 0)
        return false;

    if (_data.maximum_alive_enemies <= 0)
        return false;

    if (_data.maximum_queued_enemies <= 0)
        return false;


    // ========================================================================
    // REQUIRED SECTIONS
    // ========================================================================

    if (!is_struct(_data.baseline))
        return false;

    if (!is_struct(_data.clusters))
        return false;

    if (!is_struct(_data.waves))
        return false;

    if (!is_struct(_data.modifiers))
        return false;

    if (!is_array(_data.milestones))
        return false;


    // ========================================================================
    // BASELINE
    // ========================================================================

    if (!variable_struct_exists(_data.baseline, "pool"))
        return false;

    if (!is_array(_data.baseline.pool))
        return false;

    if (!variable_struct_exists(
        _data.baseline,
        "weight_shift_seconds"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data.baseline,
        "weight_shift_strength"
    ))
    {
        return false;
    }

    if (_data.baseline.weight_shift_seconds <= 0)
        return false;

    if (_data.baseline.weight_shift_strength < 0)
        return false;


    // ========================================================================
    // CLUSTER CONFIGURATION
    // ========================================================================

    var _clusters =
        _data.clusters;


    if (!variable_struct_exists(_clusters, "enabled"))
        return false;

    if (!variable_struct_exists(_clusters, "interval_min_seconds"))
        return false;

    if (!variable_struct_exists(_clusters, "interval_max_seconds"))
        return false;

    if (!variable_struct_exists(_clusters, "scaling_start_seconds"))
        return false;

    if (!variable_struct_exists(_clusters, "scaling_seconds"))
        return false;

    if (!variable_struct_exists(_clusters, "count_multiplier_maximum"))
        return false;

    if (!variable_struct_exists(_clusters, "zone_width_minimum"))
        return false;

    if (!variable_struct_exists(_clusters, "zone_width_maximum"))
        return false;

    if (!variable_struct_exists(_clusters, "patterns"))
        return false;

    if (!is_array(_clusters.patterns))
        return false;


    if (_clusters.interval_min_seconds < 0)
        return false;

    if (
        _clusters.interval_max_seconds
        < _clusters.interval_min_seconds
    )
    {
        return false;
    }

    if (_clusters.scaling_start_seconds < 0)
        return false;

    if (_clusters.scaling_seconds <= 0)
        return false;

    if (_clusters.count_multiplier_maximum <= 0)
        return false;

    if (_clusters.zone_width_minimum < 0)
        return false;

    if (
        _clusters.zone_width_maximum
        < _clusters.zone_width_minimum
    )
    {
        return false;
    }


    // ========================================================================
    // CLUSTER PATTERNS
    // ========================================================================

    for (
        var i = 0;
        i < array_length(_clusters.patterns);
        ++i
    )
    {
        var _pattern =
            _clusters.patterns[i];

        if (!is_struct(_pattern))
            return false;

        if (!variable_struct_exists(_pattern, "key"))
            return false;

        if (!variable_struct_exists(_pattern, "name"))
            return false;

        if (!variable_struct_exists(_pattern, "weight"))
            return false;

        if (!variable_struct_exists(_pattern, "unlock_seconds"))
            return false;

        if (!variable_struct_exists(_pattern, "count_min"))
            return false;

        if (!variable_struct_exists(_pattern, "count_max"))
            return false;

        if (!variable_struct_exists(
            _pattern,
            "stagger_min_seconds"
        ))
        {
            return false;
        }

        if (!variable_struct_exists(
            _pattern,
            "stagger_max_seconds"
        ))
        {
            return false;
        }


        if (_pattern.weight <= 0)
            return false;

        if (_pattern.unlock_seconds < 0)
            return false;

        if (_pattern.count_min < 0)
            return false;

        if (_pattern.count_max < _pattern.count_min)
            return false;

        if (_pattern.stagger_min_seconds < 0)
            return false;

        if (
            _pattern.stagger_max_seconds
            < _pattern.stagger_min_seconds
        )
        {
            return false;
        }


        var _dynamic =
            variable_struct_exists(
                _pattern,
                "dynamic"
            )
            && _pattern.dynamic;


        if (_dynamic)
        {
            if (!variable_struct_exists(
                _pattern,
                "later_enemy_bias_strength"
            ))
            {
                return false;
            }

            if (_pattern.later_enemy_bias_strength < 0)
                return false;
        }
        else
        {
            if (!variable_struct_exists(_pattern, "enemies"))
                return false;

            if (!is_array(_pattern.enemies))
                return false;

            if (array_length(_pattern.enemies) <= 0)
                return false;
        }
    }


    // ========================================================================
    // WAVES
    // ========================================================================

    if (!variable_struct_exists(_data.waves, "definitions"))
        return false;

    if (!is_array(_data.waves.definitions))
        return false;

    if (!variable_struct_exists(_data.waves, "warning_seconds"))
        return false;

    if (_data.waves.warning_seconds < 0)
        return false;

    if (!variable_struct_exists(_data.waves, "cycle_start_index"))
        return false;

    if (_data.waves.cycle_start_index < 0)
        return false;


    // ========================================================================
    // MODIFIERS
    // ========================================================================

    if (!variable_struct_exists(_data.modifiers, "definitions"))
        return false;

    if (!is_array(_data.modifiers.definitions))
        return false;


    return true;
}


/// @description Creates one data-driven enemy instance.

function scr_enemy_spawn(
    _enemy_key,
    _world_x,
    _world_y,
    _spawn_direction = undefined,
    _spawn_modifiers = [],
    _major_wave_number = 0
)
{
    var _data =
        scr_enemy_data_get(
            _enemy_key
        );

    if (!scr_enemy_data_valid(_data))
        return noone;


    var _creation_variables =
    {
        enemy_key: _enemy_key,

        spawn_modifiers:
            scr_enemy_modifiers_copy(
                _spawn_modifiers
            ),

        // Zero means this enemy did not originate from an authored wave.
        major_wave_number:
            max(0, floor(_major_wave_number))
    };


    if (!is_undefined(_spawn_direction))
    {
        variable_struct_set(
            _creation_variables,
            "spawn_direction",
            _spawn_direction
        );
    }


    return instance_create_layer(
        _world_x,
        _world_y,

        scr_layer_enemy_get(
            _data.movement.layer
        ),

        o_enemy,
        _creation_variables
    );
}

/// @description Returns one frame expressed in seconds.

function scr_enemy_spawner_step_seconds()
{
    return 1 / max(
        1,
        game_get_speed(gamespeed_fps)
    );
}

/// @description Returns one weighted entry with optional post-unlock balancing.

function scr_enemy_spawner_weighted_entry_get(
    _entries,
    _elapsed_seconds,
    _weight_shift_seconds = 0,
    _weight_shift_strength = 0
)
{
    if (!is_array(_entries))
        return undefined;

    if (array_length(_entries) <= 0)
        return undefined;


    var _available = [];
    var _available_total_weight = 0;

    var _entry_count =
        array_length(_entries);

    var _dynamic_weights =
        _weight_shift_seconds > 0
        && _weight_shift_strength > 0;


    // ========================================================================
    // CALCULATE COMPLETE POOL INFORMATION
    // ========================================================================

    var _latest_unlock_seconds = 0;

    var _pool_weight_total = 0;
    var _pool_weight_count = 0;


    if (_dynamic_weights)
    {
        for (var i = 0; i < _entry_count; ++i)
        {
            var _entry =
                _entries[i];

            if (!is_struct(_entry))
                continue;

            if (!variable_struct_exists(_entry, "weight"))
                continue;

            if (_entry.weight <= 0)
                continue;


            var _unlock_seconds = 0;

            if (variable_struct_exists(
                _entry,
                "unlock_seconds"
            ))
            {
                _unlock_seconds =
                    max(
                        0,
                        _entry.unlock_seconds
                    );
            }


            _latest_unlock_seconds =
                max(
                    _latest_unlock_seconds,
                    _unlock_seconds
                );


            _pool_weight_total +=
                _entry.weight;

            _pool_weight_count++;
        }
    }


    // ========================================================================
    // POST-UNLOCK BALANCE PROGRESS
    // ========================================================================

    var _balance_progress = 0;

    var _average_weight = 0;


    if (
        _dynamic_weights
        && _pool_weight_count > 0
    )
    {
        _average_weight =
            _pool_weight_total
            / _pool_weight_count;


        // Balancing begins only when the final pool entry has unlocked.

        var _time_progress =
            clamp(
                (
                    _elapsed_seconds
                    - _latest_unlock_seconds
                )
                / _weight_shift_seconds,
                0,
                1
            );


        // Strength controls how closely the final weights approach average:
        //
        // strength 1 = 50%
        // strength 2 = 75%
        // strength 3 = 87.5%

        var _maximum_balance =
            1 - power(
                0.5,
                _weight_shift_strength
            );


        _balance_progress =
            _time_progress
            * _maximum_balance;
    }


    // ========================================================================
    // COLLECT UNLOCKED ENTRIES
    // ========================================================================

    for (var i = 0; i < _entry_count; ++i)
    {
        var _entry =
            _entries[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "weight"))
            continue;

        if (_entry.weight <= 0)
            continue;


        var _unlock_seconds = 0;

        if (variable_struct_exists(
            _entry,
            "unlock_seconds"
        ))
        {
            _unlock_seconds =
                max(
                    0,
                    _entry.unlock_seconds
                );
        }


        if (_elapsed_seconds < _unlock_seconds)
            continue;


        var _effective_weight =
            _entry.weight;


        // Once every enemy has unlocked, gradually move each configured
        // weight toward the complete pool's average weight.
        //
        // Common enemies decrease.
        // Uncommon enemies increase.
        // Configured rarity remains partially preserved.

        if (_dynamic_weights)
        {
            _effective_weight =
                lerp(
                    _entry.weight,
                    _average_weight,
                    _balance_progress
                );
        }


        array_push(
            _available,
            {
                entry: _entry,
                weight: _effective_weight
            }
        );


        _available_total_weight +=
            _effective_weight;
    }


    if (array_length(_available) <= 0)
        return undefined;

    if (_available_total_weight <= 0)
        return undefined;


    // ========================================================================
    // WEIGHTED SELECTION
    // ========================================================================

    var _roll =
        random(
            _available_total_weight
        );

    var _running_weight =
        0;


    for (var i = 0; i < array_length(_available); ++i)
    {
        _running_weight +=
            _available[i].weight;


        if (_roll < _running_weight)
            return _available[i].entry;
    }


    // Floating-point safety fallback.

    return _available[
        array_length(_available) - 1
    ].entry;
}


/// @description Returns one random cardinal spawn side.

function scr_enemy_spawner_side_get()
{
    switch (irandom(3))
    {
        case 0:
            return SpawnSide.TOP;

        case 1:
            return SpawnSide.RIGHT;

        case 2:
            return SpawnSide.BOTTOM;

        case 3:
            return SpawnSide.LEFT;
    }


    return SpawnSide.TOP;
}


/// @description Finds a passable edge-cell position for one enemy.

function scr_enemy_spawner_edge_position_get(
    _enemy_key,
    _side,
    _edge_ratio
)
{
    var _enemy_data = scr_enemy_data_get(_enemy_key);

    if (!scr_enemy_data_valid(_enemy_data))
        return undefined;


    if (_side == SpawnSide.RANDOM)
        _side = scr_enemy_spawner_side_get();


    var _columns = global.vtd_level.map.columns;
    var _rows = global.vtd_level.map.rows;
    var _cell_size = global.vtd_level.map.cell_size;

    var _flying =
        _enemy_data.movement.layer
        == EnemyMovementLayer.FLYING;


    _edge_ratio = clamp(_edge_ratio, 0.02, 0.98);


    repeat (30)
    {
        var _ratio = clamp(
            _edge_ratio + random_range(-0.08, 0.08),
            0.02,
            0.98
        );

        var _cell_x = 1;
        var _cell_y = 1;


        switch (_side)
        {
            case SpawnSide.TOP:
                _cell_x = floor(_ratio * (_columns - 1));
                _cell_y = 1;
            break;

            case SpawnSide.RIGHT:
                _cell_x = _columns - 2;
                _cell_y = floor(_ratio * (_rows - 1));
            break;

            case SpawnSide.BOTTOM:
                _cell_x = floor(_ratio * (_columns - 1));
                _cell_y = _rows - 2;
            break;

            case SpawnSide.LEFT:
                _cell_x = 1;
                _cell_y = floor(_ratio * (_rows - 1));
            break;
        }


        _cell_x = clamp(_cell_x, 1, _columns - 2);
        _cell_y = clamp(_cell_y, 1, _rows - 2);


        var _valid = _flying;


        if (!_flying)
        {
            _valid =
                scr_world_cell_type_get(
                    _cell_x,
                    _cell_y
                )
                == WorldCellType.EMPTY;
        }


        if (_valid)
        {
            return
            {
                x:
                    (_cell_x * _cell_size)
                    + (_cell_size * 0.5),

                y:
                    (_cell_y * _cell_size)
                    + (_cell_size * 0.5)
            };
        }
    }


    return undefined;
}


/// @description Adds one weighted staggered group to the unified queue.

function scr_enemy_spawner_group_queue(
    _spawner,
    _enemy_pool,
    _count_min,
    _count_max,
    _stagger_min_seconds,
    _stagger_max_seconds,
    _side,
    _zone_center,
    _zone_width,
    _source_name
)
{
    if (!instance_exists(_spawner))
        return false;

    if (!is_array(_enemy_pool))
        return false;

    if (array_length(_enemy_pool) <= 0)
        return false;

    var _queue = _spawner.spawner.queue;

    var _queue_space =
        _spawner.spawner.data.maximum_queued_enemies
        - array_length(_queue);

    if (_queue_space <= 0)
        return false;

    var _count =
        min(
            irandom_range(
                max(0, floor(_count_min)),
                max(0, floor(_count_max))
            ),
            _queue_space
        );

    var _running_delay = 0;

    for (var i = 0; i < _count; ++i)
    {
        var _enemy_entry =
            scr_enemy_spawner_weighted_entry_get(
                _enemy_pool,
                _spawner.spawner.time.active_seconds
            );

        if (is_undefined(_enemy_entry))
            continue;

        if (
            !scr_world_current_content_allowed(
                WorldContentType.ENEMY,
                _enemy_entry.enemy_key
            )
        )
        {
            continue;
        }

        var _edge_ratio =
            clamp(
                _zone_center
                + random_range(
                    -_zone_width * 0.5,
                    _zone_width * 0.5
                ),
                0.02,
                0.98
            );

        _running_delay +=
            random_range(
                _stagger_min_seconds,
                _stagger_max_seconds
            );

        array_push(
            _queue,
            {
                enemy_key: _enemy_entry.enemy_key,

                modifiers:
                    scr_enemy_spawner_modifiers_get(
                        _spawner,
                        _enemy_entry
                    ),

                delay_seconds: _running_delay,

                side: _side,
                edge_ratio: _edge_ratio,

                source_name: _source_name,
                failed_attempts: 0
            }
        );
    }

    _spawner.spawner.queue = _queue;

    return true;
}

/// @description Adds every exact handcrafted wave group to the queue.

function scr_enemy_spawner_wave_groups_queue(
    _spawner,
    _wave,
    _wave_side,
	_wave_number
)
{
    if (!instance_exists(_spawner))
        return false;

    if (!is_struct(_wave))
        return false;

    if (!variable_struct_exists(_wave, "groups"))
        return false;

    var _queue = _spawner.spawner.queue;
    var _queued_any = false;

    for (var i = 0; i < array_length(_wave.groups); ++i)
    {
        var _group = _wave.groups[i];

        if (
            !scr_world_current_content_allowed(
                WorldContentType.ENEMY,
                _group.enemy_key
            )
        )
        {
            show_debug_message(
                "WAVE WARNING - unavailable enemy ignored: "
                + _group.enemy_key
            );

            continue;
        }

        var _group_side = _wave_side;

        if (
            variable_struct_exists(_group, "side")
            && _group.side != SpawnSide.INHERIT
        )
        {
            _group_side = _group.side;

            if (_group_side == SpawnSide.RANDOM)
            {
                _group_side =
                    scr_enemy_spawner_side_get();
            }
        }

        var _start_delay = 0;

        if (variable_struct_exists(_group, "delay_seconds"))
            _start_delay = max(0, _group.delay_seconds);

        var _stagger_min =
            _group.stagger_min_seconds;

        var _stagger_max =
            _group.stagger_max_seconds;

        var _running_delay = _start_delay;

        var _entry =
        {
            enemy_key: _group.enemy_key,
            modifiers: []
        };

        if (variable_struct_exists(_group, "modifiers"))
            _entry.modifiers = _group.modifiers;

        var _modifiers =
            scr_enemy_spawner_modifiers_get(
                _spawner,
                _entry
            );

        for (var j = 0; j < _group.count; ++j)
        {
            if (
                array_length(_queue)
                >= _spawner.spawner.data.maximum_queued_enemies
            )
            {
                break;
            }

            _running_delay +=
                random_range(
                    _stagger_min,
                    _stagger_max
                );

            array_push(
                _queue,
                {
                    enemy_key: _group.enemy_key,

                    modifiers:
                        scr_enemy_modifiers_copy(
                            _modifiers
                        ),

                    delay_seconds: _running_delay,

                    side: _group_side,
                    edge_ratio:
                        random_range(0.05, 0.95),

                    source_name: _wave.name,
					major_wave_number: _wave_number,
                    failed_attempts: 0
                }
            );

            _queued_any = true;
        }
    }

    _spawner.spawner.queue = _queue;

    return _queued_any;
}

/// @description Processes due entries within population budgets.

function scr_enemy_spawner_queue_update(
    _spawner,
    _step_seconds
)
{
    var _queue = _spawner.spawner.queue;

    var _spawn_budget =
        _spawner.spawner.data.maximum_spawns_per_step;

    var _alive_limit =
        _spawner.spawner.data.maximum_alive_enemies;

    var _alive_count =
        instance_number(o_enemy);

    var _spawned_this_step = 0;

    for (
        var i = array_length(_queue) - 1;
        i >= 0;
        --i
    )
    {
        _queue[i].delay_seconds -= _step_seconds;

        if (_queue[i].delay_seconds > 0)
            continue;

        if (_spawned_this_step >= _spawn_budget)
            continue;

        if (_alive_count >= _alive_limit)
            continue;

        var _entry = _queue[i];

        if (
            !scr_world_current_content_allowed(
                WorldContentType.ENEMY,
                _entry.enemy_key
            )
        )
        {
            array_delete(_queue, i, 1);
            continue;
        }

        var _position =
            scr_enemy_spawner_edge_position_get(
                _entry.enemy_key,
                _entry.side,
                _entry.edge_ratio
            );

        if (is_struct(_position))
        {
			
			var _major_wave_number = 0;

			if (
			    variable_struct_exists(
			        _entry,
			        "major_wave_number"
			    )
			)
			{
			    _major_wave_number =
			        _entry.major_wave_number;
			}
			
            var _enemy =
		    scr_enemy_spawn(
		        _entry.enemy_key,
		        _position.x,
		        _position.y,
		        undefined,
		        _entry.modifiers,
		        _major_wave_number
		    );

            if (instance_exists(_enemy))
            {
                _spawner.spawner.statistics.spawned_total++;

                _spawned_this_step++;
                _alive_count++;

                array_delete(_queue, i, 1);
                continue;
            }
        }

        _queue[i].failed_attempts++;
        _queue[i].side = scr_enemy_spawner_side_get();
        _queue[i].edge_ratio = random_range(0.05, 0.95);

        if (_queue[i].failed_attempts >= 60)
        {
            show_debug_message(
                "SPAWNER WARNING - discarded blocked spawn: "
                + _entry.enemy_key
            );

            array_delete(_queue, i, 1);
        }
    }

    _spawner.spawner.queue = _queue;

    return true;
}

/// @description Updates continuous baseline enemy pressure.

function scr_enemy_spawner_baseline_update(
    _spawner,
    _step_seconds
)
{
    var _data =
        _spawner.spawner.data.baseline;

    var _runtime =
        _spawner.spawner.baseline;


    if (!_data.enabled)
        return true;


    _runtime.timer -=
        _step_seconds;


    if (_runtime.timer > 0)
        return true;


    var _pressure_data =
        _spawner.spawner.data;

    var _alive_count =
        instance_number(o_enemy);

    var _queue_count =
        array_length(
            _spawner.spawner.queue
        );


    // Delay baseline spawning while either safety limit is full.

    if (
        _alive_count
            >= _pressure_data.maximum_alive_enemies
        || _queue_count
            >= _pressure_data.maximum_queued_enemies
    )
    {
        _runtime.timer = 0.5;
        return true;
    }


    // ========================================================================
    // BASELINE INTERVAL PROGRESSION
    // ========================================================================

    var _progress =
        clamp(
            _spawner.spawner.time.active_seconds
            / max(
                0.001,
                _data.scaling_seconds
            ),
            0,
            1
        );


    _runtime.current_interval =
        lerp(
            _data.interval_start_seconds,
            _data.interval_end_seconds,
            _progress
        );


    // ========================================================================
    // DYNAMIC ENEMY SELECTION
    // ========================================================================

    var _entry =
        scr_enemy_spawner_weighted_entry_get(
            _data.pool,
            _spawner.spawner.time.active_seconds,
            _data.weight_shift_seconds,
            _data.weight_shift_strength
        );


    if (
        !is_undefined(_entry)
        && scr_world_current_content_allowed(
            WorldContentType.ENEMY,
            _entry.enemy_key
        )
    )
    {
        array_push(
            _spawner.spawner.queue,
            {
                enemy_key:
                    _entry.enemy_key,

                modifiers:
                    scr_enemy_spawner_modifiers_get(
                        _spawner,
                        _entry
                    ),

                delay_seconds: 0,

                side:
                    scr_enemy_spawner_side_get(),

                edge_ratio:
                    random_range(
                        0.05,
                        0.95
                    ),

                source_name: "BASELINE",
                failed_attempts: 0
            }
        );
    }


    _runtime.timer =
        _runtime.current_interval;


    return true;
}

/// @description Updates authored and dynamically generated enemy clusters.

function scr_enemy_spawner_cluster_update(
    _spawner,
    _step_seconds
)
{
    var _data =
        _spawner.spawner.data.clusters;

    var _runtime =
        _spawner.spawner.clusters;


    if (!_data.enabled)
        return true;


    _runtime.timer -=
        _step_seconds;


    if (_runtime.timer > 0)
        return true;


    // ========================================================================
    // SELECT AUTHORED PATTERN OR DYNAMIC TEMPLATE
    // ========================================================================

    var _pattern =
        scr_enemy_spawner_weighted_entry_get(
            _data.patterns,
            _spawner.spawner.time.active_seconds
        );


    if (!is_undefined(_pattern))
    {
        var _scaling_progress =
            clamp(
                (
                    _spawner.spawner.time.active_seconds
                    - _data.scaling_start_seconds
                )
                / max(
                    0.001,
                    _data.scaling_seconds
                ),
                0,
                1
            );


        var _count_multiplier =
            lerp(
                1,
                _data.count_multiplier_maximum,
                _scaling_progress
            );


        var _dynamic =
            variable_struct_exists(
                _pattern,
                "dynamic"
            )
            && _pattern.dynamic;


        var _enemy_pool = [];


        if (_dynamic)
        {
            _enemy_pool =
                scr_enemy_spawner_dynamic_cluster_pool_create(
                    _spawner,
                    _pattern
                );
        }
        else
        {
            _enemy_pool =
                _pattern.enemies;
        }


        if (array_length(_enemy_pool) > 0)
        {
            var _side =
                scr_enemy_spawner_side_get();

            var _zone_center =
                random_range(
                    0.12,
                    0.88
                );

            var _zone_width =
                random_range(
                    _data.zone_width_minimum,
                    _data.zone_width_maximum
                );


            var _queued =
                scr_enemy_spawner_group_queue(
                    _spawner,
                    _enemy_pool,

                    _pattern.count_min
                        * _count_multiplier,

                    _pattern.count_max
                        * _count_multiplier,

                    _pattern.stagger_min_seconds,
                    _pattern.stagger_max_seconds,

                    _side,
                    _zone_center,
                    _zone_width,

                    _pattern.name
                );


            if (_queued)
            {
                _runtime.last_name =
                    _pattern.name;
            }
        }
    }


    _runtime.timer =
        random_range(
            _data.interval_min_seconds,
            _data.interval_max_seconds
        );


    return true;
}


/// @description Begins the warning for the next sequential major wave.

function scr_enemy_spawner_wave_trigger(_spawner)
{
    var _data = _spawner.spawner.data.waves;
    var _runtime = _spawner.spawner.waves;

    if (!_data.enabled)
        return false;

    if (_runtime.warning.active)
        return true;

    if (array_length(_data.definitions) <= 0)
        return false;


    // After the final authored wave, return only to the configured
    // late-game section instead of returning to Wave 1.

    if (_runtime.index >= array_length(_data.definitions))
    {
        if (!_data.cycle)
            return false;

        _runtime.index =
            clamp(
                _data.cycle_start_index,
                0,
                array_length(_data.definitions) - 1
            );
    }

    var _wave =
        _data.definitions[_runtime.index];

    var _side =
        scr_enemy_spawner_side_get();

    _runtime.warning.active = true;
    _runtime.warning.remaining = _data.warning_seconds;
    _runtime.warning.wave_index = _runtime.index;
    _runtime.warning.wave_name = _wave.name;
    _runtime.warning.side = _side;

    scr_hud_major_alert_push(
    HudAlertType.DANGER,
    "THREAT DETECTED",
    _wave.name
    + " // INBOUND FROM "
    + scr_enemy_spawner_side_name(_side),
    _data.warning_seconds
);

    return true;
}

/// @description Releases the currently warned major wave.

function scr_enemy_spawner_wave_release(_spawner)
{
    if (!instance_exists(_spawner))
        return false;


    var _data =
        _spawner.spawner.data.waves;

    var _runtime =
        _spawner.spawner.waves;

    var _warning =
        _runtime.warning;


    if (!_warning.active)
        return false;


    if (
        _warning.wave_index < 0
        || _warning.wave_index
            >= array_length(_data.definitions)
    )
    {
        _warning.active = false;
        return false;
    }


    var _wave =
        _data.definitions[
            _warning.wave_index
        ];


    var _wave_number =
    _warning.wave_index + 1;

	var _queued =
	    scr_enemy_spawner_wave_groups_queue(
	        _spawner,
	        _wave,
	        _warning.side,
	        _wave_number
	    );


    if (!_queued)
    {
        _warning.remaining = 1;
        return false;
    }


    var _side_name =
        scr_enemy_spawner_side_name(
            _warning.side
        );


    scr_level_result_wave_reached(_wave_number);


    scr_hud_major_alert_push(
        HudAlertType.DANGER,
        "WAVE ENGAGED",
        _wave.name + " // " + _side_name,
        3
    );


    _runtime.last_name =
        _wave.name;

    _runtime.index =
        _warning.wave_index + 1;


    _warning.active = false;
    _warning.remaining = 0;
    _warning.wave_index = -1;
    _warning.wave_name = "";
    _warning.side = SpawnSide.RANDOM;


    _runtime.timer =
        random_range(
            _data.interval_min_seconds,
            _data.interval_max_seconds
        );


    return true;
}


/// @description Updates wave timing and warning phases.

function scr_enemy_spawner_wave_update(
    _spawner,
    _step_seconds
)
{
    var _data =
        _spawner.spawner.data.waves;

    var _runtime =
        _spawner.spawner.waves;


    if (!_data.enabled)
        return true;


    if (_runtime.warning.active)
    {
        _runtime.warning.remaining = max(
            0,
            _runtime.warning.remaining
            - _step_seconds
        );


        if (_runtime.warning.remaining <= 0)
            scr_enemy_spawner_wave_release(_spawner);


        return true;
    }


    _runtime.timer -= _step_seconds;


    if (_runtime.timer <= 0)
        scr_enemy_spawner_wave_trigger(_spawner);


    return true;
}


/// @description Returns whether a milestone key already triggered.

function scr_enemy_spawner_milestone_reached(
    _spawner,
    _milestone_key
)
{
    var _reached =
        _spawner.spawner.milestones.reached;


    for (var i = 0; i < array_length(_reached); ++i)
    {
        if (_reached[i] == _milestone_key)
            return true;
    }


    return false;
}


/// @description Queues newly reached kill milestones.

function scr_enemy_spawner_milestone_update(_spawner)
{
    var _milestones =
        _spawner.spawner.data.milestones;

    var _kills =
        global.vtd_level.combat.kills;


    for (var i = 0; i < array_length(_milestones); ++i)
    {
        var _milestone =
            _milestones[i];


        if (_kills < _milestone.trigger_kills)
            continue;


        if (
            scr_enemy_spawner_milestone_reached(
                _spawner,
                _milestone.key
            )
        )
        {
            continue;
        }


        array_push(
            _spawner.spawner
                .milestones.reached,
            _milestone.key
        );


        var _side =
            scr_enemy_spawner_side_get();


        scr_enemy_spawner_group_queue(
            _spawner,
            _milestone.enemies,

            _milestone.count_min,
            _milestone.count_max,

            _milestone.stagger_min_seconds,
            _milestone.stagger_max_seconds,

            _side,
            0.5,
            0.9,

            _milestone.name
        );


        _spawner.spawner
            .milestones.last_name =
            _milestone.name;


        scr_hud_major_alert_push(
    HudAlertType.MILESTONE,
    "MILESTONE THREAT",
    _milestone.name
    + " // "
    + scr_enemy_spawner_side_name(_side),
    5
);


        show_debug_message(
            "MILESTONE ATTACK QUEUED: "
            + _milestone.name
        );
    }


    return true;
}


/// @description Initializes enemy pressure for the generated world.

function scr_enemy_spawner_initialize(_spawner)
{
    if (!instance_exists(_spawner))
        return false;

    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!is_struct(global.vtd_level.world.generation))
        return false;


    var _world_data =
        scr_world_data_get(
            global.vtd_level.world.generation.key
        );


    if (!scr_world_data_valid(_world_data))
        return false;

    if (!variable_struct_exists(_world_data, "pressure"))
        return false;

    if (!scr_enemy_spawner_data_valid(_world_data.pressure))
        return false;


    var _data = _world_data.pressure;


    if (!variable_struct_exists(global.vtd_level, "combat"))
    {
        global.vtd_level.combat =
        {
            kills: 0
        };
    }


    _spawner.spawner =
    {
        data: _data,

        time:
        {
            total_seconds: 0,
            active_seconds: 0,
            grace_remaining: _data.grace_seconds
        },

        baseline:
        {
            timer: _data.baseline.interval_start_seconds,
            current_interval: _data.baseline.interval_start_seconds
        },

        clusters:
        {
            timer:
                random_range(
                    _data.clusters.interval_min_seconds,
                    _data.clusters.interval_max_seconds
                ),

            last_name: ""
        },

        waves:
		{
		    timer:
		        random_range(
		            _data.waves.interval_min_seconds,
		            _data.waves.interval_max_seconds
		        ),

		    index: 0,
		    last_name: "",

		    warning:
		    {
		        active: false,
		        remaining: 0,

		        wave_index: -1,
		        wave_name: "",

		        side: SpawnSide.RANDOM
		    }
		},

        milestones:
        {
            reached: [],
            last_name: ""
        },

        queue: [],

        statistics:
        {
            spawned_total: 0
        }
    };


    global.vtd_level.entities.spawner =
        _spawner;


    show_debug_message(
        "VECTOR TD 2026 - ENEMY PRESSURE INITIALIZED"
    );


    return true;
}


/// @description Processes all enemy-pressure layers.

function scr_enemy_spawner_update(_spawner)
{
    if (!instance_exists(_spawner))
        return false;


    var _runtime = _spawner.spawner;
    var _data = _runtime.data;

    if (!_data.enabled)
        return true;


    var _step_seconds =
        scr_enemy_spawner_step_seconds();


    _runtime.time.total_seconds +=
        _step_seconds;


    // Debug: G immediately finishes the grace period.

    if (
        global.vtd.debug.enabled
        && keyboard_check_pressed(ord("G"))
    )
    {
        _runtime.time.grace_remaining = 0;
    }


    // Debug: M immediately queues the next major wave.

    if (
        global.vtd.debug.enabled
        && keyboard_check_pressed(ord("M"))
    )
    {
        scr_enemy_spawner_wave_trigger(_spawner);
    }


    if (_runtime.time.grace_remaining > 0)
    {
        _runtime.time.grace_remaining = max(
            0,
            _runtime.time.grace_remaining
            - _step_seconds
        );

        return true;
    }


    _runtime.time.active_seconds +=
        _step_seconds;


    scr_enemy_spawner_baseline_update(
        _spawner,
        _step_seconds
    );

    scr_enemy_spawner_cluster_update(
        _spawner,
        _step_seconds
    );

    scr_enemy_spawner_wave_update(
        _spawner,
        _step_seconds
    );

    scr_enemy_spawner_milestone_update(
        _spawner
    );

    scr_enemy_spawner_queue_update(
        _spawner,
        _step_seconds
    );


    return true;
}

/// @description Returns readable text for one spawn side.

function scr_enemy_spawner_side_name(_side)
{
    switch (_side)
    {
        case SpawnSide.TOP:
            return "NORTH";

        case SpawnSide.RIGHT:
            return "EAST";

        case SpawnSide.BOTTOM:
            return "SOUTH";

        case SpawnSide.LEFT:
            return "WEST";
    }


    return "UNKNOWN";
}

/// @description Returns whether an array already contains a modifier.

function scr_enemy_spawner_modifier_array_has(
    _modifiers,
    _modifier
)
{
    if (!is_array(_modifiers))
        return false;

    for (var i = 0; i < array_length(_modifiers); ++i)
    {
        if (_modifiers[i] == _modifier)
            return true;
    }

    return false;
}


/// @description Returns whether an enemy can receive one modifier.

function scr_enemy_spawner_modifier_eligible(
    _enemy_key,
    _modifier
)
{
    var _data =
        scr_enemy_data_get(_enemy_key);

    if (!scr_enemy_data_valid(_data))
        return false;

    switch (_modifier)
    {
        case EnemyModifier.SHIELDED:
        {
            return (
                variable_struct_exists(
                    _data.vitals,
                    "shield_maximum"
                )
                && _data.vitals.shield_maximum > 0
            );
        }
		
		case EnemyModifier.STEALTHED:
		{
		    // Every enemy can theoretically receive stealth.
		    // Specific exclusions can be added here later.

		    return true;
		}
    }

    return true;
}


/// @description Builds one spawn's guaranteed and randomly rolled modifiers.

function scr_enemy_spawner_modifiers_get(
    _spawner,
    _enemy_entry
)
{
    var _result = [];

    if (!instance_exists(_spawner))
        return _result;

    if (!is_struct(_enemy_entry))
        return _result;

    var _enemy_key =
        _enemy_entry.enemy_key;


    // ========================================================================
    // GUARANTEED ENTRY MODIFIERS
    // ========================================================================

    if (
        variable_struct_exists(_enemy_entry, "modifiers")
        && is_array(_enemy_entry.modifiers)
    )
    {
        for (
            var i = 0;
            i < array_length(_enemy_entry.modifiers);
            ++i
        )
        {
            var _modifier =
                _enemy_entry.modifiers[i];

            if (
                scr_enemy_spawner_modifier_eligible(
                    _enemy_key,
                    _modifier
                )
                && !scr_enemy_spawner_modifier_array_has(
                    _result,
                    _modifier
                )
            )
            {
                array_push(_result, _modifier);
            }
        }
    }


    // ========================================================================
    // TIMED LEVEL MODIFIERS
    // ========================================================================

    var _pressure =
        _spawner.spawner.data;

    if (!variable_struct_exists(_pressure, "modifiers"))
        return _result;

    var _modifier_data =
        _pressure.modifiers;

    if (!_modifier_data.enabled)
        return _result;

    var _elapsed =
        _spawner.spawner.time.active_seconds;

    for (
        var i = 0;
        i < array_length(_modifier_data.definitions);
        ++i
    )
    {
        var _definition =
            _modifier_data.definitions[i];

        if (_elapsed < _definition.unlock_seconds)
            continue;

        if (
            !scr_enemy_spawner_modifier_eligible(
                _enemy_key,
                _definition.modifier
            )
        )
        {
            continue;
        }

        if (
            scr_enemy_spawner_modifier_array_has(
                _result,
                _definition.modifier
            )
        )
        {
            continue;
        }

        var _progress =
            clamp(
                (
                    _elapsed
                    - _definition.unlock_seconds
                )
                / max(
                    0.001,
                    _definition.scaling_seconds
                ),
                0,
                1
            );

        var _chance =
            lerp(
                _definition.chance_start,
                _definition.chance_maximum,
                _progress
            );

        if (random(1) <= _chance)
        {
            array_push(
                _result,
                _definition.modifier
            );
        }
    }

    return _result;
}


/// @description Clears queued pressure runtime.

function scr_enemy_spawner_cleanup(_spawner)
{
    if (!instance_exists(_spawner))
        return false;


    if (variable_instance_exists(_spawner, "spawner"))
    {
        _spawner.spawner.queue = [];
        _spawner.spawner.milestones.reached = [];
    }


    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && variable_struct_exists(
            global.vtd_level.entities,
            "spawner"
        )
        && global.vtd_level.entities.spawner == _spawner
    )
    {
        global.vtd_level.entities.spawner = noone;
    }


    return true;
}

/// @description Spawns one enemy configuration at a random map edge.

function scr_enemy_spawn_edge(
    _enemy_key,
    _spawn_modifiers = []
)
{
    var _margin = 64;
    var _spawn_x = _margin;
    var _spawn_y = _margin;


    switch (irandom(3))
    {
        case 0:
        {
            _spawn_x =
                random_range(
                    _margin,
                    room_width - _margin
                );

            _spawn_y =
                _margin;
        }
        break;


        case 1:
        {
            _spawn_x =
                room_width - _margin;

            _spawn_y =
                random_range(
                    _margin,
                    room_height - _margin
                );
        }
        break;


        case 2:
        {
            _spawn_x =
                random_range(
                    _margin,
                    room_width - _margin
                );

            _spawn_y =
                room_height - _margin;
        }
        break;


        case 3:
        {
            _spawn_x =
                _margin;

            _spawn_y =
                random_range(
                    _margin,
                    room_height - _margin
                );
        }
        break;
    }


    return scr_enemy_spawn(
        _enemy_key,
        _spawn_x,
        _spawn_y,
        undefined,
        _spawn_modifiers
    );
}

/// @description Creates an unlocked weighted enemy pool for a dynamic cluster.

function scr_enemy_spawner_dynamic_cluster_pool_create(
    _spawner,
    _pattern
)
{
    var _result = [];


    if (!instance_exists(_spawner))
        return _result;

    if (!is_struct(_pattern))
        return _result;


    var _pressure =
        _spawner.spawner.data;

    var _clusters =
        _pressure.clusters;

    var _baseline_pool =
        _pressure.baseline.pool;

    var _elapsed =
        _spawner.spawner.time.active_seconds;


    if (!is_array(_baseline_pool))
        return _result;

    if (array_length(_baseline_pool) <= 0)
        return _result;


    // ========================================================================
    // DYNAMIC CLUSTER PROGRESSION
    // ========================================================================

    var _progress =
        clamp(
            (
                _elapsed
                - _clusters.scaling_start_seconds
            )
            / max(
                0.001,
                _clusters.scaling_seconds
            ),
            0,
            1
        );


    var _bias_strength =
        max(
            0,
            _pattern.later_enemy_bias_strength
        );

    var _pool_count =
        array_length(_baseline_pool);


    // ========================================================================
    // BUILD THE CURRENTLY AVAILABLE POOL
    // ========================================================================

    for (var i = 0; i < _pool_count; ++i)
    {
        var _entry =
            _baseline_pool[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "enemy_key"))
            continue;

        if (!variable_struct_exists(_entry, "weight"))
            continue;

        if (_entry.weight <= 0)
            continue;


        var _unlock_seconds = 0;

        if (variable_struct_exists(
            _entry,
            "unlock_seconds"
        ))
        {
            _unlock_seconds =
                max(
                    0,
                    _entry.unlock_seconds
                );
        }


        // Dynamic clusters never select locked enemies.

        if (_elapsed < _unlock_seconds)
            continue;


        if (
            !scr_world_current_content_allowed(
                WorldContentType.ENEMY,
                _entry.enemy_key
            )
        )
        {
            continue;
        }


        var _enemy_data =
            scr_enemy_data_get(
                _entry.enemy_key
            );

        if (!scr_enemy_data_valid(_enemy_data))
            continue;


        // Pool position supplies a lightweight difficulty approximation.
        // Earlier entries retain their original weight.
        // Later entries gain a gradual weight bonus as pressure scales.

        var _tier =
            i
            / max(
                1,
                _pool_count - 1
            );

        var _later_multiplier =
            power(
                2,
                _tier
                * _progress
                * _bias_strength
            );


        var _generated_entry =
        {
            enemy_key:
                _entry.enemy_key,

            weight:
                _entry.weight
                * _later_multiplier,

            // This generated pool already performed its unlock check.
            unlock_seconds: 0
        };


        // Preserve any guaranteed modifiers configured on the baseline entry.

        if (
            variable_struct_exists(
                _entry,
                "modifiers"
            )
            && is_array(_entry.modifiers)
        )
        {
            variable_struct_set(
                _generated_entry,
                "modifiers",
                scr_enemy_modifiers_copy(
                    _entry.modifiers
                )
            );
        }


        array_push(
            _result,
            _generated_entry
        );
    }


    return _result;
}