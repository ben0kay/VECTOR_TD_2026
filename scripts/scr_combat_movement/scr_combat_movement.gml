/// @description Advanced enemy combat movement and temporary player targeting.


/// @description Moves one angle toward another without wrapping incorrectly.

function scr_enemy_angle_approach(
    _current,
    _target,
    _amount
)
{
    var _difference =
        angle_difference(
            _target,
            _current
        );

    return (
        _current
        + clamp(
            _difference,
            -_amount,
            _amount
        )
        + 360
    ) mod 360;
}


/// @description Initializes optional advanced enemy runtime systems.

function scr_enemy_advanced_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _data =
        _enemy.enemy_data;

    var _initial_angle =
        _enemy.visual.draw_angle;


    // ========================================================================
    // INDEPENDENT HULL / TURRET ROTATION
    // ========================================================================

    _enemy.visual.hull_angle =
        _initial_angle;

    _enemy.visual.turret_angle =
        _initial_angle;


    // ========================================================================
    // TEMPORARY PLAYER TARGETING
    // ========================================================================

    var _player_data =
    {
        enabled: false,

        acquire_range: 0,
        lose_range: 0,
        acquire_chance: 0,

        check_interval_minimum: 1,
        check_interval_maximum: 1.5,

        lock_seconds_minimum: 3,
        lock_seconds_maximum: 5,

        reacquire_seconds: 2,

        require_line_of_sight: true,
        require_reachable: true
    };


    if (
        variable_struct_exists(
            _data.targeting,
            "player"
        )
        && is_struct(_data.targeting.player)
    )
    {
        var _source =
            _data.targeting.player;

        var _names =
            variable_struct_get_names(
                _source
            );

        for (
            var i = 0;
            i < array_length(_names);
            ++i
        )
        {
            variable_struct_set(
                _player_data,
                _names[i],
                variable_struct_get(
                    _source,
                    _names[i]
                )
            );
        }
    }


    _enemy.targeting.player =
    {
        data: _player_data,

        active: false,

        check_remaining:
            random_range(
                _player_data
                    .check_interval_minimum,

                _player_data
                    .check_interval_maximum
            ),

        lock_remaining: 0,
        reacquire_remaining: 0
    };


    // ========================================================================
    // COMBAT MOVEMENT
    // ========================================================================

    var _combat_data =
    {
        type:
            EnemyCombatMovement.STATIONARY,

        preferred_range:
            _enemy.attack.range * 0.8,

        minimum_range:
            _enemy.attack.range * 0.55,

        maximum_range:
            _enemy.attack.range,

        anchor_radius: 0,

        speed_multiplier: 1,

        hull_turn_speed: 2,
        turret_turn_speed: 6,

        reposition:
        {
            enabled: false,
            chance: 0,

            interval_minimum: 3,
            interval_maximum: 4,

            distance_minimum: 0,
            distance_maximum: 0,

            candidate_attempts: 4,
            arrival_tolerance: 5,

            require_line_of_sight: false
        }
    };


    if (
        variable_struct_exists(
            _data,
            "combat_movement"
        )
        && is_struct(_data.combat_movement)
    )
    {
        var _source =
            _data.combat_movement;

        var _names =
            variable_struct_get_names(
                _source
            );


        for (
            var i = 0;
            i < array_length(_names);
            ++i
        )
        {
            var _name =
                _names[i];

            if (_name == "reposition")
                continue;

            variable_struct_set(
                _combat_data,
                _name,
                variable_struct_get(
                    _source,
                    _name
                )
            );
        }


        if (
            variable_struct_exists(
                _source,
                "reposition"
            )
            && is_struct(_source.reposition)
        )
        {
            var _reposition_names =
                variable_struct_get_names(
                    _source.reposition
                );


            for (
                var i = 0;
                i < array_length(
                    _reposition_names
                );
                ++i
            )
            {
                var _name =
                    _reposition_names[i];

                variable_struct_set(
                    _combat_data.reposition,
                    _name,
                    variable_struct_get(
                        _source.reposition,
                        _name
                    )
                );
            }
        }
    }


    _enemy.combat_movement =
    {
        data: _combat_data,

        anchor:
        {
            x: _enemy.x,
            y: _enemy.y,

            valid: false,
            target: noone,

            navigation_revision:
                -1
        },

        destination:
        {
            x: _enemy.x,
            y: _enemy.y,
            active: false
        },

        reposition:
        {
            remaining:
                random_range(
                    _combat_data
                        .reposition
                        .interval_minimum,

                    _combat_data
                        .reposition
                        .interval_maximum
                )
        }
    };


    return true;
}


