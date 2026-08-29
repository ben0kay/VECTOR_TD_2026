/// @description Synchronizes the player roll with the current strategic target.

function scr_enemy_player_roll_sync(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _runtime =
        _enemy.targeting.player;

    if (
        _runtime.roll.strategic_target
        == _enemy.targeting.strategic
    )
    {
        return true;
    }


    _runtime.roll.strategic_target =
        _enemy.targeting.strategic;

    _runtime.roll.completed =
        false;

    _runtime.roll.succeeded =
        false;


    return true;
}

/// @description Restores the best strategic target after player aggro ends.

function scr_enemy_player_target_restore(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _runtime =
        _enemy.targeting.player;

    _runtime.active =
        false;

    _runtime.roll.succeeded =
        false;


    // Look for a newly placed, meaningfully closer building immediately.

    scr_enemy_strategic_retarget_update(
        _enemy,
        true
    );


    // If the cached target was destroyed, acquire a replacement regardless
    // of the ordinary target-switch distance requirement.

    if (!instance_exists(_enemy.targeting.strategic))
    {
        var _replacement =
            scr_enemy_target_acquire(
                _enemy
            );

        scr_enemy_strategic_target_set(
            _enemy,
            _replacement
        );
    }


    _enemy.targeting.breach =
        noone;

    _enemy.targeting.target =
        _enemy.targeting.strategic;


    if (instance_exists(_enemy.targeting.target))
    {
        _enemy.navigation.reachable =
            true;

        _enemy.EnemyState =
            EnemyState.MOVING;

        scr_navigation_enemy_repath_request(
            _enemy,
            true
        );
    }


    return true;
}

/// @description Processes strategic retargeting and one player roll per objective.

function scr_enemy_player_targeting_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_struct_exists(_enemy.targeting, "player"))
        return true;


    var _runtime =
        _enemy.targeting.player;

    var _data =
        _runtime.data;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _delta =
        1 / _fps;


    // Enemies not pursuing the player may periodically reconsider buildings.

    if (!_runtime.active
    && _enemy.targeting.target_type == EnemyTarget.BUILDING)
	{
	    scr_enemy_strategic_retarget_update(_enemy);
	}


    scr_enemy_player_roll_sync(
        _enemy
    );


    if (!_data.enabled)
        return true;


    var _player =
        global.vtd_level.entities.player;


    // ========================================================================
    // MAINTAIN ACTIVE PLAYER TARGET
    // ========================================================================

    if (_runtime.active)
    {
        if (!instance_exists(_player))
        {
            return scr_enemy_player_target_restore(
                _enemy
            );
        }


        var _difference_x =
            _player.x - _enemy.x;

        var _difference_y =
            _player.y - _enemy.y;

        var _distance_squared =
            (_difference_x * _difference_x)
            + (_difference_y * _difference_y);

        var _forget_range =
            _data.acquire_range
            * max(
                1,
                _data.forget_range_multiplier
            );


        if (
            _distance_squared
            > _forget_range * _forget_range
        )
        {
            return scr_enemy_player_target_restore(
                _enemy
            );
        }


        // A completed failed route means the player cannot currently
        // be reached. Return to the cached strategic objective.

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


        _enemy.targeting.target =
            _player;


        // ================================================================
        // MOVING-TARGET PATH REFRESH
        // ================================================================

        var _follow =
            _runtime.follow_repath;

        _follow.remaining =
            max(
                0,
                _follow.remaining - _delta
            );


        var _player_move_x =
            _player.x - _follow.target_x;

        var _player_move_y =
            _player.y - _follow.target_y;

        var _player_move_squared =
            (_player_move_x * _player_move_x)
            + (_player_move_y * _player_move_y);

        var _minimum_distance_squared =
            _follow.minimum_distance
            * _follow.minimum_distance;


        if (
            _follow.remaining <= 0
            && _player_move_squared
                >= _minimum_distance_squared
        )
        {
            _follow.target_x =
                _player.x;

            _follow.target_y =
                _player.y;

            _follow.remaining =
                random_range(
                    _follow.interval_minimum,
                    _follow.interval_maximum
                );


            // This recalculates this enemy's route to the player's latest
            // position. It does not rebuild or modify the shared MP grid.

            scr_navigation_enemy_repath_request(
                _enemy,
                true
            );
        }


        return true;
    }


    // ========================================================================
    // ONE PLAYER ROLL FOR THE CURRENT STRATEGIC TARGET
    // ========================================================================

    if (_runtime.roll.completed)
        return true;

    if (!instance_exists(_enemy.targeting.strategic))
        return true;

    if (!instance_exists(_player))
        return true;


    var _difference_x =
        _player.x - _enemy.x;

    var _difference_y =
        _player.y - _enemy.y;

    var _distance_squared =
        (_difference_x * _difference_x)
        + (_difference_y * _difference_y);


    // Being outside acquisition range does not consume the roll.

    if (
        _distance_squared
        > _data.acquire_range
        * _data.acquire_range
    )
    {
        return true;
    }


    // Blocked line of sight does not consume the roll.

    if (
        _data.require_line_of_sight
        && !scr_enemy_player_line_of_sight_clear(
            _enemy,
            _player
        )
    )
    {
        return true;
    }


    // The required conditions are valid, so consume this objective's roll.

    _runtime.roll.completed =
        true;

    _runtime.roll.succeeded =
        random(1)
        <= _data.acquire_chance;


    if (!_runtime.roll.succeeded)
        return true;


    // Preserve the strategic building while temporarily pursuing the player.

    _runtime.active =
        true;

    _enemy.targeting.breach =
        noone;

    _enemy.targeting.target =
        _player;

    _enemy.navigation.reachable =
        true;

    _enemy.EnemyState =
        EnemyState.MOVING;


    // Cache the position used by this first path request.

    _runtime.follow_repath.target_x =
        _player.x;

    _runtime.follow_repath.target_y =
        _player.y;

    _runtime.follow_repath.remaining =
        random_range(
            _runtime.follow_repath.interval_minimum,
            _runtime.follow_repath.interval_maximum
        );


    scr_navigation_enemy_repath_request(
        _enemy,
        true
    );


    return true;
}

/// @description Returns whether an enemy has clear sight of the player.

function scr_enemy_player_line_of_sight_clear(
    _enemy,
    _player
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_player))
        return false;


    if (
        _enemy.movement.layer
        == EnemyMovementLayer.FLYING
    )
    {
        return true;
    }


    var _distance =
        point_distance(
            _enemy.x,
            _enemy.y,
            _player.x,
            _player.y
        );

    if (_distance <= 0)
        return true;


    var _spacing =
        max(
            8,
            global.vtd_level.map.cell_size
            * 0.5
        );

    var _checks =
        max(
            1,
            ceil(_distance / _spacing)
        );


    // Skip both endpoints. Only space between the enemy and player matters.

    for (var i = 1; i < _checks; ++i)
    {
        var _amount =
            i / _checks;

        var _check_x =
            lerp(
                _enemy.x,
                _player.x,
                _amount
            );

        var _check_y =
            lerp(
                _enemy.y,
                _player.y,
                _amount
            );


        if (
            scr_world_circle_gameplay_solid(
                _check_x,
                _check_y,
                2,
                true
            )
        )
        {
            return false;
        }
    }


    return true;
}