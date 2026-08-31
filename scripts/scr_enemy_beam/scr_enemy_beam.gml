/// @description Returns the Siege Beam's extending geometry.

function scr_enemy_siege_beam_geometry_get(_enemy, _target)
{
    var _beam = _enemy.attack.beam;
    var _muzzle_distance = _enemy.visual.radius * 1.22;

    var _start_x =
        _enemy.x
        + lengthdir_x(
            _muzzle_distance,
            _enemy.visual.turret_angle
        );

    var _start_y =
        _enemy.y
        + lengthdir_y(
            _muzzle_distance,
            _enemy.visual.turret_angle
        );

    var _target_x = instance_exists(_target) ? _target.x : _start_x;
    var _target_y = instance_exists(_target) ? _target.y : _start_y;

    var _direction =
        point_direction(
            _start_x,
            _start_y,
            _target_x,
            _target_y
        );

    var _full_length =
        point_distance(
            _start_x,
            _start_y,
            _target_x,
            _target_y
        );

    var _current_length =
        min(
            _beam.reach,
            _full_length
        );

    return
    {
        start_x: _start_x,
        start_y: _start_y,

        end_x:
            _start_x
            + lengthdir_x(
                _current_length,
                _direction
            ),

        end_y:
            _start_y
            + lengthdir_y(
                _current_length,
                _direction
            ),

        target_x: _target_x,
        target_y: _target_y,

        direction: _direction,
        full_length: _full_length,
        current_length: _current_length
    };
}


/// @description Removes and resets one Siege Beam.

function scr_enemy_siege_beam_hitbox_stop(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _beam = _enemy.attack.beam;

    if (!is_struct(_beam))
        return true;

    _beam.hitbox =
        scr_beam_hitbox_remove(
            _beam.hitbox
        );

    _beam.reach = 0;
    _beam.target = noone;

    return true;
}


/// @description Extends and updates one Siege Beam hitbox.

function scr_enemy_siege_beam_hitbox_update(_enemy, _target)
{
    if (!instance_exists(_enemy) || !instance_exists(_target))
        return false;

    var _beam = _enemy.attack.beam;

    if (!is_struct(_beam))
        return false;

    var _area = _beam.area;

    if (!is_struct(_area))
        return false;

    if (_area.shape != AttackAreaShape.CAPSULE)
        return false;


    // Reset extension when switching targets.

    if (_beam.target != _target)
    {
        _beam.target = _target;
        _beam.reach = 0;
    }


    var _geometry =
        scr_enemy_siege_beam_geometry_get(
            _enemy,
            _target
        );

    var _beam_data =
        _enemy.enemy_data
            .ability_data
            .beam;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    _beam.reach =
        min(
            _geometry.full_length,
            _beam.reach
            + (_beam_data.extension_speed / _fps)
        );


    // Recalculate using the newly extended reach.

    _geometry =
        scr_enemy_siege_beam_geometry_get(
            _enemy,
            _target
        );


    if (!instance_exists(_beam.hitbox))
    {
        _beam.hitbox =
            scr_beam_hitbox_create(
                _enemy,
                DamageSource.ENEMY,
                DamageType.LASER,
                _enemy.attack.damage,
                _area.radius,
                EnemyMovementLayer.GROUND
            );
    }

    if (!instance_exists(_beam.hitbox))
        return false;

    return scr_beam_hitbox_geometry_set(
        _beam.hitbox,
        _geometry.start_x,
        _geometry.start_y,
        _geometry.end_x,
        _geometry.end_y
    );
}

/// @description Processes the mobile piercing Siege Beam platform.

function scr_enemy_siege_beam_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _target = _enemy.targeting.target;

    if (!instance_exists(_target))
    {
        scr_enemy_siege_beam_hitbox_stop(_enemy);
        return true;
    }

    var _combat = _enemy.combat_movement;
    var _data = _combat.data;


    switch (_enemy.EnemyState)
    {
        case EnemyState.SPAWNING:
        {
            scr_enemy_siege_beam_hitbox_stop(_enemy);

            _enemy.EnemyState = EnemyState.MOVING;
            scr_navigation_enemy_repath_request(_enemy, true);
        }
        break;


        case EnemyState.MOVING:
        {
            scr_enemy_siege_beam_hitbox_stop(_enemy);

            var _distance =
                scr_enemy_target_edge_distance(
                    _enemy,
                    _target
                );

            if (_distance <= _data.preferred_range)
            {
                var _geometry =
                    scr_enemy_siege_beam_geometry_get(
                        _enemy,
                        _target
                    );

                var _blocked =
                    scr_world_line_blocked_by_dead(
                        _geometry.start_x,
                        _geometry.start_y,
                        _geometry.target_x,
                        _geometry.target_y
                    );

                if (!_blocked)
                {
                    scr_navigation_enemy_stop(_enemy);
                    _enemy.EnemyState = EnemyState.ATTACKING;

                    if (!scr_enemy_combat_anchor_begin(_enemy, _target))
                    {
                        show_debug_message(
                            "ENEMY COMBAT ERROR - siege beam anchor failed: "
                            + _enemy.identity.key
                        );

                        return false;
                    }
                }
            }

            if (_enemy.EnemyState == EnemyState.MOVING)
                scr_navigation_enemy_update(_enemy);
        }
        break;


        case EnemyState.ATTACKING:
        {
            var _distance =
                scr_enemy_target_edge_distance(
                    _enemy,
                    _target
                );

            var _geometry =
                scr_enemy_siege_beam_geometry_get(
                    _enemy,
                    _target
                );

            var _blocked =
                scr_world_line_blocked_by_dead(
                    _geometry.start_x,
                    _geometry.start_y,
                    _geometry.target_x,
_geometry.target_y
                );

            if (
                _distance > _data.maximum_range
                || _blocked
            )
            {
                scr_enemy_siege_beam_hitbox_stop(_enemy);

                _combat.anchor.valid = false;
                _combat.destination.active = false;
                _enemy.EnemyState = EnemyState.MOVING;

                scr_navigation_enemy_repath_request(_enemy, true);
                break;
            }

            var _target_angle =
                point_direction(
                    _enemy.x,
                    _enemy.y,
                    _target.x,
                    _target.y
                );

            _enemy.visual.turret_angle =
                scr_enemy_angle_approach(
                    _enemy.visual.turret_angle,
                    _target_angle,
                    _data.turret_turn_speed
                );

            scr_enemy_combat_movement_update(
                _enemy,
                _target
            );

            if (
                !scr_enemy_siege_beam_hitbox_update(
                    _enemy,
                    _target
                )
            )
            {
                show_debug_message(
                    "ENEMY ATTACK ERROR - siege beam hitbox failed: "
                    + _enemy.identity.key
                );

                return false;
            }
        }
        break;


        case EnemyState.STUNNED:
        case EnemyState.DEAD:
        {
            scr_enemy_siege_beam_hitbox_stop(_enemy);
            scr_navigation_enemy_stop(_enemy);

            _combat.destination.active = false;
        }
        break;
    }

    return true;
}