/// @description Restores an enemy's strategic target after player aggro.

function scr_enemy_player_target_restore(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _runtime =
        _enemy.targeting.player;

    _runtime.active = false;
    _runtime.lock_remaining = 0;

    _runtime.reacquire_remaining =
        max(
            0,
            _runtime.data.reacquire_seconds
        );


    if (!instance_exists(_enemy.targeting.strategic))
    {
        _enemy.targeting.strategic =
            scr_enemy_target_acquire(
                _enemy
            );
    }


    _enemy.targeting.target =
        _enemy.targeting.strategic;

    _enemy.targeting.breach =
        noone;


    if (instance_exists(_enemy.targeting.target))
    {
        _enemy.EnemyState =
            EnemyState.MOVING;

        scr_navigation_enemy_repath_request(
            _enemy,
            true
        );
    }


    return true;
}


/// @description Processes optional temporary player aggro.

function scr_enemy_player_targeting_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        !variable_struct_exists(
            _enemy.targeting,
            "player"
        )
    )
    {
        return true;
    }


    var _runtime =
        _enemy.targeting.player;

    var _data =
        _runtime.data;

    if (!_data.enabled)
        return true;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _delta =
        1 / _fps;


    _runtime.check_remaining =
        max(
            0,
            _runtime.check_remaining
            - _delta
        );

    _runtime.lock_remaining =
        max(
            0,
            _runtime.lock_remaining
            - _delta
        );

    _runtime.reacquire_remaining =
        max(
            0,
            _runtime.reacquire_remaining
            - _delta
        );


    var _player =
        global.vtd_level.entities.player;


    // ========================================================================
    // MAINTAIN EXISTING PLAYER AGGRO
    // ========================================================================

    if (_runtime.active)
    {
        if (!instance_exists(_player))
            return scr_enemy_player_target_restore(_enemy);


        var _difference_x =
            _player.x - _enemy.x;

        var _difference_y =
            _player.y - _enemy.y;

        var _distance_squared =
            (_difference_x * _difference_x)
            + (_difference_y * _difference_y);

        var _lose_range =
            max(
                _data.acquire_range,
                _data.lose_range
            );


        if (
            _distance_squared
            > _lose_range * _lose_range
        )
        {
            return scr_enemy_player_target_restore(
                _enemy
            );
        }


        // A failed player route restores the cached strategic objective.
        // This avoids repeatedly performing a separate MP-grid test here.

        if (
            _data.require_reachable
            && !_enemy.navigation.reachable
            && !_enemy.navigation.needs_path
        )
        {
            return scr_enemy_player_target_restore(
                _enemy
            );
        }


        if (_runtime.lock_remaining <= 0)
        {
            return scr_enemy_player_target_restore(
                _enemy
            );
        }


        _enemy.targeting.target =
            _player;

        return true;
    }


    // ========================================================================
    // PLAYER ACQUISITION
    // ========================================================================

    if (_runtime.reacquire_remaining > 0)
        return true;

    if (_runtime.check_remaining > 0)
        return true;


    _runtime.check_remaining =
        random_range(
            _data.check_interval_minimum,
            _data.check_interval_maximum
        );


    if (!instance_exists(_player))
        return true;


    var _difference_x =
        _player.x - _enemy.x;

    var _difference_y =
        _player.y - _enemy.y;

    var _distance_squared =
        (_difference_x * _difference_x)
        + (_difference_y * _difference_y);


    if (
        _distance_squared
        > _data.acquire_range
        * _data.acquire_range
    )
    {
        return true;
    }


    if (random(1) > _data.acquire_chance)
        return true;


    if (
        _data.require_line_of_sight
        && scr_world_line_blocked_by_dead(
            _enemy.x,
            _enemy.y,
            _player.x,
            _player.y
        )
    )
    {
        return true;
    }


    // Preserve the building/CPU objective. Only the active target changes.

    _runtime.active = true;

    _runtime.lock_remaining =
        random_range(
            _data.lock_seconds_minimum,
            _data.lock_seconds_maximum
        );


    _enemy.targeting.breach =
        noone;

    _enemy.targeting.target =
        _player;

    _enemy.navigation.reachable =
        true;

    _enemy.EnemyState =
        EnemyState.MOVING;


    scr_navigation_enemy_repath_request(
        _enemy,
        true
    );


    return true;
}


/// @description Returns target-edge distance from an arbitrary position.

