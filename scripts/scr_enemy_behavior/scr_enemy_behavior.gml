/// @description Processes ordinary enemy movement and attacks.

function scr_enemy_behavior_standard_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _target =
        _enemy.targeting.target;

    if (!instance_exists(_target))
        return true;


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
                <= _enemy.attack.range;


            // Non-LOS enemies never call the LOS function.

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
                <= _enemy.attack.range;


            // Non-LOS enemies never call the LOS function.

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

/// @description Dispatches one enemy's configured primary behavior.

function scr_enemy_behavior_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    switch (_enemy.EnemyBehavior)
    {
        case EnemyBehavior.STANDARD:
        {
            return scr_enemy_behavior_standard_update(
                _enemy
            );
        }


        case EnemyBehavior.BRAINLESS:
        {
            return scr_enemy_brainless_update(
                _enemy
            );
        }


        case EnemyBehavior.ORBIT:
        {
            return scr_enemy_orbit_update(
                _enemy
            );
        }


        case EnemyBehavior.STANDOFF:
        {
            return scr_enemy_standoff_update(
                _enemy
            );
        }


        case EnemyBehavior.ANCHOR_BEAM:
        {
            return scr_enemy_siege_beam_update(
                _enemy
            );
        }


        case EnemyBehavior.SUPPORT:
        {
            return scr_enemy_shield_generator_update(
                _enemy
            );
        }
    }


    show_debug_message(
        "ENEMY BEHAVIOR ERROR - unsupported behavior: "
        + string(_enemy.EnemyBehavior)
    );


    return false;
}