/// @description Data-driven baseline, cluster, wave, and milestone spawning.


/// @description Returns whether pressure configuration contains core data.

function scr_enemy_spawner_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!variable_struct_exists(_data, "enabled"))
        return false;

    if (!variable_struct_exists(_data, "grace_seconds"))
        return false;

    if (!variable_struct_exists(_data, "maximum_spawns_per_step"))
        return false;

    if (!variable_struct_exists(_data, "baseline"))
        return false;

    if (!variable_struct_exists(_data, "clusters"))
        return false;

    if (!variable_struct_exists(_data, "waves"))
        return false;

    if (!variable_struct_exists(_data, "milestones"))
        return false;


    if (!is_struct(_data.baseline))
        return false;

    if (!is_struct(_data.clusters))
        return false;

    if (!is_struct(_data.waves))
        return false;

    if (!is_array(_data.milestones))
        return false;

    if (_data.grace_seconds < 0)
        return false;

    if (_data.maximum_spawns_per_step <= 0)
        return false;
	
	if (!variable_struct_exists(_data, "maximum_alive_enemies"))
    return false;

	if (!variable_struct_exists(_data, "maximum_queued_enemies"))
    return false;
	
	if (_data.maximum_alive_enemies <= 0)
    return false;

	if (_data.maximum_queued_enemies <= 0)
    return false;
	
	if (!variable_struct_exists(_data.waves, "warning_seconds"))
    return false;

	if (_data.waves.warning_seconds < 0)
    return false;

    if (!is_array(_data.baseline.pool))
        return false;

    if (!is_array(_data.clusters.patterns))
        return false;

    if (!is_array(_data.waves.definitions))
        return false;


    return true;
}


/// @description Returns one frame expressed in seconds.

function scr_enemy_spawner_step_seconds()
{
    return 1 / max(
        1,
        game_get_speed(gamespeed_fps)
    );
}


/// @description Returns one weighted entry unlocked at the current time.

function scr_enemy_spawner_weighted_entry_get(
    _entries,
    _elapsed_seconds
)
{
    if (!is_array(_entries))
        return undefined;


    var _available = [];
    var _total_weight = 0;


    for (var i = 0; i < array_length(_entries); ++i)
    {
        var _entry = _entries[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "weight"))
            continue;

        if (_entry.weight <= 0)
            continue;


        var _unlock_seconds = 0;

        if (variable_struct_exists(_entry, "unlock_seconds"))
            _unlock_seconds = _entry.unlock_seconds;


        if (_elapsed_seconds < _unlock_seconds)
            continue;


        array_push(_available, _entry);
        _total_weight += _entry.weight;
    }


    if (array_length(_available) <= 0)
        return undefined;


    var _roll = random(_total_weight);
    var _running_weight = 0;


    for (var i = 0; i < array_length(_available); ++i)
    {
        _running_weight += _available[i].weight;

        if (_roll < _running_weight)
            return _available[i];
    }


    return _available[0];
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