function scr_enemy_target_edge_distance_at(
    _enemy,
    _target,
    _world_x,
    _world_y
)
{
    if (!instance_exists(_enemy))
        return infinity;

    if (!instance_exists(_target))
        return infinity;


    if (
        _target.object_index == o_building_par
        || object_is_ancestor(
            _target.object_index,
            o_building_par
        )
    )
    {
        var _cell_size =
            global.vtd_level.map.cell_size;

        var _half_width =
            _target.footprint.width_cells
            * _cell_size
            * 0.5;

        var _half_height =
            _target.footprint.height_cells
            * _cell_size
            * 0.5;

        var _closest_x =
            clamp(
                _world_x,
                _target.x - _half_width,
                _target.x + _half_width
            );

        var _closest_y =
            clamp(
                _world_y,
                _target.y - _half_height,
                _target.y + _half_height
            );

        return max(
            0,

            point_distance(
                _world_x,
                _world_y,
                _closest_x,
                _closest_y
            )
            - _enemy.visual.radius
            - (_cell_size * 0.25)
        );
    }


    var _target_radius = 0;


    if (
        variable_instance_exists(
            _target,
            "visual"
        )
        && is_struct(_target.visual)
        && variable_struct_exists(
            _target.visual,
            "radius"
        )
    )
    {
        _target_radius =
            _target.visual.radius;
    }


    return max(
        0,

        point_distance(
            _world_x,
            _world_y,
            _target.x,
            _target.y
        )
        - _enemy.visual.radius
        - _target_radius
    );
}


/// @description Begins a combat anchor at the enemy's current position.

function scr_enemy_combat_anchor_begin(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;


    var _anchor =
        _enemy.combat_movement.anchor;

    var _destination =
        _enemy.combat_movement.destination;

    var _reposition =
        _enemy.combat_movement.reposition;

    var _data =
        _enemy.combat_movement.data;


    _anchor.x = _enemy.x;
    _anchor.y = _enemy.y;

    _anchor.valid = true;
    _anchor.target = _target;

    _anchor.navigation_revision =
        global.vtd_level.navigation.revision;


    _destination.x = _enemy.x;
    _destination.y = _enemy.y;
    _destination.active = false;


    _reposition.remaining =
        random_range(
            _data.reposition.interval_minimum,
            _data.reposition.interval_maximum
        );


    return true;
}


/// @description Returns whether a short local movement segment remains clear.

function scr_enemy_combat_segment_clear(
    _enemy,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    if (!instance_exists(_enemy))
        return false;


    var _distance =
        point_distance(
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );

    var _sample_distance =
        max(
            4,
            _enemy.visual.radius * 0.4
        );

    var _steps =
        max(
            1,
            ceil(
                _distance
                / _sample_distance
            )
        );


    for (var i = 1; i <= _steps; ++i)
    {
        var _amount =
            i / _steps;

        var _check_x =
            lerp(
                _start_x,
                _end_x,
                _amount
            );

        var _check_y =
            lerp(
                _start_y,
                _end_y,
                _amount
            );


        if (
            scr_world_circle_gameplay_solid(
                _check_x,
                _check_y,
                _enemy.visual.radius,
                true
            )
        )
        {
            return false;
        }
    }


    return true;
}


/// @description Returns whether a local combat destination is usable.

function scr_enemy_combat_destination_valid(
    _enemy,
    _target,
    _world_x,
    _world_y
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;


    var _data =
        _enemy.combat_movement.data;

    var _reposition =
        _data.reposition;


    if (
        _world_x < _enemy.visual.radius
        || _world_x
            > room_width
            - _enemy.visual.radius

        || _world_y < _enemy.visual.radius
        || _world_y
            > room_height
            - _enemy.visual.radius
    )
    {
        return false;
    }


    if (
        point_distance(
            _enemy.combat_movement.anchor.x,
            _enemy.combat_movement.anchor.y,
            _world_x,
            _world_y
        )
        > _data.anchor_radius
    )
    {
        return false;
    }


    var _target_distance =
        scr_enemy_target_edge_distance_at(
            _enemy,
            _target,
            _world_x,
            _world_y
        );


    if (
        _target_distance < _data.minimum_range
        || _target_distance > _data.maximum_range
    )
    {
        return false;
    }


    if (
        scr_world_circle_gameplay_solid(
            _world_x,
            _world_y,
            _enemy.visual.radius,
            true
        )
    )
    {
        return false;
    }


    if (
        !scr_enemy_combat_segment_clear(
            _enemy,
            _enemy.x,
            _enemy.y,
            _world_x,
            _world_y
        )
    )
    {
        return false;
    }


    if (
        _reposition.require_line_of_sight
        && scr_world_line_blocked_by_dead(
            _world_x,
            _world_y,
            _target.x,
            _target.y
        )
    )
    {
        return false;
    }


    return true;
}


