/// @description Original-style native mp_grid enemy navigation.


/// @description Returns the navigation grid used by an enemy.

function scr_navigation_enemy_grid_get(_enemy)
{
    if (!instance_exists(_enemy))
        return -1;

    if (!is_struct(global.vtd_level))
        return -1;

    if (!global.vtd_level.navigation.ready)
        return -1;


    // FUTURE:
    // Flying enemies may eventually use direct movement or a dedicated grid.
    // Underground enemies may eventually use a separate terrain grid.
    // Phasing is an ability, not a movement layer.

    switch (_enemy.movement.layer)
    {
        case EnemyMovementLayer.GROUND:
        {
            if (
                scr_enemy_has_ability(
                    _enemy,
                    EnemyAbility.PHASING
                )
            )
            {
                return global.vtd_level
                    .navigation.grid_breach;
            }

            return global.vtd_level
                .navigation.grid_ground;
        }


        case EnemyMovementLayer.FLYING:
        {
            return global.vtd_level
                .navigation.grid_breach;
        }


        case EnemyMovementLayer.UNDERGROUND:
        {
            return global.vtd_level
                .navigation.grid_breach;
        }
    }


    return -1;
}


/// @description Requests a new path after a small randomized delay.

function scr_navigation_enemy_repath_request(
    _enemy,
    _immediate = false
)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.navigation.needs_path =
        true;


    if (_immediate)
    {
        // Even immediate requests are spread over a few frames.
        // This will matter when many enemies spawn together.

        _enemy.navigation.repath_timer =
            real(_enemy.id) mod 4;
    }
    else
    {
        _enemy.navigation.repath_timer =
            irandom_range(
                15,
                30
            );
    }


    return true;
}


/// @description Stops an enemy's current native path.

function scr_navigation_enemy_stop(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    with (_enemy)
    {
        path_end();
    }


    return true;
}


/// @description Calculates and starts a path to the current target.

function scr_navigation_enemy_path_build(
    _enemy
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(
        _enemy.targeting.target
    ))
    {
        return false;
    }


    var _grid =
        scr_navigation_enemy_grid_get(
            _enemy
        );

    if (_grid < 0)
        return false;


    var _path =
        _enemy.navigation.path_id;

    var _target =
        _enemy.targeting.target;


    path_clear_points(
        _path
    );


    var _path_found =
        mp_grid_path(
            _grid,
            _path,
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y,
            true
        );


    if (!_path_found)
    {
        _enemy.navigation.reachable =
            false;

        path_clear_points(
            _path
        );

        return false;
    }


    _enemy.navigation.reachable =
        true;

    _enemy.navigation.needs_path =
        false;

    _enemy.navigation.revision_seen =
        global.vtd_level.navigation.revision;


    with (_enemy)
    {
        path_start(
            navigation.path_id,
            movement.speed,
            path_action_stop,
            true
        );
    }


    return true;
}


/// @description Updates one enemy's path request.

function scr_navigation_enemy_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(
        _enemy.targeting.target
    ))
    {
        scr_navigation_enemy_stop(
            _enemy
        );

        return false;
    }


    // A changed navigation revision means a building or obstacle changed.
    //
    // FUTURE:
    // Building placement will increase this revision and update only the
    // affected mp_grid cells.

    if (
        _enemy.navigation.revision_seen
        != global.vtd_level.navigation.revision
        && !_enemy.navigation.needs_path
    )
    {
        scr_navigation_enemy_repath_request(
            _enemy,
            false
        );
    }


    if (_enemy.navigation.needs_path)
    {
        _enemy.navigation.repath_timer--;


        if (
            _enemy.navigation.repath_timer
            <= 0
        )
        {
            return scr_navigation_enemy_path_build(
                _enemy
            );
        }
    }


    // Keep native path speed synchronized with enemy data and future effects.

    _enemy.path_speed =
        _enemy.movement.speed;


    if (_enemy.speed > 0)
    {
        _enemy.visual.draw_angle =
            _enemy.direction;
    }


    return true;
}


/// @description Deletes the native path owned by an enemy.

function scr_navigation_enemy_cleanup(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    scr_navigation_enemy_stop(
        _enemy
    );


    if (
        _enemy.navigation.path_id >= 0
        && path_exists(
            _enemy.navigation.path_id
        )
    )
    {
        path_delete(
            _enemy.navigation.path_id
        );
    }


    _enemy.navigation.path_id =
        -1;


    return true;
}