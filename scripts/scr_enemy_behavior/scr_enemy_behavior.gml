function scr_enemy_behavior_standard_update(_enemy)
{
    switch (_enemy.EnemyState)
    {
        case EnemyState.MOVING:
        {
            // Native path movement continues automatically.
            scr_navigation_enemy_update(_enemy);

            if (!IFRAMES_5)
                return true;


            // ------------------------------------------------------------
            // BUILDING HUNTER
            // ------------------------------------------------------------

            if (_enemy.targeting.target_type == EnemyTarget.BUILDING
                && !_enemy.targeting.player.active)
            {
                var _dx = _enemy.targeting.target_x - _enemy.x;
                var _dy = _enemy.targeting.target_y - _enemy.y;

                var _distance_squared =
                    (_dx * _dx) + (_dy * _dy);

                var _arrival_range =
                    _enemy.attack.range
                    + global.vtd_level.map.cell_size;

                // Still travelling toward remembered location.
                if (_distance_squared > _arrival_range * _arrival_range)
                    return true;

                // Only NOW does the enemy discover whether the building
                // still exists.
                if (!instance_exists(_enemy.targeting.strategic))
                {
                    var _replacement =
                        scr_enemy_target_acquire(_enemy);

                    scr_enemy_strategic_target_set(_enemy, _replacement);

                    if (instance_exists(_replacement))
                        scr_navigation_enemy_repath_request(_enemy, true);

                    return true;
                }
            }


            // ------------------------------------------------------------
            // LIVE TARGET RANGE CHECK
            // ------------------------------------------------------------

            var _target = _enemy.targeting.target;

            if (!instance_exists(_target))
                return true;

            var _edge_distance =
                scr_enemy_target_edge_distance(_enemy, _target);

            var _can_attack =
                _edge_distance <= _enemy.attack.range;

            if (_can_attack && _enemy.attack.requires_line_of_sight)
                _can_attack =
                    scr_enemy_attack_line_of_sight_clear(_enemy, _target);

            if (_can_attack)
            {
                scr_navigation_enemy_stop(_enemy);
                _enemy.EnemyState = EnemyState.ATTACKING;
            }

            return true;
        }


        case EnemyState.ATTACKING:
        {
            var _target = _enemy.targeting.target;

            if (!instance_exists(_target))
            {
                _enemy.EnemyState = EnemyState.MOVING;

                if (_enemy.targeting.target_type == EnemyTarget.BUILDING)
                {
                    var _replacement =
                        scr_enemy_target_acquire(_enemy);

                    scr_enemy_strategic_target_set(_enemy, _replacement);

                    if (instance_exists(_replacement))
                        scr_navigation_enemy_repath_request(_enemy, true);
                }

                return true;
            }

            var _edge_distance =
                scr_enemy_target_edge_distance(_enemy, _target);

            var _can_attack =
                _edge_distance <= _enemy.attack.range;

            if (_can_attack && _enemy.attack.requires_line_of_sight)
                _can_attack =
                    scr_enemy_attack_line_of_sight_clear(_enemy, _target);

            if (!_can_attack)
            {
                _enemy.EnemyState = EnemyState.MOVING;
                scr_navigation_enemy_repath_request(_enemy, true);
                return true;
            }

            if (_enemy.attack.cooldown.remaining <= 0)
                scr_enemy_attack(_enemy);

            return true;
        }


        case EnemyState.STUNNED:
        case EnemyState.DEAD:
            scr_navigation_enemy_stop(_enemy);
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