/// @description Attempts to choose a new point inside the combat anchor.

function scr_enemy_combat_destination_choose(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;


    var _runtime =
        _enemy.combat_movement;

    var _data =
        _runtime.data;

    var _reposition =
        _data.reposition;

    var _attempts =
        max(
            1,
            floor(
                _reposition.candidate_attempts
            )
        );


    repeat (_attempts)
    {
        var _direction =
            random(360);

        var _distance =
            random_range(
                _reposition.distance_minimum,
                _reposition.distance_maximum
            );

        var _candidate_x =
            _runtime.anchor.x
            + lengthdir_x(
                _distance,
                _direction
            );

        var _candidate_y =
            _runtime.anchor.y
            + lengthdir_y(
                _distance,
                _direction
            );


        if (
            !scr_enemy_combat_destination_valid(
                _enemy,
                _target,
                _candidate_x,
                _candidate_y
            )
        )
        {
            continue;
        }


        _runtime.destination.x =
            _candidate_x;

        _runtime.destination.y =
            _candidate_y;

        _runtime.destination.active =
            true;


        return true;
    }


    _runtime.destination.active =
        false;

    return false;
}


/// @description Moves an anchored enemy toward its local destination.

function scr_enemy_combat_destination_move(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _runtime =
        _enemy.combat_movement;

    var _destination =
        _runtime.destination;

    var _data =
        _runtime.data;


    if (!_destination.active)
        return true;


    var _distance =
        point_distance(
            _enemy.x,
            _enemy.y,
            _destination.x,
            _destination.y
        );


    if (
        _distance
        <= _data.reposition.arrival_tolerance
    )
    {
        _enemy.x =
            _destination.x;

        _enemy.y =
            _destination.y;

        _destination.active =
            false;

        return true;
    }


    var _move_direction =
        point_direction(
            _enemy.x,
            _enemy.y,
            _destination.x,
            _destination.y
        );

    var _move_amount =
        min(
            _distance,

            _enemy.movement.speed
            * _data.speed_multiplier
        );

    var _next_x =
        _enemy.x
        + lengthdir_x(
            _move_amount,
            _move_direction
        );

    var _next_y =
        _enemy.y
        + lengthdir_y(
            _move_amount,
            _move_direction
        );


    if (
        scr_world_circle_gameplay_solid(
            _next_x,
            _next_y,
            _enemy.visual.radius,
            true
        )
    )
    {
        _destination.active =
            false;

        return false;
    }


    _enemy.x = _next_x;
    _enemy.y = _next_y;


    _enemy.visual.hull_angle =
        scr_enemy_angle_approach(
            _enemy.visual.hull_angle,
            _move_direction,
            _data.hull_turn_speed
        );

    _enemy.visual.draw_angle =
        _enemy.visual.hull_angle;


    return true;
}


/// @description Processes one enemy's reusable combat movement.

function scr_enemy_combat_movement_update(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;


    var _runtime =
        _enemy.combat_movement;

    var _data =
        _runtime.data;


    if (
        _data.type
        != EnemyCombatMovement.ANCHOR_ROAM
    )
    {
        return true;
    }


    if (
        !_runtime.anchor.valid
        || _runtime.anchor.target != _target
    )
    {
        scr_enemy_combat_anchor_begin(
            _enemy,
            _target
        );
    }


    // Existing construction may invalidate the local destination.

    if (
        _runtime.anchor.navigation_revision
        != global.vtd_level.navigation.revision
    )
    {
        _runtime.anchor.navigation_revision =
            global.vtd_level.navigation.revision;

        _runtime.destination.active =
            false;

        _runtime.reposition.remaining =
            random_range(
                0.25,
                0.75
            );
    }


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _runtime.reposition.remaining =
        max(
            0,
            _runtime.reposition.remaining
            - (1 / _fps)
        );


    if (
        !_runtime.destination.active
        && _runtime.reposition.remaining <= 0
    )
    {
        _runtime.reposition.remaining =
            random_range(
                _data.reposition.interval_minimum,
                _data.reposition.interval_maximum
            );


        if (
            _data.reposition.enabled
            && random(1)
                <= _data.reposition.chance
        )
        {
            scr_enemy_combat_destination_choose(
                _enemy,
                _target
            );
        }
    }


    return scr_enemy_combat_destination_move(
        _enemy
    );
}