/// @description Adds a staggered group to the unified queue.

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


    var _queue =
        _spawner.spawner.queue;

    var _queue_space =
        _spawner.spawner.data
            .maximum_queued_enemies
        - array_length(_queue);


    if (_queue_space <= 0)
        return false;


    var _count = min(
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


        var _edge_ratio = clamp(
            _zone_center
            + random_range(
                -_zone_width * 0.5,
                _zone_width * 0.5
            ),
            0.02,
            0.98
        );


        _running_delay += random_range(
            _stagger_min_seconds,
            _stagger_max_seconds
        );


        array_push(
            _queue,
            {
                enemy_key: _enemy_entry.enemy_key,
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

/// @description Processes due entries within population budgets.

function scr_enemy_spawner_queue_update(
    _spawner,
    _step_seconds
)
{
    var _queue =
        _spawner.spawner.queue;

    var _spawn_budget =
        _spawner.spawner.data
            .maximum_spawns_per_step;

    var _alive_limit =
        _spawner.spawner.data
            .maximum_alive_enemies;

    var _alive_count =
        instance_number(o_enemy);

    var _spawned_this_step = 0;


    for (
        var i = array_length(_queue) - 1;
        i >= 0;
        --i
    )
    {
        _queue[i].delay_seconds -=
            _step_seconds;


        if (_queue[i].delay_seconds > 0)
            continue;

        if (_spawned_this_step >= _spawn_budget)
            continue;

        if (_alive_count >= _alive_limit)
            continue;


        var _entry = _queue[i];

        var _position =
            scr_enemy_spawner_edge_position_get(
                _entry.enemy_key,
                _entry.side,
                _entry.edge_ratio
            );


        if (is_struct(_position))
        {
            var _enemy = scr_enemy_spawn(
                _entry.enemy_key,
                _position.x,
                _position.y
            );


            if (instance_exists(_enemy))
            {
                _spawner.spawner
                    .statistics.spawned_total++;

                _spawned_this_step++;
                _alive_count++;

                array_delete(_queue, i, 1);
                continue;
            }
        }


        _queue[i].failed_attempts++;

        _queue[i].side =
            scr_enemy_spawner_side_get();

        _queue[i].edge_ratio =
            random_range(0.05, 0.95);


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


/// @description Updates continuous baseline pressure.

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


    _runtime.timer -= _step_seconds;

    if (_runtime.timer > 0)
        return true;


    var _pressure_data =
        _spawner.spawner.data;

    var _alive_count =
        instance_number(o_enemy);

    var _queue_count =
        array_length(_spawner.spawner.queue);


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


    var _progress = clamp(
        _spawner.spawner.time.active_seconds
        / max(0.001, _data.scaling_seconds),
        0,
        1
    );


    _runtime.current_interval = lerp(
        _data.interval_start_seconds,
        _data.interval_end_seconds,
        _progress
    );


    var _entry =
        scr_enemy_spawner_weighted_entry_get(
            _data.pool,
            _spawner.spawner.time.active_seconds
        );


    if (!is_undefined(_entry))
    {
        array_push(
            _spawner.spawner.queue,
            {
                enemy_key: _entry.enemy_key,
                delay_seconds: 0,

                side: scr_enemy_spawner_side_get(),
                edge_ratio: random_range(0.05, 0.95),

                source_name: "BASELINE",
                failed_attempts: 0
            }
        );
    }


    _runtime.timer =
        _runtime.current_interval;


    return true;
}

/// @description Updates random localized enemy clusters.

function scr_enemy_spawner_cluster_update(
    _spawner,
    _step_seconds
)
{
    var _data = _spawner.spawner.data.clusters;
    var _runtime = _spawner.spawner.clusters;

    if (!_data.enabled)
        return true;


    _runtime.timer -= _step_seconds;

    if (_runtime.timer > 0)
        return true;


    var _pattern =
        scr_enemy_spawner_weighted_entry_get(
            _data.patterns,
            _spawner.spawner.time.active_seconds
        );


    if (!is_undefined(_pattern))
    {
        var _scaling_progress = clamp(
            (
                _spawner.spawner.time.active_seconds
                - _data.scaling_start_seconds
            )
            / max(0.001, _data.scaling_seconds),
            0,
            1
        );

        var _multiplier = lerp(
            1,
            _data.count_multiplier_maximum,
            _scaling_progress
        );

        var _side =
            scr_enemy_spawner_side_get();

        var _zone_center =
            random_range(0.12, 0.88);

        var _zone_width =
            random_range(
                _data.zone_width_minimum,
                _data.zone_width_maximum
            );


        scr_enemy_spawner_group_queue(
            _spawner,
            _pattern.enemies,

            _pattern.count_min * _multiplier,
            _pattern.count_max * _multiplier,

            _pattern.stagger_min_seconds,
            _pattern.stagger_max_seconds,

            _side,
            _zone_center,
            _zone_width,

            _pattern.name
        );


        _runtime.last_name = _pattern.name;
    }


    _runtime.timer = random_range(
        _data.interval_min_seconds,
        _data.interval_max_seconds
    );


    return true;
}


/// @description Begins the warning for the next major wave.

function scr_enemy_spawner_wave_trigger(_spawner)
{
    var _data =
        _spawner.spawner.data.waves;

    var _runtime =
        _spawner.spawner.waves;


    if (!_data.enabled)
        return false;

    if (_runtime.warning.active)
        return true;

    if (array_length(_data.definitions) <= 0)
        return false;


    if (_runtime.index >= array_length(_data.definitions))
    {
        if (_data.cycle)
            _runtime.index = 0;
        else
            return false;
    }


    var _wave =
        _data.definitions[_runtime.index];

    var _side =
        scr_enemy_spawner_side_get();


    _runtime.warning.active = true;
    _runtime.warning.remaining = _data.warning_seconds;

    _runtime.warning.wave_index =
        _runtime.index;

    _runtime.warning.wave_name =
        _wave.name;

    _runtime.warning.side =
        _side;


    scr_hud_alert_push(
        HudAlertType.DANGER,
        "THREAT DETECTED",
        _wave.name
        + " // INBOUND FROM "
        + scr_enemy_spawner_side_name(_side),
        _data.warning_seconds
    );


    show_debug_message(
        "MAJOR WAVE WARNING: "
        + _wave.name
    );


    return true;
}


/// @description Releases a warned wave into the spawn queue.

function scr_enemy_spawner_wave_release(_spawner)
{
    if (!instance_exists(_spawner))
        return false;


    var _data = _spawner.spawner.data.waves;
    var _runtime = _spawner.spawner.waves;
    var _warning = _runtime.warning;

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
        _data.definitions[_warning.wave_index];

    var _queued =
        scr_enemy_spawner_group_queue(
            _spawner,
            _wave.enemies,

            _wave.count_min,
            _wave.count_max,

            _wave.stagger_min_seconds,
            _wave.stagger_max_seconds,

            _warning.side,
            0.5,
            0.9,

            _wave.name
        );


    // Keep trying if the queue is temporarily full.

    if (!_queued)
    {
        _warning.remaining = 1;
        return false;
    }


    var _side_name =
        scr_enemy_spawner_side_name(
            _warning.side
        );


    scr_hud_alert_push(
        HudAlertType.DANGER,
        "WAVE ENGAGED",
        _wave.name
        + " // "
        + _side_name,
        3
    );


    show_debug_message(
        "MAJOR WAVE RELEASED: "
        + _wave.name
        + " FROM "
        + _side_name
    );


    _runtime.last_name = _wave.name;
    _runtime.index = _warning.wave_index + 1;

    _warning.active = false;
    _warning.remaining = 0;
    _warning.wave_index = -1;
    _warning.wave_name = "";
    _warning.side = SpawnSide.RANDOM;

    _runtime.timer = random_range(
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


        scr_hud_alert_push(
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