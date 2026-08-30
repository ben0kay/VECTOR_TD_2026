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

function scr_enemy_combat_segment_clear(_enemy, _start_x, _start_y, _end_x, _end_y)
{
    if (!instance_exists(_enemy))
        return false;

    return collision_line(
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        o_solid_par,
        false,
        true
    ) == noone;
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
	    collision_circle(
	        _world_x,
	        _world_y,
	        _enemy.visual.radius,
	        o_solid_par,
	        false,
	        true
	    ) != noone
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
	    collision_circle(
	        _next_x,
	        _next_y,
	        _enemy.visual.radius,
	        o_solid_par,
	        false,
	        true
	    ) != noone
	)
	{
	    _destination.active = false;
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



/// @description Processes a ranged enemy seeking a clear standoff position.

function scr_enemy_standoff_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _target =
        _enemy.targeting.target;

    if (!instance_exists(_target))
        return true;


    var _data =
        _enemy.combat_movement.data;


    var _edge_distance =
        scr_enemy_target_edge_distance(
            _enemy,
            _target
        );


    switch (_enemy.EnemyState)
    {
        case EnemyState.SPAWNING:
        {
            _enemy.EnemyState =
                EnemyState.MOVING;

            scr_navigation_enemy_repath_request(
                _enemy,
                true
            );
        }
        break;


        case EnemyState.MOVING:
        {
            var _attack_position_valid =
                _edge_distance
                <= _data.preferred_range
                && _edge_distance
                >= _data.minimum_range;


            if (
                _attack_position_valid
                && _enemy.attack.requires_line_of_sight
            )
            {
                _attack_position_valid =
                    scr_enemy_attack_line_of_sight_clear(
                        _enemy,
                        _target
                    );
            }


            if (_attack_position_valid)
            {
                scr_navigation_enemy_stop(
                    _enemy
                );

                _enemy.EnemyState =
                    EnemyState.ATTACKING;

                break;
            }


            // Continue approaching until a valid firing position is found.

            scr_navigation_enemy_update(
                _enemy
            );
        }
        break;


        case EnemyState.ATTACKING:
        {
            _enemy.visual.draw_angle =
                point_direction(
                    _enemy.x,
                    _enemy.y,
                    _target.x,
                    _target.y
                );


            var _attack_position_valid =
                _edge_distance
                <= _data.maximum_range
                && _edge_distance
                >= _data.minimum_range;


            if (
                _attack_position_valid
                && _enemy.attack.requires_line_of_sight
            )
            {
                _attack_position_valid =
                    scr_enemy_attack_line_of_sight_clear(
                        _enemy,
                        _target
                    );
            }


            if (!_attack_position_valid)
            {
                _enemy.EnemyState =
                    EnemyState.MOVING;

                scr_navigation_enemy_repath_request(
                    _enemy,
                    true
                );

                break;
            }


            if (_enemy.attack.cooldown.remaining <= 0)
            {
                scr_enemy_attack(
                    _enemy
                );
            }
        }
        break;


        case EnemyState.STUNNED:
        case EnemyState.DEAD:
        {
            scr_navigation_enemy_stop(
                _enemy
            );
        }
        break;
    }


    return true;
}

