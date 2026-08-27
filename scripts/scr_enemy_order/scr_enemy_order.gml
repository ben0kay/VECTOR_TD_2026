/// @description Enemy tactical-order runtime and target acquisition.


/// ============================================================================
/// RUNTIME
/// ============================================================================

function scr_enemy_order_runtime_create()
{
    return
    {
        type:
            EnemyOrder.NONE,

        target:
            noone,

        player_follow:
        {
            remaining:
                0,

            interval_seconds:
                0.35,

            minimum_distance:
                32,

            x:
                0,

            y:
                0
        }
    };
}


/// @description Returns whether an enemy currently has an active tactical order.

function scr_enemy_order_active(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_enemy.order))
        return false;

    return
        _enemy.order.type
        != EnemyOrder.NONE;
}


/// ============================================================================
/// PATHABLE TARGET ACQUISITION
/// ============================================================================

/// @description Returns whether this enemy can currently path to a target.

function scr_enemy_order_target_pathable(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;


    var _grid =
        scr_navigation_enemy_grid_get(
            _enemy
        );

    if (_grid < 0)
        return false;


    return scr_navigation_path_to_target(
        _enemy,
        _target,
        _grid,
        _enemy.navigation.path_id
    );
}


/// @description Returns the closest valid pathable instance of one object type.

function scr_enemy_order_closest_pathable_get(
    _enemy,
    _object
)
{
    if (!instance_exists(_enemy))
        return noone;


    var _best =
        noone;

    var _best_distance =
        infinity;

    var _count =
        instance_number(_object);

    for (
        var i = 0;
        i < _count;
        ++i
    )
    {
        var _candidate =
            instance_find(
                _object,
                i
            );

        if (!instance_exists(_candidate))
            continue;

        if (
            _candidate.BuildingState
            == BuildingState.DESTROYED
        )
        {
            continue;
        }


        var _distance =
            point_distance(
                _enemy.x,
                _enemy.y,
                _candidate.x,
                _candidate.y
            );

        if (_distance >= _best_distance)
            continue;

        if (
            !scr_enemy_order_target_pathable(
                _enemy,
                _candidate
            )
        )
        {
            continue;
        }

        _best =
            _candidate;

        _best_distance =
            _distance;
    }


    // The candidate tests reuse the enemy's native path object. Restore its
    // final path to the chosen target before returning.

    if (instance_exists(_best))
    {
        scr_enemy_order_target_pathable(
            _enemy,
            _best
        );
    }

    return _best;
}


/// @description Returns the pathable target selected by one tactical order.

function scr_enemy_order_target_get(
    _enemy,
    _order_type
)
{
    if (!instance_exists(_enemy))
        return noone;


    switch (_order_type)
    {
        case EnemyOrder.TARGET_PLAYER:
        {
            var _player =
                global.vtd_level.entities.player;

            if (
                !instance_exists(_player)
                || !scr_enemy_order_target_pathable(
                    _enemy,
                    _player
                )
            )
            {
                return noone;
            }

            return _player;
        }


        case EnemyOrder.TARGET_MINER:
        {
            return scr_enemy_order_closest_pathable_get(
                _enemy,
                o_miner
            );
        }


        case EnemyOrder.TARGET_TOWER:
        {
            return scr_enemy_order_closest_pathable_get(
                _enemy,
                o_tower
            );
        }
    }

    return noone;
}


/// ============================================================================
/// ASSIGNMENT / FALLBACK
/// ============================================================================

/// @description Permanently abandons an order and restores ordinary enemy behaviour.

function scr_enemy_order_fallback(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.order.type =
        EnemyOrder.NONE;

    _enemy.order.target =
        noone;

    _enemy.targeting.breach =
        noone;


    var _ordinary_target =
        scr_enemy_target_acquire(
            _enemy
        );

    _enemy.targeting.strategic =
        _ordinary_target;

    _enemy.targeting.target =
        _ordinary_target;


    if (!instance_exists(_ordinary_target))
    {
        scr_navigation_enemy_stop(
            _enemy
        );

        return true;
    }


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


/// @description Assigns one tactical order and its one-time pathable target.

function scr_enemy_order_assign(
    _enemy,
    _order_type
)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        _enemy.EnemyBehavior
        == EnemyBehavior.BRAINLESS
    )
    {
        return false;
    }


    _enemy.order.type =
        EnemyOrder.NONE;

    _enemy.order.target =
        noone;


    if (_order_type == EnemyOrder.NONE)
        return true;


    var _target =
        scr_enemy_order_target_get(
            _enemy,
            _order_type
        );

    if (!instance_exists(_target))
    {
        // No pathable special target exists at spawn, so this enemy permanently
        // returns to its ordinary definition-driven target behaviour.

        return scr_enemy_order_fallback(
            _enemy
        );
    }


    _enemy.order.type =
        _order_type;

    _enemy.order.target =
        _target;

    _enemy.targeting.breach =
        noone;

    _enemy.targeting.strategic =
        _target;

    _enemy.targeting.target =
        _target;

    _enemy.order.player_follow.x =
        _target.x;

    _enemy.order.player_follow.y =
        _target.y;

    _enemy.order.player_follow.remaining =
        _enemy.order.player_follow.interval_seconds;

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


/// @description Initializes the enemy order runtime after advanced targeting exists.

function scr_enemy_order_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.order =
        scr_enemy_order_runtime_create();


    var _spawn_order =
        EnemyOrder.NONE;

    if (
        variable_instance_exists(
            _enemy,
            "spawn_order"
        )
    )
    {
        _spawn_order =
            _enemy.spawn_order;
    }


    return scr_enemy_order_assign(
        _enemy,
        _spawn_order
    );
}


/// ============================================================================
/// UPDATE
/// ============================================================================

/// @description Updates one active tactical order.

function scr_enemy_order_update(_enemy)
{
    if (!scr_enemy_order_active(_enemy))
        return false;


    var _order =
        _enemy.order;

    var _target =
        _order.target;


    if (!instance_exists(_target))
    {
        scr_enemy_order_fallback(
            _enemy
        );

        return false;
    }


    // Keep a player-hunt order following a moving player without recalculating
    // a path every Step.

    if (
        _order.type
        == EnemyOrder.TARGET_PLAYER
    )
    {
        var _fps =
            max(
                1,
                game_get_speed(gamespeed_fps)
            );

        var _follow =
            _order.player_follow;

        _follow.remaining =
            max(
                0,
                _follow.remaining
                - (1 / _fps)
            );

        if (_follow.remaining <= 0)
        {
            _follow.remaining =
                _follow.interval_seconds;

            if (
                point_distance(
                    _follow.x,
                    _follow.y,
                    _target.x,
                    _target.y
                )
                >= _follow.minimum_distance
            )
            {
                _follow.x =
                    _target.x;

                _follow.y =
                    _target.y;

                scr_navigation_enemy_repath_request(
                    _enemy,
                    false
                );
            }
        }
    }


    _enemy.targeting.strategic =
        _target;

    _enemy.targeting.target =
        _target;

    return true;
}